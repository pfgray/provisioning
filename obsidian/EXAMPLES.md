# Obsidian Configuration Examples

## Example 1: Minimal Configuration

Uses all defaults, just specify your server:

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
    };
  };
}
```

**What you get:**
- Vault at `~/Documents/ObsidianVault` (macOS) or `~/obsidian-vault` (Linux)
- **New SSH key** generated at `~/.ssh/obsidian_sync_ed25519`
- Syncs when Obsidian is open
- 5-minute pull interval
- 5-second debounce after edits
- "Newest wins" conflict resolution

---

## Example 1b: Use Your Default SSH Key

If you already have SSH access to your server:

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";

      # Use your existing SSH key
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
      # Or: sshKeyPath = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };
}
```

**Benefits:**
- ✅ No new SSH key to manage
- ✅ Server already has your public key
- ✅ One less key to add to server
- ✅ Same key for all SSH access

---

## Example 2: Linux with GNOME Keyring (Auto-load Password-Protected Keys)

For Linux users with GNOME desktop (Ubuntu, Fedora, Pop!_OS):

```nix
{
  config.obsidian = {
    enable = true;
    useGnomeKeyring = true;  # Enable GNOME Keyring for automatic key loading

    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";

      # Use your existing password-protected key
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };
}
```

**Setup:**
1. Deploy: `home-manager switch`
2. Run: `ssh-add ~/.ssh/id_ed25519` (enter password once)
3. Check "Remember password" in GNOME dialog
4. After reboot - key auto-loads automatically!

**See [LINUX_SSH_SETUP.md](./LINUX_SSH_SETUP.md) for other Linux desktop environments**

---

## Example 3: Custom Vault Location

Store your vault in a custom location:

```nix
{
  config.obsidian = {
    enable = true;
    vaultPath = "${config.home.homeDirectory}/Dropbox/MyVault";

    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
    };
  };
}
```

**Use cases:**
- You have an existing vault in a different location
- You want to keep notes in Dropbox/iCloud folder
- You prefer a different organization scheme

---

## Example 3: Background Sync (Always On)

Sync continues even when Obsidian is closed:

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";

      # Enable background sync
      backgroundSync = {
        enable = true;
        interval = "5min";
      };
    };
  };
}
```

**What you get:**
- Vault syncs every 5 minutes via background service
- Works even when Obsidian is closed
- Perfect for multiple devices

---

## Example 4: Performance Tuned

Optimized for fast sync with less frequent background checks:

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";

      # Quick sync when actively editing
      debounceSeconds = 3;        # Sync 3 seconds after last edit
      pullIntervalMinutes = 2;    # Check for changes every 2 minutes

      # Less frequent background sync (saves battery)
      backgroundSync = {
        enable = true;
        interval = "15min";       # Background sync every 15 min
      };
    };
  };
}
```

**Good for:**
- Active editing sessions (fast sync)
- Battery-conscious laptop users (less frequent background checks)

---

## Example 5: Server-Authoritative

Server version always wins in conflicts:

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";

      # Server is source of truth
      conflictStrategy = "server";

      backgroundSync = {
        enable = true;
      };
    };
  };
}
```

**Use cases:**
- Collaborative vault (multiple people editing)
- Server has automated processing
- You want predictable conflict resolution

---

## Example 6: Full Custom Configuration

All options customized:

```nix
{
  config.obsidian = {
    enable = true;

    # Custom vault location
    vaultPath = "${config.home.homeDirectory}/Documents/Notes/Work";

    sync = {
      enable = true;

      # Server settings
      remoteHost = "sync.mycompany.com";
      remoteUser = "vault-sync";
      remotePath = "/data/vaults/paul-gray";
      sshKeyPath = "${config.home.homeDirectory}/.ssh/company_vault_key";

      # Timing
      pullIntervalMinutes = 10;
      debounceSeconds = 10;

      # Conflict resolution
      conflictStrategy = "newest";

      # Background sync
      backgroundSync = {
        enable = true;
        interval = "10min";
      };
    };
  };
}
```

---

## Example 7: Multiple Vaults (Advanced)

You can't configure multiple vaults directly with this module, but you can:

**Option A: Multiple machines, different vaults**
```nix
# On laptop
config.obsidian = {
  vaultPath = "${config.home.homeDirectory}/Work";
  sync.remotePath = "/srv/vaults/work";
};

# On desktop
config.obsidian = {
  vaultPath = "${config.home.homeDirectory}/Personal";
  sync.remotePath = "/srv/vaults/personal";
};
```

**Option B: Manual additional syncs**
Use the background sync script as a template and create additional systemd/launchd services for other vaults.

---

## Example 8: Disable Sync Temporarily

Keep Obsidian installed but disable sync:

```nix
{
  config.obsidian = {
    enable = true;
    sync.enable = false;  # Disable all sync
  };
}
```

Or disable just background sync:

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      enable = true;
      backgroundSync.enable = false;  # Only sync when Obsidian is open
    };
  };
}
```

---

## Platform-Specific Examples

### macOS with iCloud

```nix
{
  config.obsidian = {
    enable = true;
    vaultPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/MyVault";

    sync = {
      # Still sync to server as backup
      remoteHost = "backup.example.com";
      remotePath = "/backups/vault";
    };
  };
}
```

### Linux with Custom Location

```nix
{
  config.obsidian = {
    enable = true;
    vaultPath = "/mnt/data/obsidian-vault";

    sync = {
      remoteHost = "server.local";
      remotePath = "/srv/vaults/main";
    };
  };
}
```

---

## Configuration Quick Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `obsidian.enable` | bool | - | Enable Obsidian |
| `obsidian.vaultPath` | string | `~/Documents/ObsidianVault` (macOS)<br>`~/obsidian-vault` (Linux) | Local vault directory |
| `sync.enable` | bool | `true` | Enable sync |
| `sync.remoteHost` | string | - | Server hostname |
| `sync.remoteUser` | string | `"obsidian-sync"` | SSH username |
| `sync.remotePath` | string | - | Remote vault path |
| `sync.sshKeyPath` | string | `~/.ssh/obsidian_sync_ed25519` | SSH key path<br>**Tip:** Set to `~/.ssh/id_ed25519` to use default key |
| `sync.pullIntervalMinutes` | int | `5` | Pull interval (minutes) |
| `sync.debounceSeconds` | int | `5` | Debounce delay (seconds) |
| `sync.conflictStrategy` | enum | `"newest"` | `"newest"`, `"server"`, or `"client"` |
| `sync.backgroundSync.enable` | bool | `false` | Background sync service |
| `sync.backgroundSync.interval` | string | `"5min"` | Background sync interval |

---

## Testing Your Configuration

After deploying:

```bash
# 1. Check vault was created
ls -la ~/Documents/ObsidianVault/  # or your custom path

# 2. Check SSH key
ls -la ~/.ssh/obsidian_sync_ed25519*

# 3. Test SSH connection
ssh -i ~/.ssh/obsidian_sync_ed25519 obsidian-sync@your-server

# 4. Test rclone
rclone ls obsidian-remote:

# 5. Test manual sync
rclone bisync ~/Documents/ObsidianVault obsidian-remote:/path/to/vault --dry-run -v

# 6. Check background service (if enabled)
# macOS:
launchctl list | grep obsidian
tail -f ~/Library/Logs/obsidian-sync.log

# Linux:
systemctl --user status obsidian-sync.timer
journalctl --user -u obsidian-sync -f
```
