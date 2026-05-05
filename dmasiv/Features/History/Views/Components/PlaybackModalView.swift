import SwiftUI
import AVFoundation

struct PlaybackModalView: View {
    let recording: RecordingItem
    @ObservedObject var manager: AudioPlaybackManager
    let onDelete: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Info Lagu
                VStack(spacing: 8) {
                    Text(recording.name)
                        .font(.title2.bold())
                        .lineLimit(1)
                    Text(recording.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)

                // Slider Timeline
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { manager.currentTime },
                            set: { newValue in manager.seek(to: newValue) }
                        ),
                        in: 0...max(manager.duration, 0.01)
                    )
                    .tint(.blue)

                    HStack {
                        Text(formatTime(manager.currentTime))
                        Spacer()
                        Text("-" + formatTime(manager.duration - manager.currentTime))
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)

                // Kontrol Playback (Prev 10s, Play/Pause, Next 10s)
                HStack(spacing: 40) {
                    Button(action: { manager.skipBackward() }) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 28))
                    }

                    Button(action: { manager.togglePlayPause() }) {
                        Image(systemName: manager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 64))
                    }

                    Button(action: { manager.skipForward() }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 28))
                    }
                }
                .foregroundColor(.blue)

                Spacer()
            }
            .onAppear { manager.load(url: recording.url) }
            .onDisappear { manager.stop() }

            // Toolbar Atas Modal
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Tutup") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
