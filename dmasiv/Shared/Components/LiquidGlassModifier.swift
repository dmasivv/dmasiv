import SwiftUI

// ============================================================
// MARK: - Liquid Glass Box Modifier
// ============================================================

struct LiquidGlassBoxModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            // 1. Efek Kaca Transparan
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(0.07)
            )
            // 2. Highlight / Pinggiran bercahaya
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.lyricActive.opacity(0.5), AppColors.lyricActive.opacity(0.05), AppColors.lyricActive.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
            )
            // 3. Shadow lembut di bawah box
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
    }
}

extension View {
    /// Memberikan efek Liquid Glass (kaca buram dengan highlight gradient)
    func liquidGlassBox(cornerRadius: CGFloat = 22) -> some View {
        self.modifier(LiquidGlassBoxModifier(cornerRadius: cornerRadius))
    }
}
