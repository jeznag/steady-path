import SwiftUI


struct ConfirmationView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding()
            Text("All Set!")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
        .transition(.opacity)
        .animation(.easeInOut, value: UUID()) // triggers transition animation
    }
}
