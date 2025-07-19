import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Around Egypt")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
} 