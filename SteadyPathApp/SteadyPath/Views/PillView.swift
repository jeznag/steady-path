import SwiftUI
import WidgetKit

struct PillView: View {
    @State private var takingMedicine = SharedDataManager.shared.takingMedicine
    
    let takingMedGradientOrange: AngularGradient = {
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .orange,
                            .red,
                            .yellow,
                            .orange
                        ]),
                        center: .center,
                        angle: .degrees(0)
                    )

    }()
    let takingMedGradientGreen: AngularGradient = {
        AngularGradient(
            gradient: Gradient(colors: [
                Color(red: 0.22, green: 0.73, blue: 0.39), // Duolingo main green
                Color(red: 0.18, green: 0.8, blue: 0.44),  // Bright green
                Color(red: 0.13, green: 0.59, blue: 0.29), // Darker green
                Color(red: 0.22, green: 0.73, blue: 0.39), // Back to main green
                Color(red: 0.25, green: 0.85, blue: 0.48), // Lighter green
                Color(red: 0.22, green: 0.73, blue: 0.39)  // Main green again
            ]),
            center: .center,
            angle: .degrees(0)
        )

    }()

    private var backgroundColor: AngularGradient {
        takingMedicine ? takingMedGradientGreen : takingMedGradientOrange
    }
    
    private var backgroundTitle: some View {
        takingMedicine ?
        textField(message: "Great Job! You're doing great!") :
        textField(message: "Don't forget to take your medicine")
    }
    
    func textField(message: String) -> some View {
        Text(message)
            .font(.system(size: 50))
            .fontWeight(.black)
            .foregroundColor(.white)
    }

    private var backgroundStreak: Text {
        takingMedicine ?
        Text("13")
            .font(.system(size: 180, weight: .black, design: .rounded))
            .foregroundColor(.white)
        :
        Text("12")
            .font(.system(size: 180, weight: .black, design: .rounded))
            .foregroundColor(.white)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            .ignoresSafeArea()
            
            VStack {
                VStack {
                    backgroundTitle
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)

                VStack {
                    ZStack {
                        // Fire effect behind the streak
                        Text("🔥")
                            .font(.system(size: 220))
                            .opacity(0.7)
                            .scaleEffect(1.5)
                            .blur(radius: 2)
                            .offset(y: -50)
                    
                        .blur(radius: 1)
                        
                        // The streak number on top
                        backgroundStreak
                            .font(.system(size: 80, weight: .black, design: .rounded))
                    }
                }
                

                Spacer()

                if !takingMedicine {
                    HStack {
                        Button {
                            takingMedicine.toggle()
                            SharedDataManager.shared.takingMedicine = takingMedicine
                            SharedDataManager.shared.lastMedicationDate = Date()
                            
                            // Reload widget timeline
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            Text("I have taken my medication")
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 100)
                }
            }
        }
        .onAppear {
            takingMedicine = SharedDataManager.shared.takingMedicine
        }
    }
}

#Preview {
    PillView()
}
