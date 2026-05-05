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

struct SongTitleAndArtist: View {
    let title: String
    let artist: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.lyricActive)
                Text(artist)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.lyricActive.opacity(0.6))
            }
            
            Spacer()
            
            NavigationLink(destination: HistoryView()) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.lyricActive)
                    .padding(10)
                    .background(AppColors.overlayMedium)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

// ============================================================
// MARK: - Playback Controls
// ============================================================

/// Bottom control bar with play/stop (mic) toggle button.
/// Also holds the "Selesai" navigation button which saves the vocal recording.
struct RecordControlsView: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var navigateToResult: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Recording saved confirmation toast
            if viewModel.showSavedConfirmation, let url = viewModel.savedRecordingURL {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.stateSuccess)
                    Text("Rekaman disimpan!")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.lyricActive)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.overlayLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.stateSuccessSoft, lineWidth: 1)
                        )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            HStack(spacing: 40) {
                // Play / Stop toggle
                Button(action: {
                    viewModel.togglePlayAndRecord()
                }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.lyricActive)
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: viewModel.isPlaying ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                
                // "Selesai" (Done) button — stops recording, saves file, navigates to Result
                if viewModel.isRecording || viewModel.pitchHistory.count > 0 {
                    Button("Selesai") {
                        viewModel.stopRecording()
                        navigateToResult = false
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(AppColors.stateSuccess)
                    .foregroundColor(AppColors.lyricActive)
                    .cornerRadius(25)
                    .font(.headline)
                }
            }
        }
        .padding(.bottom, 30)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showSavedConfirmation)
    }
}

// ============================================================
// MARK: - Timeline / Pitch Visualization
// ============================================================

/// The scrolling MIDI-note timeline showing reference notes, recorded pitch dots,
/// a red playhead line, and the live pitch indicator.
struct TimelineAreaView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    // How far ahead (in seconds) the timeline shows upcoming notes.
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
                    .fill(AppColors.overlaySubtle)
                
                // -- Horizontal grid lines (C3–C6) --
                VStack {
                    GridLineView(label: "C6"); Spacer()
                    GridLineView(label: "C5"); Spacer()
                    GridLineView(label: "C4"); Spacer()
                    GridLineView(label: "C3")
                }
//                .padding(.vertical, 10)
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
                            .fill(isActive ? AppColors.noteActive : AppColors.noteInactive)
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
                            .fill(AppColors.pitchHistory)
                            .frame(width: 6, height: 6)
                            .position(x: pointX, y: calculateY(for: point.midiNote, in: height))
                    }
                }
                
                // -- Red playhead line --
                Rectangle()
                    .fill(AppColors.stateDanger)
                    .frame(width: 2, height: height)
                    .position(x: playheadX, y: height / 2)
                
                // -- Live pitch indicator (green dot) --
                if viewModel.currentMidiNote > 0 {
                    Circle()
                        .fill(AppColors.stateSuccess)
                        .frame(width: 20, height: 20)
                        .position(x: playheadX, y: calculateY(for: viewModel.currentMidiNote, in: height))
                        .shadow(color: AppColors.stateSuccess.opacity(0.8), radius: 8)
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
                .foregroundColor(AppColors.lyricActive.opacity(0.3))
            Rectangle()
                .fill(AppColors.overlayLight)
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
                .foregroundColor(midiNote > 0 ? AppColors.stateSuccess : AppColors.pitchNone)
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
                    .fill(viewModel.isRecording ? AppColors.lyricActive : AppColors.pitchNone.opacity(0.3))
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
                .foregroundColor(AppColors.lyricActive.opacity(0.3))

            // Highlighted overlay (sung portion), masked by progress
            Text(text)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.lyricSweep)
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
                .foregroundColor(AppColors.overlayLight)
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
                    .fill(AppColors.lyricActive.opacity(0.12))
                    .frame(height: 5)

                // Animated fill (only when this interval is the current one)
                if isActive {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.lyricActive.opacity(0.9), AppColors.lyricActive],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * progress), height: 5)
                        .shadow(color: AppColors.lyricActive.opacity(0.6), radius: 8, x: 0, y: 0)
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
                    .fill(AppColors.overlayMedium)
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
            .foregroundColor(isCurrent ? AppColors.lyricActive : AppColors.lyricInactive)
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

