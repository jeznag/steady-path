//
//  CardElement.swift
//  AFP-Ripple
//
//

import SwiftUI



struct ExploreCard: View {
    
    @Binding var templateText: String
    @Binding var affirmationText: String
    @Binding var liked: Bool
    
    @State private var showingShareSheet = false
    @State var grad1: Color = .blue
    @State var grad2: Color = .yellow
    @State var heartStatus: String = "heart"
    @State var colorArrayCopy: [Color] = [
        Color(#colorLiteral(red: 0.879907012, green: 0.7766652703, blue: 0.1443305612, alpha: 1)),
        Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)),
        Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)),
    ]
    
    @EnvironmentObject var savedCards: Deck
    
    let colorArray: [Color] = [
        Color(#colorLiteral(red: 0.879907012, green: 0.7766652703, blue: 0.1443305612, alpha: 1)),
        Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)),
        Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .ignoresSafeArea()
                    
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width:300, height: 500)
                        .foregroundStyle(LinearGradient(
                            colors:
                                [colorArrayCopy[0],
                                 colorArrayCopy[1],
                                 colorArrayCopy[2]],
                            startPoint: .top, endPoint: .bottom))
                    //                        .overlay(
                    //                                RoundedRectangle(cornerRadius: 25)
                    //                                    .stroke(.rippleYellow1, lineWidth: 2)
                    //                            )
                    
                    
                    VStack {
                        Spacer()
                        
                        // Moved text lower
                        VStack(spacing: 12) {
                            Text(templateText)
                                .foregroundStyle(.white)
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            Text(affirmationText)
                                .multilineTextAlignment(.center)
                                .frame(width: 200, height: 60)
                                .foregroundStyle(.white)
                                .font(.largeTitle)
                                .fontWeight(.black)
                        }
                        .padding(.top, 30) // Slightly lower
                        
                        Spacer()
                
                        // Bottom buttons aligned horizontally
                        HStack(spacing: 30) {
                            Button {
                                liked.toggle()
                            } label: {
                                Image(systemName: liked ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                            
                            Button {
                                showingShareSheet.toggle()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                            }
                            .sheet(isPresented: $showingShareSheet) {
                                ShareSheet(activityItems: [templateText + " " + affirmationText])
                            }
                        }
                        .padding(.bottom, 20)
                        
                    }
                    .padding()
                    .frame(width: 350, height: 500)
                    
                }
                .onAppear(){
                    colorArrayCopy = colorArray.shuffled()
                }
            }
        }
    }
    
    
    struct ShareSheet: UIViewControllerRepresentable {
        var activityItems: [Any]  // The content to be shared
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    
    //    #Preview {
    //        @Previewable @State var templateText = "I am preview"
    //        @Previewable @State var affirmationText = "Cool"
    //        @Previewable @State var liked = false
    //        ExploreCard(templateText: $templateText, affirmationText: $affirmationText, liked: $liked)
}
