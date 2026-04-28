import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void
    @State private var selection = 0

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $selection) {
                onboardingPage(
                    title: "Capture ideas without friction",
                    subtitle: "Save copied text and images into a clean, searchable shelf built for iPhone.",
                    symbol: "sparkles.rectangle.stack.fill",
                    colors: [ClipShelfTheme.accent, ClipShelfTheme.secondaryAccent]
                )
                .tag(0)

                onboardingPage(
                    title: "Paste with Apple’s system control",
                    subtitle: "Use the native paste action to reduce repeated permission prompts and stay aligned with iOS privacy expectations.",
                    symbol: "hand.tap.fill",
                    colors: [ClipShelfTheme.warmHighlight, ClipShelfTheme.rose]
                )
                .tag(1)

                onboardingPage(
                    title: "Pin what matters most",
                    subtitle: "Create a lightweight personal clipboard archive with favorites, images, and fast copy-back actions.",
                    symbol: "pin.circle.fill",
                    colors: [ClipShelfTheme.secondaryAccent, ClipShelfTheme.accent]
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(selection == 2 ? "Start Organizing" : "Next") {
                if selection < 2 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                        selection += 1
                    }
                } else {
                    onContinue()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(ClipShelfTheme.accent)
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
        .background(ClipShelfTheme.appBackground.ignoresSafeArea())
    }

    private func onboardingPage(title: String, subtitle: String, symbol: String, colors: [Color]) -> some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 220, height: 220)
                    .shadow(color: colors.last?.opacity(0.35) ?? .clear, radius: 30, y: 20)

                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
