//
//  LoginView.swift
//  AFP-Ripple
//
//  Created by Mira on 25/2/2025.
//

import SwiftUI

struct LoginView: View {
    @State private var userName = ""
    @State private var password = ""
    @State private var loginMessage = ""
    
    var body: some View {
        
      
        
        ZStack {
            
            Color.blue
                .ignoresSafeArea()
            
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
                    .multilineTextAlignment(.center)
                    .frame(width: 250)
                Spacer()
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 250)
                    .foregroundStyle(LinearGradient(colors: [.yellow, .white], startPoint: .top, endPoint: .bottom))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 300, height: 175)
                    .cornerRadius(20)
                    .overlay {
                        VStack (spacing: 0) {
                            
                            TextField ("Username", text: $userName)
                                .foregroundColor(.white)
                                .background(Color(.white))
                                .cornerRadius(5)
                                .padding(.horizontal, 20)
                                .bold()
                            
                            SecureField ("Password", text:$password)
                                .textContentType(.password)
                                .background(Color(.white))
                                .cornerRadius(5)
                                .padding(20)
                                .bold()
                            
                            Button(action: {
                                loginMessage = "Login Successful"
                            }) {
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                        }
                    }
                Spacer()
            }
        }
    }
    
}
#Preview {
    LoginView()
}
