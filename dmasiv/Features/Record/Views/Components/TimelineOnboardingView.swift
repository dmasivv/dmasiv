import SwiftUI

// ============================================================
// MARK: - Timeline Onboarding Overlay
// ============================================================

/// Overlay info yang menjelaskan arti warna di Breath Timeline.
/// Tampil sekali saat pertama kali user membuka halaman Record.
/// Jika user tekan "Don't show it again", disimpan ke UserDefaults
/// agar tidak pernah tampil lagi.
struct TimelineOnboardingView: View {
    var onDismiss: () -> Void
    var onNeverShow: () -> Void

    // Warna konsisten dengan BreathTimelineView
    private let cardBg    = Color(red: 0.08, green: 0.10, blue: 0.20)
    private let cardBorder = Color(red: 0.18, green: 0.22, blue: 0.36)
    private let singColor  = Color.white.opacity(0.15) // abu-abu transparan
    private let breathColor = Color(red: 0.22, green: 0.41, blue: 0.85) // biru

    var body: some View {
        VStack(spacing: 0) {
            // ── Header: Judul + Close ──────────────────────────────
            HStack {
                Spacer()
                Text("Taiko Indicator")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // ── Mini Preview Timeline ──────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .frame(height: 40)

                HStack(spacing: 6) {
                    // Kapsul Sing (abu-abu transparan)
                    Capsule()
                        .fill(singColor)
                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .frame(width: 80, height: 18)

                    // Kapsul Breathe (biru)
                    Capsule()
                        .fill(breathColor)
                        .frame(width: 36, height: 18)

                    // Kapsul Sing (abu-abu transparan)
                    Capsule()
                        .fill(singColor)
                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .frame(width: 60, height: 18)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // ── Legend Items ───────────────────────────────────────
            VStack(spacing: 16) {
                // Sing
                HStack(spacing: 14) {
                    Capsule()
                        .fill(singColor)
                        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .frame(width: 48, height: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sing")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Sing along with the lyrics")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()
                }

                // Breathe
                HStack(spacing: 14) {
                    Capsule()
                        .fill(breathColor)
                        .frame(width: 48, height: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Breathe")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Inhale or exhale here")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // ── Don't show it again ───────────────────────────────
            Button(action: onNeverShow) {
                Text("Don't show it again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(.bottom, 20)
        }
        .background(
            ZStack {
                // Fill utama
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardBg)

                // Border luar: biru-abu lembut
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),  // cahaya atas
                                Color(red: 0.18, green: 0.22, blue: 0.38).opacity(0.6), // sisi
                                Color(red: 0.12, green: 0.15, blue: 0.28).opacity(0.3)  // bawah redup
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )

                // Inner glow halus di atas
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.06), lineWidth: 4)
                    .blur(radius: 3)
                    .mask(RoundedRectangle(cornerRadius: 24))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
