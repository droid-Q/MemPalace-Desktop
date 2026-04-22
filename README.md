# MemPalace Desktop

A native macOS application for managing your [MemPalace](https://github.com/MemPalace/mempalace) memory system.

## Features

- **Search** - Search through your memories with full-text search across wings and rooms
- **Palace View** - Visualize your memory palace structure with wings and rooms
- **Agents** - Manage AI agents and their associated memories
- **Settings** - Configure palace path, auto-save, and other preferences

## Requirements

- macOS 14.0 or later
- [MemPalace CLI](https://github.com/MemPalace/mempalace) installed and accessible in PATH

## Installation

1. Clone this repository
2. Open `MemPalace.xcodeproj` in Xcode
3. Build and run (Cmd+R)

Or download a pre-built release from the [Releases](https://github.com/droid-Q/MemPalace-Desktop/releases) page.

## Usage

### Palace Path

MemPalace stores memories in `~/.mempalace/palace` by default. Make sure the MemPalace CLI is installed and the palace directory is initialized.

### Search

Use the Search tab to find memories across your palace. You can filter by wing or search globally.

### Palace View

The Palace view shows your memory palace structure:
- **Wings** - Top-level organizational units (e.g., projects, topics)
- **Rooms** - Within each wing, rooms categorize memories

Click on a wing to see details and perform actions:
- Search within wing
- View timeline
- Export wing data

### Wake Up

The Wake Up feature loads relevant context from your palace for the current session.

### Mine Directory

Mine a directory of files or conversations into your palace for future retrieval.

## Keyboard Shortcuts

- `Cmd+N` - New Search
- `Cmd+M` - Mine Directory
- `Cmd+R` - Refresh
- `Cmd+W` - Close Window
- `Cmd+,` - Settings

## Architecture

```
MemPalace/
├── main.swift              # Application entry point
├── AppDelegate.swift       # App lifecycle management
├── AppState.swift          # Global state management
├── Services/
│   ├── MemPalaceService.swift   # MemPalace CLI wrapper
│   └── ProcessRunner.swift      # Shell command execution
└── Views/
    ├── ContentView.swift   # Main layout with sidebar
    ├── SearchView.swift    # Search interface
    ├── PalaceView.swift    # Palace visualization
    ├── AgentsView.swift     # Agent management
    └── SettingsView.swift   # Preferences
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
