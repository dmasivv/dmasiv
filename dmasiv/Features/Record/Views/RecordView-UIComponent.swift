import SwiftUI

// ============================================================
// MARK: - Header & Song Info
// ============================================================

/// Displays the song title and artist name in a header layout.
/// Used at the top of RecordView.
//struct RecordHeaderView: View {
//    let title: String
//    let artist: String
//    
//    var body: some View {
//        Text("\(title) - \(artist)")
//            .font(.system(size: 24, weight: .bold, design: .rounded))
//            .foregroundColor(.white)
//            .padding(.top)
//    }
//}

/// A hardcoded song title/artist header (placeholder for dynamic data).
/// TODO: Replace hardcoded values with dynamic `Song` properties.
struct SongTitleAndArtist: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Januari")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Glenn Fredly")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

// ============================================================
// MARK: - Playback Controls
// ============================================================

/// Bottom control bar with play/stop (mic) toggle button.
/// Also holds the (currently commented-out) "Selesai" navigation button.
struct RecordControlsView: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var navigateToResult: Bool
    
    var body: some View {
        HStack(spacing: 40) {
            // Play / Stop toggle
            Button(action: {
                viewModel.togglePlayAndRecord()
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.isPlaying ? Color.white : Color.white)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: viewModel.isPlaying ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            
            // "Selesai" (Done) button — navigate to Result page
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

// ============================================================
// MARK: - Timeline / Pitch Visualization
// ============================================================

/// The scrolling MIDI-note timeline showing reference notes, recorded pitch dots,
/// a red playhead line, and the live pitch indicator.
struct TimelineAreaView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    /// How far ahead (in seconds) the timeline shows upcoming notes.
    let lookaheadTime: TimeInterval = 5.0
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let playheadX = width * 0.2                                       // Playhead sits at 20% from left
            let pixelsPerSecond = (width - playheadX) / CGFloat(lookaheadTime) // Scale factor
            
            ZStack(alignment: .topLeading) {
                // -- Background --
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
                
                // -- Horizontal grid lines (C3–C6) --
                VStack {
                    GridLineView(label: "C6"); Spacer()
                    GridLineView(label: "C5"); Spacer()
                    GridLineView(label: "C4"); Spacer()
                    GridLineView(label: "C3")
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 10)

                // -- Reference MIDI notes (capsules) --
                ForEach(viewModel.allNotes) { note in
                    let startX = playheadX + CGFloat(note.start - viewModel.currentTime) * pixelsPerSecond
                    let noteWidth = CGFloat(note.duration) * pixelsPerSecond
                    let endX = startX + noteWidth
                    
                    if endX > 0 && startX < width {
                        let isActive = viewModel.currentTime >= note.start
                            && viewModel.currentTime <= (note.start + note.duration)
                        
                        Capsule()
                            .fill(isActive ? Color.blue.opacity(0.8) : Color.gray.opacity(0.4))
                            .frame(width: max(noteWidth, 10), height: 14)
                            .position(
                                x: startX + (noteWidth / 2),
                                y: calculateY(for: Float(note.number), in: height)
                            )
                    }
                }
                
                // -- Recorded pitch history (yellow dots) --
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
                
                // -- Red playhead line --
                Rectangle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 2, height: height)
                    .position(x: playheadX, y: height / 2)
                
                // -- Live pitch indicator (green dot) --
                if viewModel.currentMidiNote > 0 {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 20, height: 20)
                        .position(x: playheadX, y: calculateY(for: viewModel.currentMidiNote, in: height))
                        .shadow(color: .green.opacity(0.8), radius: 8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .frame(height: 300)
    }
    
    // MARK: Helpers
    
    /// Maps a MIDI note number (48–84 ≈ C3–C6) to a vertical Y position.
    private func calculateY(for noteNumber: Float, in height: CGFloat) -> CGFloat {
        let minNote: Float = 48  // C3
        let maxNote: Float = 84  // C6
        let clamped = max(minNote, min(maxNote, noteNumber))
        let normalized = (clamped - minNote) / (maxNote - minNote)
        let padding: CGFloat = 30
        let usableHeight = height - (padding * 2)
        return padding + (usableHeight * (1.0 - CGFloat(normalized)))
    }
}

/// A single horizontal grid line with a note label (e.g. "C4").
struct GridLineView: View {
    let label: String
    
    var body: some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
    }
}

// ============================================================
// MARK: - Pitch Indicator
// ============================================================

/// Shows the user's currently detected pitch as a large text label.
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

// ============================================================
// MARK: - Waveform Visualizer
// ============================================================

/// A live audio-level visualizer rendered as vertical bars.
/// Bars animate with a spring effect; silent segments collapse to dots.
struct WaveformVisualizerView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    var body: some View {
        HStack(spacing: 4.0) {
            ForEach(0..<viewModel.audioLevels.count, id: \.self) { index in
                let level = viewModel.audioLevels[index]
                
                // Silence threshold — below 0.3 is treated as quiet
                let isSilent = level < 0.3
                
                // Silent bars shrink to 1pt; voiced bars scale up to ~80pt
                let barHeight: CGFloat = isSilent ? 1.0 : max(1.5, level * 80.0)
                
                RoundedRectangle(cornerRadius: 2.0)
                    .fill(viewModel.isRecording ? Color.white : Color.gray.opacity(0.3))
                    .frame(width: 2.0, height: barHeight)
                    .animation(.spring(response: 0.15, dampingFraction: 0.7), value: barHeight)
            }
        }
        .frame(height: 80.0)
    }
}

// ============================================================
// MARK: - Karaoke Lyric Sweep
// ============================================================

