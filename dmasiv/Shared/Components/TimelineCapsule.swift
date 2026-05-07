import SwiftUI

// MARK: - Timeline Capsule Styles

enum TimelineCapsuleStyle {
    /// Glass style — used for lyric/sing markers
    case sing
    /// Solid fill — used for breath markers
    case breathe
}

/// Single source of truth for timeline capsule appearance.
/// Use this in both `BreathTimelineView` and `TimelineOnboardingView`
/// so a style change propagates everywhere automatically.
struct TimelineCapsule: View {
    let style: TimelineCapsuleStyle
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        switch style {
        case .sing:
            Capsule()
                .fill(AppColors.timelineSing)
                .frame(width: width, height: height)
        case .breathe:
            Capsule()
                .fill(AppColors.timelineBreath)
                .background(Capsule().fill(.ultraThinMaterial))
                .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                .frame(width: width, height: height)
        }
    }
}
