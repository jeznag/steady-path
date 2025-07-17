import SwiftUI

struct HomeView: View {
    @State private var opacity: Double = 0  // Controls fade in
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .opacity(0.8)
                    .foregroundColor(Color.white)
                    .ignoresSafeArea()
                
                // Arm Rectangle
                Rectangle()
                    .foregroundColor(Color(red: 244/255, green: 182/255, blue: 227/255))  // nurse pink
                    .frame(width: 50, height: 380)
                    .position(x: 368, y: 550)
                    .rotationEffect(.degrees(-15))
                    .rotation3DEffect(.degrees(360), axis: (x: 0, y: 1, z: 0))
                
                // Head Circle
                Circle()
                    .foregroundColor(Color(red: 244/255, green: 182/255, blue: 227/255))  // nurse pink
                    .frame(width: 580, height: 580)
                    .position(x: 80, y: 400)
                    .shadow(radius: 20)
                    .padding()
                    .rotation3DEffect(.degrees(360), axis: (x: 0, y: 1, z: 0))
                
                // Left eye with pupil
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .position(x: 160, y: 250)
                
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 16, height: 20)
                    .position(x: 160, y: 250)
                
                // Right eye with pupil
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .position(x: 200, y: 260)
                
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 16, height: 16)
                    .position(x: 200, y: 260)
                
                // Smile
                HomeSmile(size: 130)
                    .padding(.bottom, -150)
                    .offset(x: -110, y: -220)
                    .rotationEffect(.degrees(25))
                    .padding(.top, 150)
                
                // Speech bubble
                VStack(spacing: 0) {
                    Text("Welcome \(dataModel.userName)")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 54)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                                )
                                .shadow(radius: 4)
                        )
                        .offset(y: -83)

                    
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 24, height: 12)
                        .rotationEffect(.degrees(0))
                        .offset(y: -167)
                }
                .position(x: UIScreen.main.bounds.midX, y: 470)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    opacity = 1.0
                }
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))   // bottom left
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY)) // top middle
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom right
            path.closeSubpath()
        }
    }
}

#Preview {
    HomeView()
}
