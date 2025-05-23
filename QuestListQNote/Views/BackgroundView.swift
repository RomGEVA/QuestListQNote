import SwiftUI

struct BackgroundView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            switch themeManager.currentTheme {
            case .system, .light:
                LinearGradient(
                    colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                
            case .dark:
                LinearGradient(
                    colors: [Color(.systemIndigo).opacity(0.3), Color(.systemPurple).opacity(0.2)],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                
            case .colorful:
                LinearGradient(
                    colors: [
                        .purple.opacity(0.3),
                        .pink.opacity(0.2),
                        .orange.opacity(0.2),
                        .yellow.opacity(0.2)
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    BackgroundView()
} 