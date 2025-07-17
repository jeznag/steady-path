import SwiftUI
import Lottie

struct ContentView: View {
    var onNext: () -> Void
    @State private var isTransitioning = false
    @State private var userName: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Title and Subtitle
            VStack(spacing: 4) {
                Text("Welcome to SteadyPath")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Your virtual path assistant")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            // Lottie Animation
            LottieView(animation: .named("nurse"))
                .looping()
                .frame(height: 300)
            

            TextField("Enter your name", text: $userName)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
            // Next Button
            Button(action: {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isTransitioning = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onNext()
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .disabled(isTransitioning)
        }
        .opacity(isTransitioning ? 0 : 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onChange(of: userName) { oldValue, newValue in
            dataModel.userName = newValue
        }
    }
}

#Preview {
    ContentView {
        print("Debug")
    }
}
