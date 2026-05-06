import SwiftUI

// MARK: - Legend Row

private enum LegendType { case singing, breathing }

private struct OnboardingLegendRow: View {
    let type: LegendType

    var body: some View {
        HStack(spacing: 14) {
            // Capsule swatch
            switch type {
            case .singing:
                TimelineCapsule(style: .sing, width: 40, height: 16)
            case .breathing:
                TimelineCapsule(style: .breathe, width: 40, height: 16)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(type == .singing ? "Sing" : "Breathe")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.lyricActive)
                Text(type == .singing
                     ? "Sing along with the lyrics"
                     : "Inhale or exhale here")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.lyricSubtitle)
            }
            Spacer()
        }
    }
}

// MARK: - Mini Timeline

private struct OnboardingMiniTimeline: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
            )
            .frame(height: 36)
            .overlay(
                HStack(spacing: 6) {
                    TimelineCapsule(style: .sing, width: 60, height: 14)
                    TimelineCapsule(style: .breathe, width: 36, height: 14)
                    TimelineCapsule(style: .sing, width: 48, height: 14)
                }
            )
    }
}

// MARK: - Onboarding Card

struct TimelineOnboardingView: View {
    let onDismiss: () -> Void
    let onNeverShow: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            OnboardingMiniTimeline()

            VStack(spacing: 14) {
                OnboardingLegendRow(type: .singing)
                OnboardingLegendRow(type: .breathing)
            }

            Button("Don't show it again") {
                onNeverShow()
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(AppColors.labelDim)
            .frame(minHeight: 44)
        }
        .padding(24)
        .overlay(alignment: .topTrailing) {
            Button { onDismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.lyricSubtitle)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(AppColors.overlayMedium))
            }
            .padding(.top, 12)
            .padding(.trailing, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.lyricActive.opacity(0.5),
                                    AppColors.lyricActive.opacity(0.05),
                                    AppColors.lyricActive.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 16)
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TimelineOnboardingView(
            onDismiss: {},
            onNeverShow: {}
        )
        .padding(.horizontal, 28)
    }
}
