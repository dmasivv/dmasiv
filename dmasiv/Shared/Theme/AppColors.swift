import SwiftUI

// MARK: - App Colors
// All colors used across the app, defined as static constants.

struct AppColors {

    // ── Card / Overlay Surfaces ───────────────────────────────────────────
    /// Dark navy fill for floating cards (e.g. onboarding popup)
    static let cardSurface          = Color(red: 0.06, green: 0.09, blue: 0.20)

    // ── Timeline Capsule Colors ───────────────────────────────────────────
    /// Breath / exhale capsule on the timeline
    static let timelineBreath       = AppColors.accentBlue
    /// Sing / lyric capsule on the timeline — glass style (no solid color token needed)
    static let timelineSing         = Color.white.opacity(0.1)
    // ── Background Gradient (RecordView) ──────────────────────────────────
    /// Top of the background gradient
    static let backgroundTop    = Color(red: 0.16, green: 0.25, blue: 0.50)
    /// Middle band of the background gradient (used at 0.25 and 0.45 stops)
    static let backgroundMid    = Color(red: 0.10, green: 0.15, blue: 0.35)
    /// Bottom of the background gradient
    static let backgroundBottom = Color(red: 0.15, green: 0.23, blue: 0.48)
    /// Full-screen background for secondary screens (e.g. RecordingsListView)
    static let backgroundScreen = Color(red: 0.10, green: 0.08, blue: 0.15)

    // ── Accent Blues ──────────────────────────────────────────────────────
    /// Strong blue — progress bar fill start, breath bar active start
    static let accentBlue       = Color(red: 0.22, green: 0.41, blue: 0.85)
    /// Softer blue — breath bar inactive fill
    static let accentBlueSoft   = Color(red: 0.30, green: 0.50, blue: 0.85)
    /// Album art placeholder gradient — top/leading
    static let albumArtTop      = Color(red: 0.30, green: 0.40, blue: 0.70)
    /// Album art placeholder gradient — bottom/trailing
    static let albumArtBottom   = Color(red: 0.20, green: 0.30, blue: 0.60)
    /// Mic / Replay button gradient — top/leading
    static let buttonBlueTop    = Color(red: 0.18, green: 0.30, blue: 0.60)
    /// Mic / Replay button gradient — bottom/trailing
    static let buttonBlueBottom = Color(red: 0.10, green: 0.18, blue: 0.45)

    // ── Lyrics ────────────────────────────────────────────────────────────
    /// Current (active) lyric line
    static let lyricActive      = Color.white
    /// Upcoming / past lyric lines
    static let lyricInactive    = Color.white.opacity(0.40)
    /// Karaoke sweep highlight color
    static let lyricSweep       = Color.purple
    /// Subtitle text (artist name, secondary labels)
    static let lyricSubtitle    = Color.white.opacity(0.65)

    // ── Overlay Surfaces ─────────────────────────────────────────────────
    /// Very subtle fill (e.g. timeline background)
    static let overlaySubtle    = Color.white.opacity(0.05)
    /// Light fill (e.g. toast background, grid lines, breath track)
    static let overlayLight     = Color.white.opacity(0.10)
    /// Medium fill (e.g. instrumental break dots, button backgrounds)
    static let overlayMedium    = Color.white.opacity(0.15)
    /// Track fill (e.g. progress bar track, waveform idle bars)
    static let overlayTrack     = Color.white.opacity(0.18)

    // ── Waveform ─────────────────────────────────────────────────────────
    /// Waveform bars while recording is active
    static let waveformActive   = Color.white.opacity(0.85)
    /// Waveform bars while idle
    static let waveformIdle     = Color.white.opacity(0.18)

    // ── State Indicators ─────────────────────────────────────────────────
    /// Live pitch dot / confirmed action (saved toast checkmark, Selesai button)
    static let stateSuccess     = Color.green
    /// Success confirmation border (e.g. saved toast stroke)
    static let stateSuccessSoft = Color.green.opacity(0.30)
    /// Destructive action (e.g. delete button, playhead line)
    static let stateDanger      = Color.red.opacity(0.80)
    /// Recorded pitch history dots on the timeline
    static let pitchHistory     = Color.yellow.opacity(0.80)
    /// Active MIDI note capsule on the timeline
    static let noteActive       = Color.blue.opacity(0.80)
    /// Inactive MIDI note capsule on the timeline
    static let noteInactive     = Color.gray.opacity(0.40)
    /// No-pitch-detected state (pitch indicator label)
    static let pitchNone        = Color.gray
    /// Timestamps and dim labels
    static let labelDim         = Color.white.opacity(0.45)
}
