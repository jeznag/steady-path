//
//  CardView.swift
//  AFP-Ripple
//
//  Created by Donovan Ong on 24/2/2025.
//

import SwiftUI

struct CreateView: View {
    
    @State private var selectedPage: Int = 0
    @State var templateText: [String] = [
        "I am",
        "I believe",
        "I can",
        "I will",
        "I build"
    ]
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundStyle(.blue)
                .ignoresSafeArea()
            
            TabView(selection: $selectedPage) {
                ForEach(0..<templateText.count, id: \.self) { i in
                    VStack () {
                        Text("Create")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.yellow)
                            .multilineTextAlignment(.center)
                            .frame(width: 250)
                        Spacer()
                        CreateCard(templateText: $templateText[i])
                            .offset(y: -20)
                            .tag(i)
                            .tabItem {
                                Text("Page \(i + 1)")
                            }
                        Spacer()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

#Preview {
    CreateView()
}
