import SwiftUI

struct PillView: View {
    var body: some View {
        VStack {
            Button(action: {
                // Add any action you want here
                print("Wow button tapped!")
            }) {
                Text("wow")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Pill View")
    }
}

#Preview {
    PillView()
}