// ============================================================
// MARK: - V2 Header with Album Art
// ============================================================

/// Header: album art (kiri) + judul & artis (kanan).
/// HIG: minimum 44pt tap target, SF Rounded for consistency, 20pt edge insets.
struct RecordHeaderViewV2: View {
    let song: Song

    var body: some View {
        HStack(spacing: 16) {
            // Album art atau placeholder — 100×100 (HIG: prominent media)
            Group {
                if let imageName = song.coverImageName,
                   let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.albumArtTop,
                                             AppColors.albumArtBottom],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: "music.note")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppColors.lyricActive.opacity(0.8))
                    }
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 5) {
                Text(song.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.lyricActive)
                Text(song.artist)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.lyricSubtitle)
            }
            Spacer()
        }
        .padding(.horizontal, 35)  // HIG: consistent 30pt edge inset
        .padding(.top, 15)
    }
}

// ============================================================
// MARK: - V2 Lyric Card
// ============================================================

/// Glass card yang menampilkan lirik: 3 baris lalu + aktif + 4 upcoming.
struct LyricCardViewV2: View {
    @ObservedObject var viewModel: RecordViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Ruang kosong atas agar lirik pertama bisa ke tengah
                    Color.clear.frame(height: 60)
                    
                    ForEach(Array(viewModel.allLyrics.enumerated()), id: \.element.id) { index, lyric in
                        let isCurrent = index == viewModel.currentLyricIndex
                        let progress  = progressFor(index: index)

                        LyricRowWithBarView(lyric: lyric, isCurrent: isCurrent, progress: progress)
                            .id(index) // ID untuk target scroll
                    }
                    
                    // Ruang kosong bawah
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .liquidGlassBox(cornerRadius: 22)
            .onChange(of: viewModel.currentLyricIndex) { newIndex in
                if let idx = newIndex {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
            .onAppear {
                if let idx = viewModel.currentLyricIndex {
                    proxy.scrollTo(idx, anchor: .center)
                }
            }
        }
        .padding(.horizontal, 35)  // HIG: consistent edge inset
        .padding(.top, 12)
    }

    private func progressFor(index: Int) -> CGFloat {
        let lyric    = viewModel.allLyrics[index]
        let duration = lyric.endTime - lyric.startTime
        guard duration > 0 else { return 1.0 }
        let p = (viewModel.currentTime - lyric.startTime) / duration
        return CGFloat(min(max(p, 0), 1))
    }
}

/// Satu baris lirik. Bar napas HANYA muncul untuk baris "BREATHE".
/// HIG: font size ≥ 22pt untuk readability, consistent spacing.
struct LyricRowWithBarView: View {
    let lyric: LyricLine
    let isCurrent: Bool
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if lyric.isBreathe {
                // ── Baris BREATHE: bar napas animasi ─────────────────
                BreathBarIndicatorView(
                    progress: isCurrent ? progress : 1.0,
                    isCurrent: isCurrent
                )
            } else if lyric.text.isEmpty {
                // ── Jeda instrumental: tiga titik ────────────────────
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(AppColors.lyricActive.opacity(isCurrent ? 0.3 : 0.12))
                            .frame(width: 5, height: 5)
                    }
                }
            } else {
                // ── Baris lirik normal (Sweep Effect) ──────────────────
                ZStack(alignment: .leading) {
                    // Teks dasar (abu-abu/redup)
                    Text(lyric.text)
                        .font(.system(
                            size: isCurrent ? 30 : 26,
                            weight: isCurrent ? .bold : .regular,
                            design: .rounded
                        ))
                        .foregroundColor(.white.opacity(0.40))
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                    
                    // Teks aktif (putih terang) yang menyapu dari kiri ke kanan
                    Text(lyric.text)
                        .font(.system(
                            size: isCurrent ? 30 : 26,
                            weight: isCurrent ? .bold : .regular,
                            design: .rounded
                        ))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.85)
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    // Menyapu sesuai progress hanya jika baris ini sedang dinyanyikan
                                    .frame(width: max(0, geo.size.width * (isCurrent ? progress : 0.0)))
                            }
                        )
                }
                // ── Baris lirik normal (TANPA bar) ──────────────────
                Text(lyric.text)
                    .font(.system(
                        size: isCurrent ? 30 : 26,
                        weight: isCurrent ? .bold : .regular,
                        design: .rounded
                    ))
                    .foregroundColor(isCurrent ? AppColors.lyricActive : AppColors.lyricInactive)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
            }
        }
        .padding(.vertical, 10)
    }
}

