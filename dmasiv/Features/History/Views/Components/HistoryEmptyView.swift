import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Belum ada rekaman")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
