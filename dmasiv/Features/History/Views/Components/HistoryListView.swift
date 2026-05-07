import SwiftUI

struct HistoryListView: View {
    let recordings: [RecordingItem]
    let onSelect: (RecordingItem) -> Void

    // ── Warna persis dari SongCard ──────────────────────────────────────
    private let cardFill = Color(red: 0.12, green: 0.16, blue: 0.28)
    private let cardBorder = Color(red: 0.20, green: 0.25, blue: 0.40)

    var body: some View {
        LazyVStack(spacing: 10) {
        LazyVStack(spacing: 10) {
            ForEach(recordings) { recording in
                RecordingRow(recording: recording) {
                    onSelect(recording) // Lempar lagu yang ditekan ke tampilan utama
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}
