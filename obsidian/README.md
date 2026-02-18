# Obsidian with Automatic Sync

This module configures Obsidian with a custom plugin for automatic vault synchronization using rclone bisync.

## Features

- ✅ Automatic background sync via file watching
- ✅ Periodic pulls to catch remote changes (configurable interval)
- ✅ Bidirectional sync using rclone bisync
- ✅ Conflict resolution strategies (newest wins, server wins, client wins)
- ✅ Fully configured through Nix/home-manager
- ✅ SSH key management
- ✅ Works across macOS and Linux

## Quick Start

### 1. Enable in Your Configuration

In your `local-provisioning/flake.nix` or home-manager config:

```nix
{
  config.obsidian = {
    enable = true;

    # Optional: customize vault location (defaults shown below)
    # vaultPath = "${config.home.homeDirectory}/my-custom-vault";

    sync = {
      enable = true;
      remoteHost = "vault.yourdomain.com";  # Your NixOS server
      remoteUser = "obsidian-sync";
      remotePath = "/srv/obsidian-vaults/your-username";

      # Optional: use your default SSH key instead of generating a new one
      # sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };
}
```

### 2. Deploy

```bash
cd ~/dev/hm/local-provisioning
home-manager switch
```

This will:
- Install Obsidian and rclone
- Create vault directory at `~/Documents/ObsidianVault` (macOS) or `~/obsidian-vault` (Linux)
- Generate SSH key (only if it doesn't exist) or use your existing key
- Install and configure the sync plugin
- Set up rclone configuration

### 3. Configure Server

**If using a new generated key:**
- The deployment will print your SSH public key
- Add it to your NixOS server configuration

**If using your existing default key:**
- Your server likely already has your public key
- **If your key is password-protected:**
  - **macOS:** See [SSH_AGENT_SETUP.md](./SSH_AGENT_SETUP.md) for macOS Keychain setup
  - **Linux:** See [LINUX_SSH_SETUP.md](./LINUX_SSH_SETUP.md) for GNOME Keyring and other options
- If your key has no password: No additional setup needed

See the plan file at `~/.claude/plans/federated-weaving-swan.md` for complete server setup instructions.

### 4. Test Connection

```bash
# Test SSH
ssh -i ~/.ssh/obsidian_sync_ed25519 obsidian-sync@vault.yourdomain.com

# Test rclone
rclone ls obsidian-remote:
```

### 5. Open Obsidian

1. Open Obsidian
2. Open the vault at `~/Documents/ObsidianVault` (or your custom path)
3. Settings → Community plugins → Enable community plugins (if prompted)
4. The **"Rsync Sync"** plugin should already be enabled automatically
5. Check Developer Console (Cmd+Opt+I) for sync logs

**📖 See [PLUGIN_GUIDE.md](./PLUGIN_GUIDE.md) for detailed instructions on finding and using the plugin.**

## Configuration Options

### Vault Location

```nix
config.obsidian = {
  # Local vault directory (optional)
  vaultPath = "${config.home.homeDirectory}/my-vault";

  # Defaults:
  # - macOS: ~/Documents/ObsidianVault
  # - Linux: ~/obsidian-vault
};
```

### Sync Settings

```nix
config.obsidian.sync = {
  enable = true;                              # Enable/disable sync
  remoteHost = "vault.example.com";          # Server hostname
  remoteUser = "obsidian-sync";               # SSH username
  remotePath = "/srv/obsidian-vaults/user";   # Remote vault path
  sshKeyPath = "~/.ssh/obsidian_sync_ed25519"; # SSH key location
  pullIntervalMinutes = 5;                    # How often to pull (default: 5)
  debounceSeconds = 5;                        # Wait time after changes (default: 5)
  conflictStrategy = "newest";                # newest, server, or client

  # Background sync (optional - syncs even when Obsidian is closed)
  backgroundSync = {
    enable = false;                           # Enable background service
    interval = "5min";                        # Sync interval (systemd format)
  };
};
```

### Conflict Resolution Strategies

- **`newest`** (recommended): Uses modification time to determine which version to keep
- **`server`**: Always prefers the remote version
- **`client`**: Always prefers the local version

## How It Works

### Sync Flow

1. **On Startup**: Plugin pulls latest changes from server
2. **On File Change**:
   - Changes are tracked
   - After 5 seconds of no changes (debounce), sync is triggered
   - Plugin runs `rclone bisync` to sync both directions
3. **Periodic Pull**: Every 5 minutes, plugin pulls latest changes
4. **Conflict Resolution**: Handled automatically by configured strategy

### Plugin Architecture

The custom plugin is written in TypeScript and:
- Monitors vault events (create, modify, delete, rename)
- Shells out to rclone for syncing
- Handles conflicts using configured strategy
- Prevents concurrent syncs with state management
- Logs all operations to Developer Console

### Rclone Bisync

Uses `rclone bisync` which provides:
- True bidirectional synchronization
- Built-in conflict resolution
- Resilient operation (recovers from interruptions)
- Safety features (max-delete limit)

## Troubleshooting

### Plugin Not Appearing

1. Check if Obsidian is installed: `which obsidian`
2. Check if plugin is installed: `ls -la ~/.config/obsidian/plugins/obsidian-rsync-sync`
3. Rebuild: `home-manager switch`

### Sync Errors

1. Open Developer Console (Cmd+Opt+I on macOS, Ctrl+Shift+I on Linux)
2. Look for `[Rsync Sync]` log messages
3. Common issues:
   - **SSH key not accepted**: Check server has your public key
   - **Remote path doesn't exist**: Create directory on server
   - **Rclone not found**: Check `which rclone` and update path in settings

### Test Sync Manually

```bash
# Navigate to vault
cd ~/Documents/ObsidianVault

# Run rclone bisync manually
rclone bisync . obsidian-remote:/srv/obsidian-vaults/your-username \
  --create-empty-src-dirs \
  --conflict-resolve newer \
  --resilient \
  --verbose
```

### View Sync Logs

In Obsidian:
1. Open Developer Tools (Cmd+Opt+I on macOS)
2. Go to Console tab
3. Filter by `[Rsync Sync]`

## Mobile Support

The custom plugin uses `child_process` which isn't available on mobile. For mobile devices:

1. Use the **Obsidian Git plugin** instead
2. Configure your server to also serve the vault via Git
3. See the implementation plan for complete mobile setup instructions

## File Structure

```
provisioning/obsidian/
├── default.nix              # Home-manager module
├── README.md                # This file
└── plugin/                  # Custom plugin source
    ├── src/
    │   ├── main.ts
    │   ├── syncManager.ts
    │   ├── fileWatcher.ts
    │   ├── commandExecutor.ts
    │   ├── conflictResolver.ts
    │   ├── settings.ts
    │   ├── syncState.ts
    │   └── logger.ts
    ├── manifest.json
    ├── package.json
    ├── tsconfig.json
    ├── esbuild.config.mjs
    └── default.nix          # Plugin build derivation
```

## Vault Location

**Default locations:**
- **macOS**: `~/Documents/ObsidianVault`
- **Linux**: `~/obsidian-vault`

**Custom location:**
```nix
config.obsidian.vaultPath = "${config.home.homeDirectory}/Notes/vault";
```

The directory will be created automatically on first run if it doesn't exist.

## Security

- Uses SSH key authentication (no passwords)
- SSH key is generated with ED25519 algorithm
- Server should be configured to only allow key-based auth
- Sync user on server should be isolated with limited permissions

## Development

To modify the plugin:

```bash
cd ~/dev/hm/provisioning/obsidian/plugin
npm install
npm run dev  # Watch mode
# or
npm run build  # Production build
```

After making changes:
```bash
home-manager switch
```

## Documentation

- **[PLUGIN_GUIDE.md](./PLUGIN_GUIDE.md)** - How to find and use the plugin in Obsidian
- **[EXAMPLES.md](./EXAMPLES.md)** - Configuration examples for different use cases
- **[SSH_AGENT_SETUP.md](./SSH_AGENT_SETUP.md)** - macOS: Password-protected SSH keys with Keychain
- **[LINUX_SSH_SETUP.md](./LINUX_SSH_SETUP.md)** - Linux: SSH agent options (GNOME Keyring, KDE Wallet, etc.)
- **[ADVANCED_SSH.md](./ADVANCED_SSH.md)** - Advanced SSH configuration options
- **Implementation plan:** `~/.claude/plans/federated-weaving-swan.md`

## Related Files

- Plugin source: `provisioning/obsidian/plugin/`
- Nix module: `provisioning/obsidian/default.nix`
- Background sync: `provisioning/obsidian/background-sync.nix`
- Home-manager config: `provisioning/home-common.nix`

## License

MIT
