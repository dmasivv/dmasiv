# dmasiv

An offline karaoke iOS app built with SwiftUI. Users choose a song, record themselves singing, and receive a score with feedback.

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 16+ (tested on 26.4) |
| iOS Deployment Target | 17.0+ |
| Swift | 5.0+ |
| xcodegen | 2.x (only needed to regenerate the project file) |

## Getting Started

### 1. Clone the repo

```bash
git clone <repo-url>
cd dmasiv
```

### 2. Generate the Xcode project

The `.xcodeproj` is **not committed** to git (see `.gitignore`). You must generate it locally before opening in Xcode.

```bash
# Install xcodegen if you don't have it
brew install xcodegen

# Generate the project
xcodegen generate
```

This reads `project.yml` and produces `dmasiv.xcodeproj`.

### 3. Open in Xcode and run

```bash
open dmasiv.xcodeproj
```

Press **Cmd+R** to build and run on a simulator.

### Build from terminal (optional)

```bash
xcodebuild \
  -project dmasiv.xcodeproj \
  -scheme dmasiv \
  -destination "generic/platform=iOS Simulator" \
  -configuration Debug \
  build
```

---

## Navigation Flow

```
SongListView  (NavigationStack root)
  ├── gear icon ──► SettingsView
  └── tap song  ──► RecordView(song:)
                          └── Stop Recording ──► ResultView(song:)
```

---

## Project Structure

```
dmasiv/
├── project.yml                          # xcodegen config — source of truth for the Xcode project
├── generate_karaoke_boilerplate.sh      # regenerates the file scaffold (offline karaoke)
├── generate_swiftui_boilerplate.sh      # generates a generic SwiftUI MVVM scaffold
│
└── dmasiv/                              # app source root
    ├── Info.plist
    │
    ├── App/
    │   └── App.swift                    # @main entry point, launches SongListView
    │
    ├── Core/                            # shared, feature-independent code
    │   ├── Models/
    │   │   ├── Song.swift               # Song data struct (id, title, artist, file names)
    │   │   └── LyricLine.swift          # LyricLine struct (text + timestamp)
    │   ├── Audio/
    │   │   └── AudioPlayerService.swift # AudioPlayerServiceProtocol + stub implementation
    │   ├── Utilities/
    │   │   └── LyricParser.swift        # stub: parses .lrc / JSON into [LyricLine]
    │   └── Constants/                   # (empty, reserved for app-wide constants)
    │
    ├── Features/
    │   ├── SongList/                    # Page 1 — browse local song library
    │   │   ├── ViewModels/SongListViewModel.swift
    │   │   └── Views/SongListView.swift
    │   │
    │   ├── Record/                      # Page 2 — karaoke playback + mic recording
    │   │   ├── ViewModels/RecordViewModel.swift
    │   │   └── Views/RecordView.swift
    │   │
    │   ├── Result/                      # Page 3 — score and feedback
    │   │   ├── ViewModels/ResultViewModel.swift
    │   │   └── Views/ResultView.swift
    │   │
    │   └── Settings/                    # Accessible via gear icon on SongListView
    │       ├── ViewModels/SettingsViewModel.swift
    │       └── Views/SettingsView.swift
    │
    ├── Shared/
    │   ├── Theme/
    │   │   └── AppColors.swift          # Global color palette (5 semantic colors)
    │   ├── Components/                  # (empty, reserved for reusable views)
    │   └── Extensions/                  # (empty, reserved for Swift extensions)
    │
    └── Resources/
        ├── Assets.xcassets/             # App icon + 5 color sets (Primary, Secondary,
        │                                #   Accent, Background, Surface)
        ├── Audio/                       # Bundled .mp3 / .m4a files go here
        └── Lyrics/                      # Bundled .lrc / .json lyric files go here
```

---

## Architecture

**Feature-based MVVM** with a shared Core layer.

- **ViewModel**: `@MainActor`, `ObservableObject`. Exposes `@Published private(set)` state — views never mutate state directly.
- **View**: SwiftUI `struct`, observes its ViewModel via `@StateObject`.
- **Dependency Injection**: Services are passed via `init` parameters using protocol types (e.g., `AudioPlayerServiceProtocol`), enabling future testability.
- **Offline-only**: No networking. Songs, audio, and lyrics are all bundled in `Resources/`.

---

## Color Palette

Colors are defined in `Shared/Theme/AppColors.swift` and backed by asset catalog entries in `Resources/Assets.xcassets/`. To change a color, edit the `.colorset` in Xcode's asset editor — no code changes needed.

| Token | Usage |
|-------|-------|
| `AppColors.primary` | Main brand color |
| `AppColors.secondary` | Supporting color |
| `AppColors.accent` | Highlights and CTAs |
| `AppColors.background` | Page backgrounds |
| `AppColors.surface` | Cards and containers |

---

## Adding a New Song

1. Drop the audio file into `dmasiv/Resources/Audio/`
2. Drop the `.lrc` or `.json` lyric file into `dmasiv/Resources/Lyrics/`
3. Create a `Song` instance in `SongListViewModel.loadLocalSongs()` referencing those file names
4. Run `xcodegen generate` so the new resource files are picked up by the project

## Adding New Swift Files

After creating a new `.swift` file on disk, run:

```bash
xcodegen generate
```

xcodegen auto-discovers all files under `dmasiv/` — no manual project file editing needed.
