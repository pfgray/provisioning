# Obsidian Plugin Guide

## Where to Find the Plugin

After running `home-manager switch`, the plugin will be installed to your vault:

```
<your-vault>/.obsidian/plugins/obsidian-rsync-sync/
├── main.js           # Plugin code (17.9 KB)
├── manifest.json     # Plugin metadata
└── data.json         # Your sync settings
```

## How to Enable the Plugin

### Step 1: Open Obsidian

Open Obsidian and select your vault:
- **macOS**: `~/Documents/ObsidianVault` (or your custom path)
- **Linux**: `~/obsidian-vault` (or your custom path)

### Step 2: Enable Community Plugins

If this is your first time using community plugins:

1. Open Settings (⚙️ gear icon in bottom-left, or `Cmd+,` on macOS)
2. Go to **Community plugins** section
3. Click **Turn on community plugins** (if prompted)
4. You may see a warning about third-party plugins - click **Turn on community plugins**

### Step 3: Find the Rsync Sync Plugin

The plugin should already be enabled automatically! To verify:

1. Settings → **Community plugins**
2. Look under **Installed plugins**
3. You should see **"Rsync Sync"** with a toggle switch

It should look like this:

```
Installed plugins
─────────────────
  ⚫ Rsync Sync                    [toggle ON]
     Automatic vault synchronization using rclone/rsync
     by Paul Gray
```

If the toggle is OFF, click it to turn it ON.

## Plugin Settings

To configure the plugin (optional - Nix already configured it):

1. Settings → **Community plugins** → **Rsync Sync**
2. Or look for the settings cog ⚙️ next to the plugin name

You'll see:

```
Rsync Sync Settings
───────────────────

✅ Enable sync

Remote Configuration
───────────────────
Rclone path: /nix/store/.../rclone
Remote host: vault.example.com
Remote user: obsidian-sync
Remote path: /srv/obsidian-vaults/paul.gray
SSH key path: ~/.ssh/obsidian_sync_ed25519

Sync Behavior
─────────────
✅ Sync on startup
✅ Sync on file change
Pull interval (minutes): 5
Debounce delay (seconds): 5

Conflict resolution: Newest wins (by modification time)
```

All these settings are configured by your Nix configuration, so you typically don't need to change them here.

## How to Verify It's Working

### Check the Developer Console

1. Press `Cmd+Opt+I` (macOS) or `Ctrl+Shift+I` (Linux) to open Developer Tools
2. Go to the **Console** tab
3. Look for messages starting with `[Rsync Sync]`:

```
[Rsync Sync] Loading Rsync Sync plugin
[Rsync Sync] Performing initial sync on startup
[Rsync Sync] Starting pull from remote
[Rsync Sync] Pull completed successfully
[Rsync Sync] Registering periodic pull every 5 minutes
[Rsync Sync] Rsync Sync plugin loaded
```

### Check the Status Bar

Look at the bottom-right of the Obsidian window. You should see:

```
Rsync Sync: Ready
```

### Test Manual Sync

Try the manual sync command:

1. Open Command Palette (`Cmd+P` on macOS, `Ctrl+P` on Linux)
2. Type "sync"
3. Select **"Rsync Sync: Trigger Manual Sync"**
4. You should see a notice: "Starting sync..." followed by "Sync completed successfully"

### Create a Test Note

1. Create a new note (e.g., "test.md")
2. Type some content
3. Wait 5 seconds (debounce delay)
4. Check the Developer Console - you should see sync messages
5. Verify the file appears on your server:
   ```bash
   ssh obsidian-sync@your-server
   ls /srv/obsidian-vaults/paul.gray/test.md
   ```

## Plugin Location

The plugin is installed in your vault at:

```bash
# Check plugin files
ls -la ~/Documents/ObsidianVault/.obsidian/plugins/obsidian-rsync-sync/

# Should show:
# drwxr-xr-x  main.js
# -rw-r--r--  manifest.json
# -rw-r--r--  data.json
```

## Troubleshooting

### Plugin Doesn't Appear

**Problem:** Can't find "Rsync Sync" in the plugin list

**Solutions:**

1. **Check community plugins are enabled:**
   - Settings → Community plugins → Should show "Turn off community plugins" (meaning they're ON)

2. **Check plugin files exist:**
   ```bash
   ls ~/Documents/ObsidianVault/.obsidian/plugins/obsidian-rsync-sync/
   ```

3. **Check community-plugins.json:**
   ```bash
   cat ~/Documents/ObsidianVault/.obsidian/community-plugins.json
   # Should include: "obsidian-rsync-sync"
   ```

4. **Restart Obsidian:**
   - Close Obsidian completely
   - Open it again

5. **Rebuild home-manager:**
   ```bash
   cd ~/dev/hm/local-provisioning
   home-manager switch
   ```

### Plugin Shows But Won't Enable

**Problem:** Toggle switch won't turn on, or immediately turns off

**Check Developer Console:**

1. Open Developer Tools (`Cmd+Opt+I`)
2. Look for error messages when toggling the plugin
3. Common issues:
   - Missing dependencies (should not happen with Nix build)
   - Permissions issues with vault directory

**Solution:**
```bash
# Check vault permissions
ls -ld ~/Documents/ObsidianVault
# Should be owned by you with read/write permissions
```

### Sync Errors

**Problem:** Plugin loads but sync fails

**Check:**

1. **SSH connection:**
   ```bash
   ssh -i ~/.ssh/obsidian_sync_ed25519 obsidian-sync@your-server
   ```

2. **Rclone configuration:**
   ```bash
   rclone ls obsidian-remote:
   ```

3. **Plugin settings:**
   - Settings → Rsync Sync
   - Verify all paths and hostnames are correct

4. **Developer Console:**
   - Look for detailed error messages
   - Check what command failed

## Uninstalling/Disabling

### Disable temporarily

1. Settings → Community plugins → Find "Rsync Sync"
2. Toggle it OFF

Or in your Nix config:
```nix
config.obsidian.sync.enable = false;
```

### Remove completely

In your Nix config:
```nix
config.obsidian.enable = false;
```

Then:
```bash
home-manager switch
```

## Plugin Features

Once enabled, the plugin automatically:

✅ **On Startup:**
- Pulls latest changes from server
- Shows notification if sync succeeds/fails

✅ **When You Edit:**
- Watches for file changes (create, modify, delete, rename)
- Waits 5 seconds after last change
- Syncs changes to server
- Shows notification if there are conflicts

✅ **Periodically:**
- Checks for remote changes every 5 minutes
- Pulls new files from server
- Shows notification for new changes

✅ **Manual Trigger:**
- Command Palette → "Rsync Sync: Trigger Manual Sync"
- Force sync at any time

## Advanced: Multiple Vaults

If you use multiple Obsidian vaults, you'll need to:

1. **Option A:** Configure each vault separately in different Nix configs
2. **Option B:** Manually copy the plugin to other vaults:
   ```bash
   cp -r ~/Documents/ObsidianVault/.obsidian/plugins/obsidian-rsync-sync \
         ~/Documents/OtherVault/.obsidian/plugins/
   ```

Each vault has its own plugins, so the plugin needs to be in each vault's `.obsidian/plugins/` directory.
