//
//  ExploreView.swift
//  AFP-Ripple
//
//  Created by Donovan Ong on 25/2/2025.
//

import SwiftUI

struct ExploreView: View {
    
    @State var selectedPage = 0
    @State var exploreCards: Deck = Deck(cards: [
        Card(template: "I am", affirmation: "strong", saved: false),
        Card(template: "I believe", affirmation: "in myself", saved: false),
        Card(template: "I am", affirmation: "cool", saved: false),
        Card(template: "I can", affirmation: "achieve", saved: false),
        Card(template: "I will", affirmation: "progress", saved: false),
        Card(template: "I will", affirmation: "be happy", saved: false),
        Card(template: "I am", affirmation: "boom", saved: false),
        Card(template: "I am", affirmation: "boom", saved: false),
        Card(template: "I am", affirmation: "boom", saved: false),
        Card(template: "I am", affirmation: "boom", saved: false),
    ])
    
    @EnvironmentObject var savedCards: Deck
//    @EnvironmentObject var exploreCards: Deck
    
    var body: some View {
        NavigationStack {
            ZStack{
                Rectangle()
                    .foregroundStyle(.white)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Motivation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow1)
                        .multilineTextAlignment(.center)
                        .frame(width: 250)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(0..<exploreCards.cards.count, id: \.self) { i in
                                VStack () {
                                    Spacer()
                                    ExploreCard(templateText: $exploreCards.cards[i].template, affirmationText: $exploreCards.cards[i].affirmation, liked: $exploreCards.cards[i].saved)
                                        .offset(y: -20)
                                        .tag(i)
                                        .tabItem {
                                            Text("Page \(i + 1)")
                                        }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var savedCards = Deck()
    ExploreView()
        .environmentObject(savedCards)
}
