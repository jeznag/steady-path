import SwiftUI
import Lottie


struct ContentView: View {
    var body: some View {
        VStack {
            LottieView(animation: .named("nurse"))
                .looping()
        }
    }
}

// Usage with controls
struct ControlledAnimationView: View {
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            Button(isPlaying ? "Pause" : "Play") {
                isPlaying.toggle()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
