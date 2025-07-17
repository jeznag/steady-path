import SwiftUI

struct HomeSmile: View {
    let size: CGFloat
    
    var body: some View {
        Path { path in
            let startX = size * 0.2
            let startY = size * 0.25
            
            let endX = size * 0.6
            let endY = size * 0.25
            
            // Define the curvature of the smile, keeping the start and end points the same
            path.move(to: CGPoint(x: startX, y: startY))
            path.addQuadCurve(to: CGPoint(x: endX, y: endY), control: CGPoint(x: size * 0.4, y: size * 0.5)) // Adjusted control point for a smoother curve
        }
        .stroke(Color.white, lineWidth: 10) // White stroke for the smile
        .frame(width: size, height: size)
    }
}
