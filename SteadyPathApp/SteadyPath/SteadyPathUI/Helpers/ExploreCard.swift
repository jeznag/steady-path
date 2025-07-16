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
                    

                    VStack{
                        Spacer()
                        Text(templateText)
                            .foregroundStyle(.white)
                            .font(.title)
                            .fontWeight(.semibold)
                        ZStack {
                            Text(affirmationText)
                                .multilineTextAlignment(.center)
                                .frame(width: 200, height: 60)
                                .foregroundStyle(.white)
                                .font(.largeTitle)
                                .fontWeight(.black)
                        }
                        .padding(.top, -10)
                        Spacer()
                        
                        HStack{
                            Spacer()
                            Button {
                                liked.toggle()
                                
                                if liked {
                                    savedCards.addCard(card: Card(template: templateText, affirmation: affirmationText, saved: true))
                                }
                            } label: {
                                Image(systemName: liked ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            NavigationLink(destination: CreateView()) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            Button {
                                showingShareSheet.toggle()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                                .sheet(isPresented: $showingShareSheet) {
                                    // Step 3: Present the Share Sheet
                                    ShareSheet(activityItems: [templateText + " " + affirmationText])
                                }
                        }
                    }
                    .padding()
                    .padding(.bottom, 7)
                    .frame(width:350, height: 500)
                }
                .onAppear(){
                    colorArrayCopy = colorArray.shuffled()
                }
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


#Preview {
    @Previewable @State var templateText = "I am preview"
    @Previewable @State var affirmationText = "Cool"
    @Previewable @State var liked = false
    ExploreCard(templateText: $templateText, affirmationText: $affirmationText, liked: $liked)
}
