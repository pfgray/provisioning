# Troubleshooting Obsidian Sync Issues

## Viewing Error Logs

### Method 1: Developer Console (EASIEST)

**The error messages are saved in the console even if they flash by too quickly to read!**

**Open Developer Tools:**
- **macOS:** `Cmd+Option+I` or `Cmd+Opt+I`
- **Linux:** `Ctrl+Shift+I`

**View the logs:**
1. Click the **Console** tab
2. Scroll up to find the error (red text)
3. Look for lines starting with `[Rsync Sync]`

**Filter to only show plugin messages:**
- In the Filter box at the top, type: `Rsync Sync`

**Filter by severity:**
- Click **Errors** button to show only errors
- Click **Warnings** to include warnings

**Example error:**
```
❌ [Rsync Sync] ERROR: Pull failed: exit code 1
[Rsync Sync] ERROR: Command failed: /nix/store/.../rclone bisync ...
stderr: Failed to create file system for "obsidian-remote:": NewFs: failed to connect SSH: ...
```

---

### Method 2: Enable Debug Mode (More Details)

**Turn on verbose logging:**

1. Open Command Palette (`Cmd+P` on macOS, `Ctrl+P` on Linux)
2. Type: `debug`
3. Select: **"Rsync Sync: Toggle Debug Logging"**
4. You'll see: "Debug logging enabled - check Developer Console"

**Now trigger the sync:**
1. Command Palette → **"Rsync Sync: Trigger Manual Sync"**
2. Open Developer Console (`Cmd+Opt+I`)
3. You'll see detailed debug messages:
   ```
   [Rsync Sync] DEBUG: Building bisync command
   [Rsync Sync] DEBUG: Command: /nix/store/.../rclone bisync ...
   [Rsync Sync] DEBUG: Executing command
   [Rsync Sync] ERROR: Command failed: ...
   ```

**Turn off debug mode:**
- Command Palette → **"Rsync Sync: Toggle Debug Logging"** (again)

---

### Method 3: Background Sync Logs (If Enabled)

If you have `backgroundSync.enable = true`:

**macOS:**
```bash
# View live logs
tail -f ~/Library/Logs/obsidian-sync.log

# View last 100 lines
tail -100 ~/Library/Logs/obsidian-sync.log

# Search for errors
grep -i "error\|failed" ~/Library/Logs/obsidian-sync.log

# View in less (scrollable)
less ~/Library/Logs/obsidian-sync.log
```

**Linux:**
```bash
# View live logs
journalctl --user -u obsidian-sync -f

# View last 100 lines
journalctl --user -u obsidian-sync -n 100

# View since last boot
journalctl --user -u obsidian-sync -b

# Search for errors
journalctl --user -u obsidian-sync | grep -i error
```

---

## Common Errors and Solutions

### Error: "Failed to connect SSH"

**Full error:**
```
Failed to create file system for "obsidian-remote:": NewFs: failed to connect SSH:
ssh: connect to host vault.example.com port 22: Connection refused
```

**Causes:**
1. Server is down or unreachable
2. Wrong hostname in config
3. Firewall blocking SSH

**Solutions:**

1. **Test SSH connection manually:**
   ```bash
   ssh -i ~/.ssh/your_key your-server
   ```

2. **Test rclone:**
   ```bash
   rclone ls obsidian-remote:
   ```

3. **Check server is reachable:**
   ```bash
   ping vault.example.com
   ```

4. **Verify config:**
   - Settings → Rsync Sync
   - Check Remote host, Remote user, SSH key path

---

### Error: "Permission denied (publickey)"

**Full error:**
```
Failed to connect SSH: ssh: handshake failed: ssh: unable to authenticate,
attempted methods [none publickey], no supported methods remain
```

**Causes:**
1. SSH key not added to server
2. Wrong SSH key path
3. Key password not in SSH agent

**Solutions:**

1. **Check SSH key path:**
   ```bash
   ls -la ~/.ssh/obsidian_sync_ed25519
   # or
   ls -la ~/.ssh/id_ed25519
   ```

2. **Test SSH with your key:**
   ```bash
   ssh -i ~/.ssh/your_key obsidian-sync@your-server
   ```

3. **If using password-protected key, check SSH agent:**
   ```bash
   # List keys in agent
   ssh-add -l

   # If empty, add your key
   ssh-add ~/.ssh/your_key
   ```

4. **Verify server has your public key:**
   ```bash
   # Show your public key
   cat ~/.ssh/your_key.pub

   # This should be in server's authorized_keys
   ```

---

### Error: "rclone: command not found"

**Full error:**
```
Command failed: /nix/store/...-rclone/bin/rclone: No such file or directory
```

**Cause:** Rclone path in plugin settings is incorrect

**Solution:**

1. **Find correct rclone path:**
   ```bash
   which rclone
   # Should show: /nix/store/.../bin/rclone
   ```

2. **Update plugin settings:**
   - Settings → Rsync Sync
   - Update "Rclone path" to the correct path

3. **Or rebuild home-manager:**
   ```bash
   cd ~/dev/hm/local-provisioning
   home-manager switch
   ```

---

### Error: "bisync is in a critical state, use --resync to recover"

**Full error:**
```
bisync is in a critical state and may require --resync: bisync aborted
```

**Cause:** Bisync state files are out of sync (usually after a failed sync)

**Solution:**

Run bisync with --resync **ONCE** manually:

```bash
cd ~/Documents/ObsidianVault  # or your vault path

# Dry run first to see what will happen
rclone bisync . obsidian-remote:/srv/obsidian-vaults/your-path \
  --resync \
  --dry-run \
  --verbose

# If it looks good, run for real
rclone bisync . obsidian-remote:/srv/obsidian-vaults/your-path \
  --resync
```

**⚠️ Warning:** `--resync` will sync everything and may overwrite files. Use `--dry-run` first!

After resync, normal syncing should work again.

---

### Error: "path does not exist"

**Full error:**
```
Failed to create file system: directory not found:
/srv/obsidian-vaults/paul.gray
```

**Cause:** Remote directory doesn't exist on server

**Solution:**

1. **SSH to server and create directory:**
   ```bash
   ssh your-server
   sudo mkdir -p /srv/obsidian-vaults/paul.gray
   sudo chown obsidian-sync:obsidian-sync /srv/obsidian-vaults/paul.gray
   ```

2. **Or check your NixOS server config:**
   ```nix
   services.obsidian-sync = {
     enable = true;
     users = [ "paul.gray" ];  # This creates the directory
   };
   ```

---

### Sync is Slow or Hangs

**Symptoms:**
- Sync takes forever
- "Starting sync..." notice never completes
- Plugin seems frozen

**Solutions:**

1. **Check network connection:**
   ```bash
   ping -c 5 your-server
   ```

2. **Check vault size:**
   ```bash
   du -sh ~/Documents/ObsidianVault
   ```
   Large vaults take longer to sync

3. **Check for large files:**
   ```bash
   find ~/Documents/ObsidianVault -type f -size +10M
   ```

4. **Increase timeout (if needed):**
   Edit `commandExecutor.ts` and increase timeout from 300000ms (5 min)

5. **Test rclone manually:**
   ```bash
   time rclone bisync ~/Documents/ObsidianVault obsidian-remote:/path \
     --create-empty-src-dirs \
     --conflict-resolve newer \
     --verbose
   ```

---

### Plugin Doesn't Appear in Obsidian

**Solutions:**

1. **Check community plugins are enabled:**
   - Settings → Community plugins
   - Should show "Turn off community plugins" (meaning they're ON)

2. **Check plugin files exist:**
   ```bash
   ls ~/Documents/ObsidianVault/.obsidian/plugins/obsidian-rsync-sync/
   # Should show: main.js  manifest.json  data.json
   ```

3. **Check plugin is in enabled list:**
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

---

### Password Prompts During Sync

**Symptom:** Sync hangs and prompts for SSH key password

**Cause:** Password-protected SSH key not in SSH agent

**Solution:**

See:
- **macOS:** [SSH_AGENT_SETUP.md](./SSH_AGENT_SETUP.md)
- **Linux:** [LINUX_SSH_SETUP.md](./LINUX_SSH_SETUP.md)

**Quick fix:**
```bash
# Add key to agent
ssh-add ~/.ssh/your_key

# Verify
ssh-add -l
```

---

## Diagnostic Commands

### Check Everything is Set Up Correctly

```bash
# 1. Check vault exists
ls -la ~/Documents/ObsidianVault

# 2. Check plugin is installed
ls -la ~/Documents/ObsidianVault/.obsidian/plugins/obsidian-rsync-sync/

# 3. Check SSH key exists
ls -la ~/.ssh/obsidian_sync_ed25519  # or your key

# 4. Check SSH key is in agent (if password-protected)
ssh-add -l

# 5. Test SSH connection
ssh -i ~/.ssh/your_key obsidian-sync@your-server

# 6. Test rclone
rclone ls obsidian-remote:

# 7. Check rclone config
cat ~/.config/rclone/rclone.conf

# 8. Test bisync manually
cd ~/Documents/ObsidianVault
rclone bisync . obsidian-remote:/path --dry-run -v
```

---

## Getting Help

**When asking for help, include:**

1. **The error from Developer Console:**
   - Open Console (`Cmd+Opt+I`)
   - Copy the full error message

2. **Plugin settings:**
   - Settings → Rsync Sync
   - Screenshot or copy settings (hide sensitive info)

3. **Test commands output:**
   ```bash
   ssh -vvv -i ~/.ssh/your_key obsidian-sync@your-server
   # Share the output (hide sensitive info)

   rclone ls obsidian-remote: -vv
   # Share the output
   ```

4. **Your platform:**
   - macOS or Linux?
   - Desktop environment (if Linux)
   - Home-manager config (relevant parts)

---

## Reset Everything (Last Resort)

If nothing works, start fresh:

```bash
# 1. Stop background sync (if running)
# macOS:
launchctl unload ~/Library/LaunchAgents/org.nix-community.home.obsidian-sync.plist
# Linux:
systemctl --user stop obsidian-sync.timer

# 2. Remove bisync state
rm -rf ~/.cache/rclone/bisync/

# 3. Resync
cd ~/Documents/ObsidianVault
rclone bisync . obsidian-remote:/path --resync --dry-run -v
# If looks good:
rclone bisync . obsidian-remote:/path --resync

# 4. Restart Obsidian

# 5. Check logs in Developer Console
```

---

## Enable Maximum Debugging

For persistent issues:

1. **Enable debug mode:**
   - Command Palette → "Rsync Sync: Toggle Debug Logging"

2. **Open Developer Console:**
   - `Cmd+Opt+I` (macOS) or `Ctrl+Shift+I` (Linux)

3. **Keep Console open while using Obsidian**

4. **Trigger sync:**
   - Command Palette → "Rsync Sync: Trigger Manual Sync"

5. **Copy all output from Console**

6. **Share for troubleshooting**
