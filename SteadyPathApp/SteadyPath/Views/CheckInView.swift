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

extension Notification.Name {
    static let transcriptionFinalised = Notification.Name("transcriptionFinalised")
}

struct CheckInView: View {
    @State private var currentPrompt = ""
    @State private var responseText = ""
    @State private var questionIndex = 0
    @State private var isListening = false
    @StateObject private var speechDelegate = SpeechDelegate()
    @StateObject private var recognizer = RecognizerController()
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var selectedPersona = "Bogan Barry"
    @State private var hasStarted = false
    @State private var isLoading = false

    let personas = ["Bogan Barry", "Calm Carla", "Supportive Sam", "Neutral"]

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

            if !hasStarted {
                Text("Pick a vibe for your check-in:")
                    .font(.headline)
                Picker("Persona", selection: $selectedPersona) {
                    ForEach(personas, id: \.self) { persona in
                        Text(persona)
                    }
                }
                .pickerStyle(.wheel)

                Button("Start") {
                    hasStarted = true
                    setupAudioSession()
                    requestSpeechAuth()
                    NotificationCenter.default.addObserver(forName: .transcriptionFinalised, object: nil, queue: .main) { notification in
                        if let final = notification.object as? String {
                            self.responseText = final // Update final responseText
                        self.isListening = false // No longer listening
                        // Automatically proceed only if there's actual speech or a deliberate end
                        if !final.isEmpty {
                            playNextPrompt()
                        } else {
                            // If nothing was said, ensure loading is off and listening can restart if needed
                            self.isLoading = false
                            self.currentPrompt = "Didn't quite catch that. Could you please say something?"
                            self.speak(self.currentPrompt) {
                                self.isListening = true
                                self.recognizer.startTranscription { _ in }
                            }
                        }
                    }
                    loadFirstPrompt()
                }
                .padding()
            } else {
                Text(currentPrompt)
                    .font(.headline)
                    .padding()

                if isListening {
                    Text("🎤 Listening...")
                        .foregroundColor(.blue)
                } else if isLoading { // 👈 Display spinner when loading
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5) // Make it a bit bigger
                        .padding()
                }

                Text(isListening ? recognizer.liveTranscript : responseText)
                    .italic()
                    .padding()

                Button("Next") {
                    recognizer.stop() // stop recording first
                    playNextPrompt()
                }
                .disabled(isListening || responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    func loadFirstPrompt() {
        isLoading = true
        ApiClient.shared.getNextPrompt(transcript: "===Nothing said yet - conversation about to start. Ask the first question.====", persona: selectedPersona) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    currentPrompt = res.next_prompt
                    self.isLoading = false;
                    speak(currentPrompt) {
                        isListening = true
                        recognizer.startTranscription { transcript in
                            responseText = transcript
                            isListening = false
                        }
                    }
                case .failure(let error):
                    currentPrompt = "Error getting first question. Try again."
                    print("❌ Error: \(error)")
                }
            }
        }
    }

    func playNextPrompt() {
        // Already finished listening and captured the transcript
        let transcript = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty else {
            print("⚠️ No transcript captured.")
            return
        }

        isListening = false // Just in case
        isLoading = true

        ApiClient.shared.getNextPrompt(transcript: transcript, persona: selectedPersona) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    currentPrompt = "\(res.validation) \(res.next_prompt)"
                    isLoading = true
                    speak(currentPrompt) {
                        isListening = true
                        recognizer.startTranscription { nextTranscript in
                            responseText = nextTranscript
                            isListening = false
                        }
                    }

                case .failure(let error):
                    currentPrompt = "Something went wrong, sorry mate. Try again later."
                    print("❌ API Error: \(error.localizedDescription)")
                }
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
    private var speechTimer: Timer?
    private let speechTimeoutDuration: TimeInterval = 2.0 // 2 seconds of silence

    func startTranscription(onResult: @escaping (String) -> Void) {
        // Cancel the previous task if it's running
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        // Invalidate any existing timer
        speechTimer?.invalidate()
        speechTimer = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true // Crucial for live updates

        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("Speech recognizer is not available or not supported for the current locale.")
            onResult("") // Inform the caller that recognition won't start
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
            // Start the silence detection timer
            resetSpeechTimer(onResult: onResult)
        } catch {
            print("Audio engine couldn't start: \(error)")
            onResult("") // Inform the caller about the error
        }

        // Request authorization again (it's good practice to ensure it's authorized when starting a new task)
        SFSpeechRecognizer.requestAuthorization { status in
            print("Speech authorization status: \(status)")
            if status != .authorized {
                print("Speech recognition not authorized.")
                self.stop()
                onResult("") // Inform the caller that recognition won't proceed
                return
            }
        }

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result = result {
                let final = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.liveTranscript = final
                }
                isFinal = result.isFinal

                // If we get any result (partial or final), reset the timer
                self.resetSpeechTimer(onResult: onResult)

                if isFinal {
                    DispatchQueue.main.async {
                        self.liveTranscript = final
                        NotificationCenter.default.post(name: .transcriptionFinalised, object: final)
                    }
                }
            }

            if error != nil || isFinal {
                // If there's an error or the result is final, stop
                self.stop()
                self.speechTimer?.invalidate() // Invalidate timer when stopped naturally
                if let result = result {
                    onResult(result.bestTranscription.formattedString)
                } else {
                    onResult("") // In case of error with no partial result
                }
            }
        }
    }

    private func resetSpeechTimer(onResult: @escaping (String) -> Void) {
        speechTimer?.invalidate() // Invalidate existing timer
        speechTimer = Timer.scheduledTimer(withTimeInterval: speechTimeoutDuration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("Speech timeout reached. Stopping recognition.")
            self.stop()
            // If the timer fires and we have a partial transcript, send it as final
            if !self.liveTranscript.isEmpty {
                NotificationCenter.default.post(name: .transcriptionFinalised, object: self.liveTranscript)
            } else {
                // If no speech was detected at all, send an empty string
                NotificationCenter.default.post(name: .transcriptionFinalised, object: "")
            }
        }
    }


    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel() // Cancel to stop processing immediately
        recognitionTask = nil
        recognitionRequest = nil
        speechTimer?.invalidate() // Ensure timer is stopped
        speechTimer = nil

        // Reset liveTranscript when stopping
        DispatchQueue.main.async {
            self.liveTranscript = ""
        }
    }
}
