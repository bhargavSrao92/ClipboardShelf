import SwiftUI

enum ClipShelfTheme {
    static let accent = Color(red: 0.12, green: 0.58, blue: 0.95)
    static let secondaryAccent = Color(red: 0.06, green: 0.76, blue: 0.67)
    static let warmHighlight = Color(red: 1.0, green: 0.66, blue: 0.30)
    static let rose = Color(red: 0.96, green: 0.36, blue: 0.57)
    static let canvasTop = Color(uiColor: .systemBackground)
    static let canvasBottom = Color(red: 0.90, green: 0.96, blue: 1.0)
    static let darkCanvasBottom = Color(red: 0.08, green: 0.11, blue: 0.18)

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [
                canvasTop,
                Color(uiColor: .secondarySystemBackground),
                Color(uiColor: UIColor { trait in
                    trait.userInterfaceStyle == .dark
                        ? UIColor(darkCanvasBottom)
                        : UIColor(canvasBottom)
                })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ClipShelfCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12))
            )
    }
}

extension View {
    func clipShelfCard() -> some View {
        modifier(ClipShelfCardModifier())
    }
}
