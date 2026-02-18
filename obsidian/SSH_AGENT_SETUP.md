# Using Password-Protected SSH Keys with Obsidian Sync

## The Problem

Password-protected SSH keys require manual password entry, which doesn't work for:
- Automatic sync when Obsidian is running
- Background sync service (when Obsidian is closed)
- Unattended sync operations

## Solutions

### Option 1: Use SSH Agent (Recommended for Existing Password-Protected Keys)

SSH agent caches your decrypted key in memory, allowing passwordless use after initial unlock.

#### macOS Setup (Built-in Keychain)

**Step 1: Add your key to macOS Keychain**

Add this to your SSH config:

```nix
# In your home-manager configuration
programs.ssh = {
  enable = true;

  extraConfig = ''
    # Use macOS Keychain for SSH keys
    UseKeychain yes
    AddKeysToAgent yes
  '';

  matchBlocks."obsidian-sync" = {
    host = config.obsidian.sync.remoteHost;
    user = config.obsidian.sync.remoteUser;
    identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    identitiesOnly = true;

    # Use SSH agent
    forwardAgent = false;
  };
};
```

**Step 2: Add key to agent (one-time)**

```bash
# Add your key to macOS Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Enter your password when prompted - it will be saved to Keychain
```

**Step 3: Verify**

```bash
# List keys in agent
ssh-add -l

# Test connection (should work without password prompt)
ssh -i ~/.ssh/id_ed25519 obsidian-sync@your-server
```

**How it works:**
- macOS Keychain stores your SSH key password
- SSH agent loads the key on login
- All SSH connections use the cached key
- Works across all applications (Obsidian, Terminal, etc.)

---

#### Linux Setup (GNOME Keyring / systemd)

**Option A: GNOME Keyring (Desktop Linux)**

```nix
# In your home-manager configuration
services.gnome-keyring = {
  enable = true;
  components = [ "ssh" ];
};

programs.ssh.extraConfig = ''
  AddKeysToAgent yes
'';
```

Then add your key:
```bash
ssh-add ~/.ssh/id_ed25519
# Enter password - saved to GNOME Keyring
```

**Option B: systemd User Service (Any Linux)**

Create a user service to start ssh-agent:

```nix
systemd.user.services.ssh-agent = {
  Unit = {
    Description = "SSH Agent";
  };

  Service = {
    Type = "simple";
    ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
    Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
  };

  Install = {
    WantedBy = [ "default.target" ];
  };
};

home.sessionVariables = {
  SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.socket";
};
```

Then:
```bash
systemctl --user enable ssh-agent
systemctl --user start ssh-agent
ssh-add ~/.ssh/id_ed25519
```

---

### Option 2: Generate Dedicated Passwordless Key (Easiest)

**Recommended for automation!**

Generate a new key specifically for Obsidian sync, without a password:

```nix
{
  config.obsidian.sync = {
    # Use default - generates ~/.ssh/obsidian_sync_ed25519
    # This key will NOT have a password
  };
}
```

Or generate manually:

```bash
# Generate new key without password
ssh-keygen -t ed25519 -f ~/.ssh/obsidian_sync -N "" -C "obsidian-sync"

# Add public key to server
cat ~/.ssh/obsidian_sync.pub
```

Then configure:
```nix
config.obsidian.sync = {
  sshKeyPath = "${config.home.homeDirectory}/.ssh/obsidian_sync";
};
```

**Benefits:**
- ✅ Works automatically, no password needed
- ✅ Isolated key - can revoke without affecting other access
- ✅ Clear purpose
- ✅ No ssh-agent setup needed

**Security consideration:**
- Key is unencrypted on disk
- Mitigate by: limiting key permissions on server (see below)

---

### Option 3: Restrict Key Permissions on Server (Security Best Practice)

If using a passwordless key, restrict what it can do on the server:

**On your NixOS server:**

```nix
# In your NixOS server configuration
users.users.obsidian-sync = {
  isSystemUser = true;
  group = "obsidian-sync";

  openssh.authorizedKeys.keys = [
    # Restricted key - can only run rclone/rsync
    ''command="${pkgs.rclone}/bin/rclone serve sftp",no-agent-forwarding,no-port-forwarding,no-pty,no-X11-forwarding ssh-ed25519 AAAAC3... obsidian-sync''
  ];
};
```

This ensures the key can ONLY be used for syncing, even if compromised.

---

## Recommended Approach by Use Case

### If You Want Maximum Security

1. Keep your default key password-protected
2. Generate a new **passwordless** dedicated key for Obsidian
3. Restrict the passwordless key on the server (command restriction)

```nix
config.obsidian.sync = {
  # Default - generates passwordless ~/.ssh/obsidian_sync_ed25519
  remoteHost = "vault.example.com";
  remotePath = "/srv/obsidian-vaults/paul.gray";
};
```

**Security layers:**
- Default key: password-protected (for interactive use)
- Obsidian key: no password BUT restricted on server
- If Obsidian key is stolen: attacker can only sync vault, nothing else

---

### If You Already Use SSH Agent

1. Set up SSH agent (macOS Keychain or GNOME Keyring)
2. Add your default key to agent
3. Configure Obsidian to use your default key

```nix
# Add to your home-manager config
programs.ssh.extraConfig = ''
  UseKeychain yes      # macOS
  AddKeysToAgent yes   # All platforms
'';

config.obsidian.sync = {
  sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
  remoteHost = "vault.example.com";
  remotePath = "/srv/obsidian-vaults/paul.gray";
};
```

Then:
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519  # macOS
# or
ssh-add ~/.ssh/id_ed25519                        # Linux
```

**Works if:**
- ✅ SSH agent is running
- ✅ Key is added to agent
- ✅ Agent persists across reboots (macOS Keychain does this)

**Doesn't work if:**
- ❌ SSH agent stops/crashes
- ❌ Key is removed from agent
- ❌ System reboots (unless using Keychain)

---

## Testing Your Setup

After configuration:

```bash
# 1. Check if key requires password
ssh-keygen -y -f ~/.ssh/your_key
# If prompted for password → key is encrypted
# If shows public key immediately → key is not encrypted

# 2. Check if key is in SSH agent
ssh-add -l
# Should show your key if in agent

# 3. Test SSH connection without password prompt
ssh -i ~/.ssh/your_key obsidian-sync@your-server
# Should connect without asking for password

# 4. Test rclone (what the plugin uses)
rclone ls obsidian-remote:
# Should work without password prompt
```

---

## Quick Decision Guide

**Choose dedicated passwordless key if:**
- You want simple, automatic sync
- You're okay with unencrypted key on disk
- You'll restrict key permissions on server

**Choose SSH agent + existing key if:**
- You want to keep all keys password-protected
- You already use SSH agent
- You understand SSH agent setup

**Don't use password-protected key without SSH agent:**
- ❌ Won't work for automatic sync
- ❌ Plugin will hang waiting for password
- ❌ Background sync will fail

---

## Summary

| Approach | Setup Complexity | Security | Automatic Sync |
|----------|------------------|----------|----------------|
| Dedicated passwordless key | ⭐ Easy | ⭐⭐⭐ Good (with restrictions) | ✅ Yes |
| SSH agent + password key | ⭐⭐ Medium | ⭐⭐⭐⭐ Excellent | ✅ Yes (if agent running) |
| Password key alone | N/A | N/A | ❌ **No - Won't work** |

**My recommendation:** Use the default (generates new passwordless key) and restrict it on the server. Simple, secure enough, and works reliably.
