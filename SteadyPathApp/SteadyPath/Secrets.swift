import Foundation

struct Secrets {
    private static var dict: NSDictionary? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            fatalError("❌ Secrets.plist not found")
        }
        return dict
    }

    static var openAIKey: String {
        guard let key = dict?["OpenAI_API_Key"] as? String else {
            fatalError("❌ OpenAI_API_Key not found")
        }
        return key
    }
}
