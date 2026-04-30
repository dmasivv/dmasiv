import SwiftUI

// MARK: - Main View
/// The primary recording screen.
/// Assembles header, lyrics, waveform visualizer, and playback controls.
/// All sub-views live in `RecordView-UIComponents.swift`.
struct RecordView: View {
    let song: Song
    @StateObject private var viewModel = RecordViewModel()
    @State private var navigateToResult = false

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.10, green: 0.08, blue: 0.15).ignoresSafeArea()
            
            // Hidden Navigation ke Page 3
            NavigationLink(destination: Text("Halaman Result"), isActive: $navigateToResult) {
                EmptyView()
            }

            VStack(spacing: 20) {
                // Nama Lagu dan Artis
                SongTitleAndArtist(title: song.title, artist: song.artist)
                
                // Imitasi Smule
                TimelineAreaView(viewModel: viewModel)
                    .padding(.horizontal)
                
                // Lirik Musik
                RefinedLyricAndBreathingNotation(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Track User Pitch
                //RecordPitchIndicatorView(pitch: viewModel.currentPitch, midiNote: viewModel.currentMidiNote)
                
                WaveformVisualizerView(viewModel: viewModel)
                    .padding(.horizontal)
                                
                RecordControlsView(viewModel: viewModel, navigateToResult: $navigateToResult)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Mencegah Preview (Canvas) minta izin Mic yang bisa bikin Crash
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                viewModel.requestMicrophonePermission()
            }
            viewModel.loadSong(song)
        }
    }
}

// MARK: - Preview
#Preview {
    RecordView(song: .Januari)
}