/// Bar kecil biru di bawah tiap baris lirik — indikator jeda napas.
/// Lebar FIXED (bukan full-width), sesuai referensi:
/// - Non-aktif: track 64pt, fill 64pt (solid dim)
/// - Aktif: track 160pt, fill animasi sesuai progress
struct BreathBarIndicatorView: View {
    let progress: CGFloat
    let isCurrent: Bool

    // Lebar track background (referensi: aktif ~160pt, non-aktif ~64pt)
    private var trackWidth: CGFloat { isCurrent ? 160 : 64 }
    // Lebar fill minimum 8pt agar selalu ada sedikit warna biru
    private var fillWidth: CGFloat {
        isCurrent ? max(8, trackWidth * progress) : trackWidth
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Track background
            RoundedRectangle(cornerRadius: 3)
                .fill(AppColors.overlayLight)
                .frame(width: trackWidth, height: 5)

            // Fill biru ke putih sesuai referensi gambar
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    isCurrent
                    ? LinearGradient(
                        colors: [AppColors.accentBlue,                     // Biru kuat di kiri
                                 AppColors.lyricActive],                    // Memutih di kanan
                        startPoint: .leading,
                        endPoint: .trailing
                      )
                    : LinearGradient(
                        colors: [AppColors.accentBlueSoft.opacity(0.55),
                                 AppColors.accentBlueSoft.opacity(0.55)],
                        startPoint: .leading,
                        endPoint: .trailing
                      )
                )
                .frame(width: fillWidth, height: 5)
                .shadow(color: .black.opacity(isCurrent ? 0.3 : 0.0), radius: 2, x: 0, y: 1) // Shadow lembut
                .animation(.linear(duration: 0.06), value: progress)
        }
        .frame(height: 5, alignment: .leading)
    }
}

// ============================================================
// MARK: - V2 Playback Progress Slider
// ============================================================

/// Slider progress lagu dengan timestamp kiri (elapsed) dan kanan (total).
struct PlaybackProgressView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    // State lokal saat user menahan/menggeser slider
    @State private var dragProgress: CGFloat? = nil

    private var progress: CGFloat {
        if let dp = dragProgress { return dp }
        guard let duration = viewModel.songDuration, duration > 0 else { return 0 }
        return CGFloat(viewModel.currentTime / duration)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Tampilkan waktu sementara jika sedang digeser, atau waktu asli lagu jika tidak
            let displayedTime = dragProgress != nil ? (Double(dragProgress!) * (viewModel.songDuration ?? 0)) : viewModel.currentTime
            Text(formatTime(displayedTime))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(AppColors.labelDim)
                .frame(width: 36, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
            // Track
            Capsule()
                .fill(AppColors.overlayTrack)
                .frame(height: 4) // Sedikit ditebalkan sesuai referensi

            // Filled portion (Gradien biru ke putih)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.lyricActive],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(0, geo.size.width * progress), height: 4)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1) // Efek shadow

            // Thumb
            Circle()
                        .fill(AppColors.lyricActive)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                        // Perbesar sedikit thumb saat sedang di-drag
                        .scaleEffect(dragProgress != nil ? 1.3 : 1.0)
                        .offset(x: (geo.size.width * progress) - 7)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: dragProgress != nil)
                }
                .contentShape(Rectangle()) // Buat seluruh area track bisa disentuh
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Batasi progress antara 0.0 - 1.0
                            let newProgress = max(0, min(1, value.location.x / geo.size.width))
                            dragProgress = newProgress
                        }
                        .onEnded { value in
                            let newProgress = max(0, min(1, value.location.x / geo.size.width))
                            if let duration = viewModel.songDuration {
                                viewModel.seek(to: TimeInterval(newProgress) * duration)
                            }
                            dragProgress = nil
                        }
                )
            }
            .frame(height: 14)

            Text(formatTime(viewModel.songDuration ?? 0))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(AppColors.labelDim)
                .frame(width: 36, alignment: .leading)
        }
        .padding(.horizontal, 20)  // HIG: consistent 20pt edge inset
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// ============================================================
// MARK: - V2 Waveform Visualizer
// ============================================================

