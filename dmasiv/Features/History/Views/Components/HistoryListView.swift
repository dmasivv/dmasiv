import SwiftUI

struct HistoryListView: View {
    let recordings: [RecordingItem]
    let onSelect: (RecordingItem) -> Void

    var body: some View {
        List {
            ForEach(recordings) { recording in
                RecordingRow(recording: recording) {
                    onSelect(recording) // Lempar lagu yang ditekan ke tampilan utama
                }
                .cardStyleRow()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
