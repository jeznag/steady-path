//
//  CardElement.swift
//  AFP-Ripple
//
//

import SwiftUI
import NaturalLanguage

struct CreateCard: View {
    
    @FocusState private var responseIsFocused: Bool
    
    @State var templateOptions: Bool = false
    @Binding var templateText: String
    @State var affirmationText: String = ""
    @State private var sentimentText: String = ""
    
    @EnvironmentObject var savedCards: Deck
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width:300, height: 500)
                .foregroundStyle(LinearGradient(colors: [.blue, .yellow], startPoint: .top, endPoint: .bottom))
            
            VStack{
                Spacer()
                Text(templateText)
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                ZStack {
                    
                    if affirmationText.isEmpty {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 200, height: 60)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }
                    TextEditor(text: $affirmationText)
                        .focused($responseIsFocused)
                        .onReceive(affirmationText.publisher.last()) {
                            if($0 as Character).asciiValue == 10 {
                                responseIsFocused = false
                                affirmationText.removeLast()
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .multilineTextAlignment(.center)
                        .frame(width: 200, height: 60)
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .background(Color.clear)
                        .onChange(of: affirmationText) { newValue in
                            analyzeSentiment()
                        }
                }
                .padding(.top, -10)
                
                Text(sentimentText)
                    .frame(height: 10)
                    .foregroundStyle(.white)
                    .italic()
                    .multilineTextAlignment(.center)
                
                Button {
                    //Add saving function here
                    let savedCard = Card(template: templateText, affirmation: affirmationText, saved: true)
                    savedCards.addCard(card: savedCard)
                    affirmationText = ""
                } label: {
                    if !affirmationText.isEmpty{
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 150)
                .frame(width: 40, height: 40)
                Spacer()
            }
            .padding()
            .padding(.bottom, 7)
            .frame(width:350, height: 500)
            
            .actionSheet(isPresented: $templateOptions) {
                ActionSheet(
                    title: Text("Choose an option"),
                    message: Text("Select one of the following actions"),
                    buttons: [
                        .default(Text("I am")) {
                            templateText = "I am"
                        },
                        .default(Text("I will")) {
                            templateText = "I will"
                        },
                        .default(Text("I believe")) {
                            templateText = "I believe"
                        },
                        .default(Text("I have")) {
                            templateText = "I have"
                        },
                        .default(Text("I can")) {
                            templateText = "I can"
                        },
                        .destructive(Text("Reset")) {
                            print("Reset")
                        },
                        .cancel()
                    ]
                )
                
            }
            
        }
    }
    
    func analyzeSentiment() {
        let sentimentScore = getSentimentScore(from: "\"" + templateText + " " + affirmationText + "\"")
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


#Preview {
    @Previewable @State var text = "I am"
    CreateCard(templateText: $text)
}
