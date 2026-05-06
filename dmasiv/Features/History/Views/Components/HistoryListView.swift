import SwiftUI

struct HistoryListView: View {
    let recordings: [RecordingItem]
    let onSelect: (RecordingItem) -> Void

    var body: some View {
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
