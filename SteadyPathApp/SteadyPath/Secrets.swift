//
//  Secrets.swift
//  SteadyPath
//
//  Created by Jeremy Nagel on 17/7/2025.
//


import Foundation

struct Secrets {
    static var openAIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OpenAI_API_Key"] as? String else {
            fatalError("❌ OpenAI_API_Key not found in Secrets.plist")
        }
        return key
    }
}
