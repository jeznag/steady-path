//
//  CardHelper.swift
//  AFP-Ripple
//
//  Created by Donovan Ong on 25/2/2025.
//

import SwiftUI
import NaturalLanguage

struct CardHelper: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct card: Identifiable {
//    var id = UUID()
//    var template: String
//    var affirmation: String
//    var saved: Bool
//}

class Deck: Identifiable, ObservableObject {
    @Published var cards: [Card]  // Observable array of Card objects
    
    init(cards: [Card] = []) {
        self.cards = cards
    }
    
    func addCard(card: Card) {
        cards.append(card)
    }
    
    func removeCard(card: Card) {
        cards.removeAll { $0.id == card.id }
    }
}

class Card: Identifiable, ObservableObject {
    var id = UUID()  // Unique identifier
    @Published var template: String  // Observable property
    @Published var affirmation: String  // Observable property
    @Published var saved: Bool  // Observable property
    
    init(template: String, affirmation: String, saved: Bool) {
        self.template = template
        self.affirmation = affirmation
        self.saved = saved
    }
}

struct SentimentAnalysisView: View {
    @State private var userInput: String = ""
    @State private var sentimentText: String = "placeholder" // Default neutral face
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling today?")
                .font(.headline)
            
            TextField("Enter your feeling...", text: $userInput, onCommit: analyzeSentiment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text(sentimentText)
                .font(.system(size: 50))
                .animation(.easeInOut, value: sentimentText)
            
            Button("Analyze Sentiment") {
                analyzeSentiment()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func analyzeSentiment() {
        let sentimentScore = getSentimentScore(from: userInput)
        sentimentText = sentimentString(for: sentimentScore)
    }
    
    /// Function to get the sentiment score from text
    func getSentimentScore(from text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        var sentimentScore: Double = 0.0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .sentence, scheme: .sentimentScore, options: []) { tag, _ in
            if let tagValue = tag?.rawValue, let score = Double(tagValue) {
                sentimentScore = score
            }
            return false
        }
        return sentimentScore
    }
    
    func sentimentString(for score: Double) -> String {
        let sentimentEmojis = ["Let's try something more positive...",
                               "Could be better?",
                               "Not bad!",
                               "Very nice!"] // From negative to positive
        let index = min(max(Int((score + 1) * 2), 0), sentimentEmojis.count - 1) // Normalize score to index
        return sentimentEmojis[index]
    }
}

struct SentimentAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        SentimentAnalysisView()
    }
}

#Preview {
    CardHelper()
}
