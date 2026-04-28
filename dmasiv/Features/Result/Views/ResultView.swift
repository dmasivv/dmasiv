import SwiftUI

struct ResultView: View {
    let song: Song
    @StateObject private var viewModel = ResultViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("Result")
                .font(.largeTitle)

            Text(song.title)
                .font(.headline)

            Text("Result page — score and feedback will appear here")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Result")
    }
}
