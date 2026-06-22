import SwiftUI

struct AuraBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.28), .indigo.opacity(0.18), .black.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle()
                .fill(.purple.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -130, y: -260)
            Circle()
                .fill(.blue.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 70)
                .offset(x: 150, y: 220)
        }
    }
}
