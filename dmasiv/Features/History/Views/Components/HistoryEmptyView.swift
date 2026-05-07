import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 40))
                .foregroundColor(.white)
            Text("Belum ada rekaman")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
