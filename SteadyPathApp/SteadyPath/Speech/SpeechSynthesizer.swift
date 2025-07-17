import Foundation
import AVFoundation

class OpenAITTS: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer? // <-- retain!
    private var onComplete: (() -> Void)?

    private enum Constants {
        static let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        static let apiKey = Secrets.openAIKey
        static let organisation: String? = nil // optional
    }

    private lazy var session: URLSession = {
        URLSession(configuration: .default)
    }()

    func speak(_ text: String, onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        var request = URLRequest(url: Constants.url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Constants.apiKey)", forHTTPHeaderField: "Authorization")
        if let org = Constants.organisation {
            request.addValue(org, forHTTPHeaderField: "OpenAI-Organization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": "tts-1",
            "voice": "ash",            // try English + Aussie preference
            "response_format": "mp3",
            "input": text
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task = session.downloadTask(with: request) { fileURL, resp, error in
            if let error = error {
                print("❌ TTS download error:", error)
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("❌ No HTTP response")
                return
            }
            print("📡 Status:", resp.statusCode)

            guard let fileURL = fileURL else {
                print("❌ No file URL")
                return
            }

            do {
                let dest = FileManager.default.temporaryDirectory.appendingPathComponent("speech.mp3")

                if FileManager.default.fileExists(atPath: dest.path) {
                    try FileManager.default.removeItem(at: dest)
                }

                try FileManager.default.moveItem(at: fileURL, to: dest)
                print("✅ Audio saved at", dest)
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                self.audioPlayer = try AVAudioPlayer(contentsOf: dest)
                self.audioPlayer?.delegate = self // 🟢 IMPORTANT
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
            } catch {
                print("❌ Playback error:", error)
            }
        }
        task.resume()
        print("📤 TTS request sent")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("✅ Playback finished delegate called")
        onComplete?()
    }
}
