import SwiftUI

struct RecordView: View {
    let song: Song
    @StateObject private var viewModel = RecordViewModel()
    @State private var navigateToResult = false

    var body: some View {
        NavigationLink(destination: ResultView(song: song), isActive: $navigateToResult) {
            EmptyView()
        }

        VStack(spacing: 24) {
            Text("Record Singing")
                .font(.largeTitle)

            Text("\(song.title) — \(song.artist)")
                .font(.headline)

            Text("Karaoke lyrics and recording controls will appear here")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Stop Recording") {
                viewModel.stopRecording()
                navigateToResult = true
            }
            .padding()
            .background(AppColors.accent)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Record")
    }
}
