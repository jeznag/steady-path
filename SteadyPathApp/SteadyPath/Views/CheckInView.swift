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
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setPreferredSampleRate(44100)
        try session.setPreferredInputNumberOfChannels(1)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        print("🎧 Audio session set up: \(session.sampleRate) Hz, \(session.inputNumberOfChannels) ch")

        if let input = session.preferredInput {
            print("🎙️ Preferred input: \(input.portName)")
        }

    } catch {
        print("❌ Failed to set up audio session: \(error.localizedDescription)")
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
    @State private var fullTranscript: String = ""
    @State private var ttsSynthesizer: OpenAITTS? = OpenAITTS()

    let personas = ["Bogan Barry", "Calm Carla", "Supportive Sam", "Neutral"]


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

                Button("Done") {
                    isListening = false
                    print("done!87")
                    recognizer.stop() // triggers transcriptionFinalised when done
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .transcriptionFinalised, object: nil, queue: .main) { notification in
                if let final = notification.object as? String {
                    self.responseText = final
                    print("Not listening anymore96")
                    self.isListening = false

                    if !final.isEmpty {
                        playNextPrompt()
                    } else {
                        self.isLoading = false
                        self.currentPrompt = "Didn't quite catch that. Could you please say something?"
                        self.speak(self.currentPrompt) {
                            print("Finished talking. Restarting listening")
                            self.isListening = true
                            self.recognizer.startTranscription { _ in }
                        }
                    }
                }
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
                        print("yo122")
                        self.isListening = true
                        recognizer.startTranscription { _ in }
                    }
                case .failure(let error):
                    currentPrompt = "Error getting first question. Try again."
                    print("❌ Error: \(error)")
                }
            }
        }
    }

    func playNextPrompt() {
        let cleanedResponse = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedResponse.isEmpty else {
            print("⚠️ No transcript captured.")
            return
        }

        fullTranscript += "\nUser: \(cleanedResponse)\n"

        print("Play next prompt!")
        self.isListening = false
        self.isLoading = true

        ApiClient.shared.getNextPrompt(transcript: fullTranscript, persona: selectedPersona) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    let nextPrompt = "\(res.validation) \(res.next_prompt)"
                    fullTranscript += "App: \(nextPrompt)\n"
                    currentPrompt = nextPrompt
                    self.isLoading = false
                    speak(nextPrompt) {
                        print("yo155")
                        self.isListening = true
                        recognizer.startTranscription { _ in }
                    }

                case .failure(let error):
                    currentPrompt = "Something went wrong, sorry mate. Try again later."
                    print("❌ API Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func speak(_ text: String, onCompleteOuter: @escaping () -> Void) {
        print("📞 speak() called with text: \(text)")
        DispatchQueue.global(qos: .userInitiated).async {
            ttsSynthesizer?.speak(text) {
                print("🎉 Done playing")
                DispatchQueue.main.async {
                    onCompleteOuter()
                }
            }
        }
    }

    func requestSpeechAuth() {
        print("yo205")
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                print("🎤 Mic permission (iOS 17+): \(granted)")
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                print("🎤 Mic permission (legacy): \(granted)")
            }
        }
    }
}

// -------------------------------------------------------------------------------------------------------

import AVFAudio

class RecognizerController: ObservableObject {
    @Published var liveTranscript: String = ""
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?

    func startTranscription(onResult: @escaping (String) -> Void) {
        print("🧪 startTranscription() called")
        let filename = UUID().uuidString + ".m4a"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        recordingURL = path

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            setupAudioSession()
            recorder = try AVAudioRecorder(url: path, settings: settings)
            print("🛠️ Recorder created")
            recorder?.record()
            print("🎙️ Started recording to \(path)")
        } catch {
            print("❌ Failed to start recording: \(error)")
            onResult("")
        }
    }

    func stop() {
        guard let recorder = recorder, recorder.isRecording else {
            print("⚠️ Tried to stop but recorder is nil or not recording")
            return
        }

        recorder.stop()
        print("🛑 Stopped recording")

        if let url = recordingURL {
            print("📤 Sending to transcription: \(url.lastPathComponent)")
            transcribeFile(url: url)
        }

        self.recorder = nil
        self.recordingURL = nil
    }

    private func transcribeFile(url: URL) {
        print("⬆️ Uploading to OpenAI: \(url.lastPathComponent)")
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\nwhisper-1\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(try! Data(contentsOf: url))
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("❌ API request failed: \(error?.localizedDescription ?? "Unknown error")")
                NotificationCenter.default.post(name: .transcriptionFinalised, object: "")
                return
            }

            if let result = try? JSONDecoder().decode(OpenAIWhisperResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.liveTranscript = result.text
                    NotificationCenter.default.post(name: .transcriptionFinalised, object: result.text)
                }
            } else {
                print("❌ Failed to decode API response: \(String(data: data, encoding: .utf8) ?? "No body")")
                NotificationCenter.default.post(name: .transcriptionFinalised, object: "")
            }
        }.resume()
    }

    struct OpenAIWhisperResponse: Codable {
        let text: String
    }
}
