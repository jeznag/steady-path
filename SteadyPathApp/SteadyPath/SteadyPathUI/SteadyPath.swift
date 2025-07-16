//
//  AFP_RippleApp.swift
//  AFP-Ripple
//
//
//

import SwiftUI

struct SteadyPath: App {
    @StateObject var savedCards: Deck = Deck(cards: [
        Card(template: "I am", affirmation: "a placeholder", saved: true),
    ])
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab {
                    HomeView()
                } label: {
                    Image(systemName: "house")
                    Text("Home")
                }
                Tab {
                    ExploreView()
                } label: {
                    Image(systemName: "person.crop.circle")
                    Text("Motivation")
                    
                }
                Tab {
                    CheckInView()
                } label: {
                    Image(systemName: "gearshape.fill")
                    Text("CheckIn")
                }
            }
            .environmentObject(savedCards)
            
        }
        
    }
}
