import SwiftUI

struct CardStyleRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            )
    }
}

extension View {
    func cardStyleRow() -> some View {
        self.modifier(CardStyleRowModifier())
    }
}
