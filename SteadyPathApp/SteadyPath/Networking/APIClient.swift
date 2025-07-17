import Foundation

struct NextPromptResponse: Decodable {
    let validation: String
    let next_prompt: String
}

enum ApiError: Error {
    case invalidURL
    case decodingError
    case serverError(String)
}

class ApiClient {
    static let shared = ApiClient()
    private init() {}

    func getNextPrompt(transcript: String, persona: String, completion: @escaping (Result<NextPromptResponse, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:5000/next_prompt") else {
            completion(.failure(ApiError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = [
            "transcript": transcript,
            "persona": persona
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ApiError.serverError("No data received")))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(NextPromptResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Decoding error: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response: \(raw)")
                }
                completion(.failure(ApiError.decodingError))
            }
        }.resume()
    }
}