/// A single line of karaoke text with a left-to-right color-reveal animation.
/// The `progress` value (0…1) controls how much of the text is highlighted.
struct KaraokeLyricView: View {
    let text: String
    let progress: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Dim base text (unsung portion)
            Text(text)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
            
            // Highlighted overlay (sung portion), masked by progress
            Text(text)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.purple)
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

/// Displays a lyric line or a placeholder emoji when no lyric is active.
struct RecordLyricAreaView: View {
    let lyricText: String?
    let progress: CGFloat
    
    var body: some View {
        if let text = lyricText {
            KaraokeLyricView(text: text, progress: progress)
                .padding(.vertical, 10)
        } else {
            Text("🎵")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.1))
                .padding(.vertical, 10)
        }
    }
}

// ============================================================
// MARK: - Breathing Tracing Line
// ============================================================

/// An animated capsule that fills from left to right during a "BREATHE" interval.
/// Provides a visual cue for the singer to take a breath between lines.
struct BreathingTracingLineView: View {
    let progress: CGFloat
    let isActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 5)
                
                // Animated fill (only when this interval is the current one)
                if isActive {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.9), Color.white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * progress), height: 5)
                        .shadow(color: .white.opacity(0.6), radius: 8, x: 0, y: 0)
                }
            }
        }
        .frame(height: 5)
        .animation(.linear(duration: 0.05), value: progress)
    }
}

// ============================================================
// MARK: - Refined Lyric & Breathing Notation
// ============================================================

/// A 5-line sliding-window lyric display.
///
/// The **current** lyric appears at the top with a large font (40pt),
/// while up to 4 **upcoming** lines are shown below in a smaller font (24pt).
/// - `BREATHE` lines render as an animated tracing capsule.
/// - Empty / instrumental lines render as three small dots.
/// - The layout height is fixed so the UI doesn't jump when fewer lines are visible.
struct RefinedLyricAndBreathingNotation: View {
    @ObservedObject var viewModel: RecordViewModel
    
    /// Maximum number of lyric lines shown at once.
    private let maxVisibleLines = 5
    
    // MARK: Computed Properties
    
    /// Returns the slice of lyrics to display: current line + up to 4 upcoming lines.
    private var visibleLyrics: [(index: Int, lyric: LyricLine)] {
        guard let currentIdx = viewModel.currentLyricIndex else {
            // Before playback starts, show the first few lines as a preview
            let end = min(maxVisibleLines, viewModel.allLyrics.count)
            guard end > 0 else { return [] }
            return (0..<end).map { (index: $0, lyric: viewModel.allLyrics[$0]) }
        }
        let start = currentIdx
        let end = min(start + maxVisibleLines, viewModel.allLyrics.count)
        return (start..<end).map { (index: $0, lyric: viewModel.allLyrics[$0]) }
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ForEach(Array(visibleLyrics.enumerated()), id: \.element.lyric.id) { position, item in
                let isCurrent = (position == 0 && viewModel.currentLyricIndex != nil)
                let progress = progressFor(index: item.index)
                
                lyricRow(for: item.lyric, isCurrent: isCurrent, progress: progress)
            }
            
            // Pad remaining slots so the layout height stays stable
            if visibleLyrics.count < maxVisibleLines {
                ForEach(0..<(maxVisibleLines - visibleLyrics.count), id: \.self) { _ in
                    Text(" ")
                        .font(.system(size: 16))
                        .foregroundColor(.clear)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 170)
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentLyricIndex)
    }
    
    // MARK: Row Builder
    
    /// Builds the appropriate view for a single lyric row based on its type.
    @ViewBuilder
    private func lyricRow(for lyric: LyricLine, isCurrent: Bool, progress: CGFloat) -> some View {
        let transition: AnyTransition = .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
        
        if lyric.isBreathe {
            // — Breathing indicator (animated tracing capsule) —
            breatheRow(isCurrent: isCurrent, progress: progress)
                .transition(transition)
            
        } else if lyric.text.isEmpty {
            // — Instrumental break (three dots) —
            instrumentalBreakRow(isCurrent: isCurrent)
                .transition(transition)
            
        } else {
            // — Regular lyric text —
            regularLyricRow(text: lyric.text, isCurrent: isCurrent)
                .transition(transition)
        }
    }
    
    // MARK: Row Variants
    
    /// A breathing-interval row: small tracing line that fills over time.
    private func breatheRow(isCurrent: Bool, progress: CGFloat) -> some View {
        HStack(spacing: 10) {
            BreathingTracingLineView(
                progress: progress,
                isActive: isCurrent
            )
            .frame(maxWidth: isCurrent ? 200 : 140)
        }
        .padding(.vertical, isCurrent ? 4 : 2)
    }
    
    /// An instrumental-break row: three small dots.
    private func instrumentalBreakRow(isCurrent: Bool) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { _ in
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.vertical, isCurrent ? 6 : 2)
    }
    
    /// A regular lyric-text row. The current line is larger and fully white.
    private func regularLyricRow(text: String, isCurrent: Bool) -> some View {
        Text(text)
            .font(.system(
                size: isCurrent ? 40 : 24,
                weight: .bold,
                design: .rounded
            ))
            .foregroundColor(isCurrent ? .white : .white.opacity(0.4))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
    
    // MARK: Helpers
    
    /// Calculates the sweep progress (0.0 → 1.0) for a lyric at the given index.
    private func progressFor(index: Int) -> CGFloat {
        let lyric = viewModel.allLyrics[index]
        let duration = lyric.endTime - lyric.startTime
        guard duration > 0 else { return 1.0 }
        let progress = (viewModel.currentTime - lyric.startTime) / duration
        return CGFloat(min(max(progress, 0), 1))
    }
}