/// Waveform bar yang lebih besar dan lebih visible. Bar putih saat recording,
/// abu-abu saat idle. Animasi spring ringan.
struct WaveformVisualizerViewV2: View {
    @ObservedObject var viewModel: RecordViewModel

    var body: some View {
        HStack(spacing: 3.0) {
            ForEach(0..<viewModel.audioLevels.count, id: \.self) { index in
                let level = viewModel.audioLevels[index]
                
                // 1. Biarkan tinggi bar merespons level secara natural tanpa lompatan drastis.
                // Jika ingin meredam "noise" kecil, kamu bisa mengurangi nilainya sedikit,
                // tapi pastikan transisinya tetap mulus.
                let smoothLevel = max(0, level - 0.05) // Sedikit noise gate (opsional)
                let barHeight: CGFloat = max(2.0, smoothLevel * 100.0)

                RoundedRectangle(cornerRadius: 2.5)
                    .fill(
                        viewModel.isRecording
                        ? AppColors.waveformActive
                        : AppColors.waveformIdle
                    )
                    .frame(width: 3.0, height: barHeight)
                    
                    // 2. Gunakan easeOut dengan durasi yang mendekati interval timer di ViewModel kamu (biasanya 0.1 - 0.15 detik).
                    // Ini akan membuat batang memanjang dan menyusut seperti bernapas, bukan memantul.
                    .animation(.easeOut(duration: 0.15), value: barHeight)
            }
        }
        .frame(height: 100.0)
    }
}

// ============================================================
// MARK: - V2 Record Controls (Replay + Mic/Pause)
// ============================================================

/// Bottom control bar — HIG: min 44pt tap targets, primary action centered.
/// - Mic/Pause: centered di tengah layar secara horizontal
/// - Replay: di kiri tombol Mic
struct RecordControlsViewV2: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var navigateToResult: Bool

    var body: some View {
        ZStack {
            // ── Mic / Pause (centered horizontal) ────────────────────────
            Button(action: {
                viewModel.togglePlayAndRecord()
            }) {
                ZStack {
                    // Background gradasi dalam tombol
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.buttonBlueTop,   // Biru gelap
                                         AppColors.buttonBlueBottom], // Biru sangat gelap pekat
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    // Outer ring tebal solid putih
                    Circle()
                        .stroke(AppColors.lyricActive, lineWidth: 4.5)
                        .frame(width: 90, height: 90)

                    // Icon putih tebal tanpa fill background
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "mic.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(AppColors.lyricActive)
                }
            }

            // ── Replay (kiri dari mic) ────────────────────────────────────
            HStack {
                Button(action: {
                    viewModel.replayRecording()
                }) {
                    ZStack {
                        // Background gradasi dalam tombol
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.buttonBlueTop,   // Biru gelap
                                             AppColors.buttonBlueBottom], // Biru sangat gelap pekat
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        // Border tipis solid putih
                        Circle()
                            .stroke(AppColors.lyricActive, lineWidth: 1.2)
                            .frame(width: 52, height: 52)

                        // Icon arrow tebal solid putih
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppColors.lyricActive)
                    }
                }
                .padding(.leading, 75)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
//        .padding(.bottom, 1)

        // ── "Selesai" (Done) button — navigate to Result page ────────────
//        if viewModel.isRecording || viewModel.pitchHistory.count > 0 {
//            Button("Selesai") {
//                viewModel.stopRecording()
//                navigateToResult = true
//            }
//            .padding(.horizontal, 30)
//            .padding(.vertical, 15)
//            .background(AppColors.stateSuccess)
//            .foregroundColor(AppColors.lyricActive)
//            .cornerRadius(25)
//            .font(.headline)
//        }
    }
}

