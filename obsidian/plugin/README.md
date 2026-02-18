# Obsidian Rsync Sync Plugin

Automatic vault synchronization using rclone bisync. This plugin is designed to work with Nix/home-manager for seamless configuration across devices.

## Features

- **Automatic background sync** using rclone bisync
- **File watching** with debouncing (5 second default)
- **Periodic pulls** to catch remote changes (5 minute default)
- **Conflict resolution** strategies (newest wins, server wins, client wins)
- **Fully configurable** through Obsidian settings or Nix configuration

## Development

### Prerequisites

- Node.js 20+
- npm

### Build

```bash
npm install
npm run build
```

### Development Build

```bash
npm run dev
```

## Architecture

- `main.ts` - Plugin entry point and lifecycle management
- `syncManager.ts` - Core sync orchestration logic
- `fileWatcher.ts` - Vault event handling with debouncing
- `commandExecutor.ts` - Shell command execution
- `conflictResolver.ts` - Conflict detection and resolution
- `settings.ts` - Settings panel UI and data structure
- `syncState.ts` - Sync state management
- `logger.ts` - Logging utilities

## Configuration

This plugin is primarily configured through Nix/home-manager, but can also be configured through the Obsidian settings panel.

### Nix Configuration

See the parent directory's `default.nix` for home-manager module configuration.

### Manual Configuration

Settings can be accessed via: Settings → Community plugins → Rsync Sync

## License

MIT
