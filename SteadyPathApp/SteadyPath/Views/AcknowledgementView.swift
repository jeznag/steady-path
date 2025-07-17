import SwiftUI

struct AcknowledgementView: View {
    @State private var acceptedTerms = false
    @State private var shareResponses = false
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            if showConfirmation {
                ConfirmationView()
            } else {
                VStack(spacing: 30) {
                    Text("Please Review and Confirm")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 40)

                    Button(action: {
                        acceptedTerms.toggle()
                    }) {
                        HStack {
                            Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(acceptedTerms ? .blue : .secondary)
                                .font(.title2)
                            Text("I accept the Terms and Conditions")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    Button(action: {
                        shareResponses.toggle()
                    }) {
                        HStack {
                            Image(systemName: shareResponses ? "checkmark.square.fill" : "square")
                                .foregroundColor(shareResponses ? .blue : .secondary)
                                .font(.title2)
                            Text("I agree to share my responses")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    Spacer()

                    Button("Confirm") {
                        withAnimation {
                            showConfirmation = true
                        }
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    AcknowledgementView()
}