// ============================================================
// MARK: - V2 Breath Timeline
// ============================================================

/// Timeline berjalan yang menunjukkan kapan harus bernapas.
/// Lingkaran kecil = curi napas, kapsul panjang = napas panjang.
struct BreathTimelineView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    var body: some View {
        GeometryReader { geo in
            let playheadX: CGFloat = 35 // Posisi garis playhead di kiri
            let visibleDuration: TimeInterval = 4.0 // Berapa detik ke depan yang terlihat
            let pixelsPerSecond = (geo.size.width - playheadX) / CGFloat(visibleDuration)
            let trackHeight = geo.size.height
            
            // Cek apakah saat ini playhead sedang mengenai marker napas
            let isInhaling = viewModel.breathMarkers.contains { marker in
                viewModel.currentTime >= marker.startTime && viewModel.currentTime <= marker.endTime
            }
            
            ZStack(alignment: .leading) {
                // Background Track (Kaca gelap)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                
                // 3 Garis Horizontal (Track lanes)
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    Spacer()
                }
                
                // Exhale Markers (Lirik yang dinyanyikan - Warna Biru Solid)
                ForEach(viewModel.allLyrics) { marker in
                    let timeDiff = marker.startTime - viewModel.currentTime
                    let xPos = playheadX + CGFloat(timeDiff) * pixelsPerSecond
                    let duration = marker.endTime - marker.startTime
                    let width = max(16.0, CGFloat(duration) * pixelsPerSecond)
                    
                    if (xPos + width) > -50 && xPos < geo.size.width + 100 {
                        Capsule()
                            .fill(Color(red: 0.22, green: 0.41, blue: 0.85)) // Biru solid
                            .frame(width: width, height: 18)
                            .position(x: xPos + (width / 2), y: trackHeight / 2)
                    }
                }
                
                // Inhale Markers (Ambil Napas - Warna Liquid Glass)
                ForEach(viewModel.breathMarkers) { marker in
                    let timeDiff = marker.startTime - viewModel.currentTime
                    let xPos = playheadX + CGFloat(timeDiff) * pixelsPerSecond
                    let duration = marker.endTime - marker.startTime
                    let width = max(16.0, CGFloat(duration) * pixelsPerSecond)
                    
                    if (xPos + width) > -50 && xPos < geo.size.width + 100 {
                        // Desain efek Liquid Glass pada Capsule
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .background(Capsule().fill(.ultraThinMaterial))
                            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            .frame(width: width, height: 18)
                            .position(x: xPos + (width / 2), y: trackHeight / 2)
                    }
                }
                
                // Garis Vertikal Playhead
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 1, height: trackHeight)
                    .position(x: playheadX, y: trackHeight / 2)
                
                // Lingkaran Playhead / Tulisan INHALE
                ZStack {
                    if isInhaling {
                        Text("INHALE")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(Color(red: 0.22, green: 0.41, blue: 0.85)) // Warna biru yang sama
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 24, height: 24)
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 16, height: 16)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                // Geser menyesuaikan lebar tulisan agar tidak memotong batas kiri
                .position(x: isInhaling ? playheadX + 24 : playheadX, y: trackHeight / 2)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isInhaling)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 46)
    }
}

// ============================================================
// MARK: - Liquid Glass Box Modifier
// ============================================================

struct LiquidGlassBoxModifier: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            // 1. Efek Kaca Transparan (Atur opacity di sini jika ingin lebih/kurang tembus pandang)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(0.07) // Semakin kecil angkanya (misal 0.1), semakin transparan
            )
            // 2. Highlight / Pinggiran bercahaya
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.lyricActive.opacity(0.5), AppColors.lyricActive.opacity(0.05), AppColors.lyricActive.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
            )
            // 4. Shadow lembut di bawah box
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
    }
}

extension View {
    /// Memberikan efek Liquid Glass (kaca buram dengan highlight gradient)
    func liquidGlassBox(cornerRadius: CGFloat = 22) -> some View {
        self.modifier(LiquidGlassBoxModifier(cornerRadius: cornerRadius))
    }
}
