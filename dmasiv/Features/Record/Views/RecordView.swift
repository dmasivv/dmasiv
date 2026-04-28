import SwiftUI

// MARK: - Main View
struct RecordView: View {
    let song: Song
    @StateObject private var viewModel = RecordViewModel()
    @State private var navigateToResult = false

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
            
            // Hidden Navigation ke Page 3
            NavigationLink(destination: Text("Halaman Result"), isActive: $navigateToResult) {
                EmptyView()
            }

            VStack(spacing: 20) {
                RecordHeaderView(title: song.title, artist: song.artist)
                
                TimelineAreaView(viewModel: viewModel)
                    .padding(.horizontal)
                
                RecordLyricAreaView(lyricText: viewModel.activeLyric?.text)
                
                RecordPitchIndicatorView(pitch: viewModel.currentPitch, midiNote: viewModel.currentMidiNote)
                
                WaveformVisualizerView(viewModel: viewModel)
                    .padding(.horizontal)
                
                Spacer()
                
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

// MARK: - Extracted UI Components

struct RecordHeaderView: View {
    let title: String
    let artist: String
    
    var body: some View {
        Text("\(title) - \(artist)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.top)
    }
}

struct RecordLyricAreaView: View {
    let lyricText: String?
    
    var body: some View {
        if let text = lyricText {
            // Karena struktur LyricLine baru hanya punya 1 timestamp,
            // kita buat progress buatan untuk prototype
            KaraokeLyricView(text: text, progress: 1.0)
                .padding(.vertical, 10)
        } else {
            Text("🎵")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.1))
                .padding(.vertical, 10)
        }
    }
}

struct RecordPitchIndicatorView: View {
    let pitch: String
    let midiNote: Float
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Your Pitch")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(pitch)
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(midiNote > 0 ? .green : .gray)
        }
    }
}

struct RecordControlsView: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var navigateToResult: Bool
    
    var body: some View {
        HStack(spacing: 40) {
            // Tombol Mic/Stop
            Button(action: {
                viewModel.togglePlayAndRecord()
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.isPlaying ? Color.red : Color.blue)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: viewModel.isPlaying ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            
            // Tombol Lanjut ke Result
//            if viewModel.isRecording || viewModel.pitchHistory.count > 0 {
//                Button("Selesai") {
//                    viewModel.stopRecording()
//                    navigateToResult = true
//                }
//                .padding(.horizontal, 30)
//                .padding(.vertical, 15)
//                .background(Color.green)
//                .foregroundColor(.white)
//                .cornerRadius(25)
//                .font(.headline)
//            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Existing Sub Views (Timeline, Waveform, dll)

struct TimelineAreaView: View {
    @ObservedObject var viewModel: RecordViewModel
    let lookaheadTime: TimeInterval = 5.0
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let playheadX = width * 0.2
            let pixelsPerSecond = (width - playheadX) / CGFloat(lookaheadTime)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.05))
                
                VStack {
                    GridLineView(label: "C6"); Spacer()
                    GridLineView(label: "C5"); Spacer()
                    GridLineView(label: "C4"); Spacer()
                    GridLineView(label: "C3")
                }
                .padding(.vertical, 30).padding(.horizontal, 10)

                ForEach(viewModel.allNotes) { note in
                    let startX = playheadX + CGFloat(note.start - viewModel.currentTime) * pixelsPerSecond
                    let noteWidth = CGFloat(note.duration) * pixelsPerSecond
                    let endX = startX + noteWidth
                    
                    if endX > 0 && startX < width {
                        let isActive = viewModel.currentTime >= note.start && viewModel.currentTime <= (note.start + note.duration)
                        Capsule()
                            .fill(isActive ? Color.blue.opacity(0.8) : Color.gray.opacity(0.4))
                            .frame(width: max(noteWidth, 10), height: 14)
                            .position(x: startX + (noteWidth / 2), y: calculateY(for: Float(note.number), in: height))
                    }
                }
                
                ForEach(viewModel.pitchHistory) { point in
                    let xOffset = CGFloat(point.time - viewModel.recordingDuration) * pixelsPerSecond
                    let pointX = playheadX + xOffset
                    
                    if pointX > 0 {
                        Circle()
                            .fill(Color.yellow.opacity(0.8))
                            .frame(width: 6, height: 6)
                            .position(x: pointX, y: calculateY(for: point.midiNote, in: height))
                    }
                }
                
                Rectangle().fill(Color.red.opacity(0.8)).frame(width: 2, height: height).position(x: playheadX, y: height / 2)
                
                if viewModel.currentMidiNote > 0 {
                    Circle()
                        .fill(Color.green).frame(width: 20, height: 20)
                        .position(x: playheadX, y: calculateY(for: viewModel.currentMidiNote, in: height))
                        .shadow(color: .green.opacity(0.8), radius: 8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .frame(height: 300)
    }
    
    private func calculateY(for noteNumber: Float, in height: CGFloat) -> CGFloat {
        let minNote: Float = 48
        let maxNote: Float = 84
        let clamped = max(minNote, min(maxNote, noteNumber))
        let normalized = (clamped - minNote) / (maxNote - minNote)
        let padding: CGFloat = 30
        let usableHeight = height - (padding * 2)
        return padding + (usableHeight * (1.0 - CGFloat(normalized)))
    }
}

struct GridLineView: View {
    let label: String
    var body: some View {
        HStack(spacing: 5) {
            Text(label).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.white.opacity(0.3))
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
        }
    }
}

struct WaveformVisualizerView: View {
    @ObservedObject var viewModel: RecordViewModel
    var body: some View {
        HStack(spacing: 4.0) {
            ForEach(0..<viewModel.audioLevels.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2.0)
                    .fill(viewModel.isRecording ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 6.0, height: max(10.0, viewModel.audioLevels[index] * 80.0))
                    .animation(.easeInOut(duration: 0.1), value: viewModel.audioLevels[index])
            }
        }
        .frame(height: 80.0)
    }
}

struct KaraokeLyricView: View {
    let text: String
    let progress: CGFloat
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundColor(.white.opacity(0.3))
            Text(text).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundColor(.purple)
                .mask(
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle().frame(width: geo.size.width * progress)
                            Spacer(minLength: 0)
                        }
                    }
                )
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

// Preview
#Preview {
    RecordView(song: .Januari)
}
