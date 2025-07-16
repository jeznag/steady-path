import SwiftUI
import AVFoundation
import Speech

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    var onComplete: (() -> Void)?
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onComplete?()
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

            Text(responseText)
                .italic()
                .padding()

            Button("Next") {
                playNextPrompt()
            }
            .disabled(isListening || questionIndex >= questions.count)
        }
        .onAppear {
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

class RecognizerController: ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-AU"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func startTranscription(onResult: @escaping (String) -> Void) {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request,
              let recognizer = recognizer,
              recognizer.isAvailable else { return }

        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result = result, result.isFinal {
                print("transcript" + result.bestTranscription.formattedString )
                onResult(result.bestTranscription.formattedString)
                self.stop()
            }

            if error != nil {
                self.stop()
            }
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        task?.cancel()
        request = nil
    }
}
