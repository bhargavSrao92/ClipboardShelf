import SwiftUI

struct AppRootView: View {
    @AppStorage("clipshelf.hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: hasSeenOnboarding)
    }
}
