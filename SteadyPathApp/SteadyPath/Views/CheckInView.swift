import SwiftUI
import AVFoundation
import Speech

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    var onComplete: (() -> Void)?
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onComplete?()
    }
}

func setupAudioSession() {
    do {
        // Set category for playback (for synthesizer) and record (for recognizer)
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
        print("Failed to set up audio session: \(error.localizedDescription)")
    }
}

struct CheckInView: View {
    @State private var currentPrompt = ""
    @State private var responseText = ""
    @State private var questionIndex = 0
    @State private var isListening = false
    @StateObject private var speechDelegate = SpeechDelegate()
    @StateObject private var recognizer = RecognizerController()
    @State private var synthesizer = AVSpeechSynthesizer()


    let questions = [
        "Alright mate, did ya take your meds today or what?",
        "What’d you get up to today?",
        "Feelin’ all good or been a bit cooked lately?",
        "Had a few drinks or a puff?",
        "Feelin' safe or been thinkin' about some dark stuff?"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("🧠 SteadyPath Check-In")
                .font(.title2)

            Text(currentPrompt)
                .font(.headline)
                .padding()

            if isListening {
                Text("🎤 Listening...")
                    .foregroundColor(.blue)
            }

            Text(isListening ? recognizer.liveTranscript : responseText)
                .italic()
                .padding()

            Button("Next") {
                playNextPrompt()
            }
            .disabled(isListening || questionIndex >= questions.count)
        }
        .onAppear {
            setupAudioSession() // Add this line
            requestSpeechAuth()
            playNextPrompt()
        }
    }

    func playNextPrompt() {
        guard questionIndex < questions.count else { return }
        currentPrompt = questions[questionIndex]
        speak(currentPrompt) {
            isListening = true
            recognizer.startTranscription { transcript in
                responseText = transcript
                isListening = false
                questionIndex += 1
            }
        }
    }

    func speak(_ text: String, onComplete: @escaping () -> Void) {
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            print("\(voice.identifier) - \(voice.name) - \(voice.language)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_gordon_en-AU_compact")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.95

        speechDelegate.onComplete = onComplete
        synthesizer.delegate = speechDelegate
        synthesizer.speak(utterance)
    }

    func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized")
            }
        }
    }
}

// -------------------------------------------------------------------------------------------------------

class RecognizerController: ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-AU"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    @Published var liveTranscript: String = ""

    func startTranscription(onResult: @escaping (String) -> Void) {
        // Cancel the previous task if it's running
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true // Crucial for live updates

        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("Speech recognizer is not available or not supported for the current locale.")
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start: \(error)")
        }
        
        // Request authorization again (it's good practice to ensure it's authorized when starting a new task)
        SFSpeechRecognizer.requestAuthorization { status in
            print("Speech authorization status: \(status)")
            if status != .authorized {
                print("Speech recognition not authorized.")
                self.stop()
                return
            }
        }

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result = result {
                DispatchQueue.main.async {
                    self.liveTranscript = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.stop()
                if let result = result {
                    onResult(result.bestTranscription.formattedString)
                } else {
                    onResult("") // In case of error with no partial result
                }
            }
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel() // Changed from .cancel() to .finish() if you want to ensure the final result is processed before stopping
        recognitionTask = nil
        recognitionRequest = nil
        // Reset liveTranscript when stopping
        DispatchQueue.main.async {
            self.liveTranscript = ""
        }
    }
}
