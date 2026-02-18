# Linux SSH Agent Setup for Obsidian Sync

This guide covers automatic SSH key management on Linux for password-protected keys.

## The Problem

Password-protected SSH keys won't work for automatic sync because:
- The plugin runs in the background (can't prompt for password)
- Background sync service is unattended
- SSH operations would hang waiting for password

## Solutions for Linux

### Option 1: GNOME Keyring (Recommended for GNOME/Ubuntu/Fedora)

**Best for:** GNOME, Ubuntu, Fedora, Pop!_OS, and similar desktop environments

**How it works:** GNOME Keyring acts like macOS Keychain - it securely stores your SSH key password and automatically unlocks your key when you log in.

#### Configuration

```nix
{
  config.obsidian = {
    enable = true;
    useGnomeKeyring = true;  # Enable GNOME Keyring

    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";

      # Use your password-protected key
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };
}
```

#### Setup Steps

1. **Deploy the configuration:**
   ```bash
   cd ~/dev/hm/local-provisioning
   home-manager switch
   ```

2. **Add your key to GNOME Keyring (one-time):**
   ```bash
   # The first time you use SSH after login, you'll be prompted for password
   ssh-add ~/.ssh/id_rsa
   ```

   A GUI dialog will appear asking for your password and offering to save it to the keyring:
   - ✅ Check "Automatically unlock this key when I log in"
   - Enter your SSH key password
   - Click "OK"

3. **Verify:**
   ```bash
   # Check if key is loaded
   ssh-add -l

   # Test SSH without password
   ssh your-server
   ```

4. **After reboot:**
   Your key is automatically loaded - no manual `ssh-add` needed!

#### What Gets Installed

- GNOME Keyring daemon (SSH component)
- Integration with your desktop session
- Automatic key loading on login
- Secure password storage

#### Troubleshooting

**Key not loading after reboot:**
```bash
# Check if GNOME Keyring SSH agent is running
echo $SSH_AUTH_SOCK
# Should show: /run/user/1000/keyring/ssh

# If not, check service status
systemctl --user status gnome-keyring-daemon
```

**Seahorse (GUI) for managing keys:**
```bash
# Install Seahorse to view/manage stored passwords
# Already available on most GNOME systems
seahorse

# Navigate to: Passwords → Login keyring
# You should see your SSH key password stored here
```

---

### Option 2: KDE Wallet (For KDE Plasma Users)

**Best for:** KDE Plasma, Kubuntu, KDE Neon

KDE Wallet provides similar functionality to GNOME Keyring.

#### Configuration

```nix
{
  config.obsidian = {
    enable = true;

    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };

  # Enable KDE integration
  programs.ssh = {
    enable = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  # KDE Wallet SSH integration
  services.kwalletd.enable = true;
}
```

#### Setup Steps

1. Deploy configuration
2. First SSH connection will prompt for password via KDE dialog
3. Choose "Remember password" in KDE Wallet
4. Key automatically loads on subsequent logins

---

### Option 3: Plain ssh-agent (Any Desktop Environment)

**Best for:** i3, Sway, XFCE, LXQt, or minimal setups

This provides a basic SSH agent but requires manual password entry once per session.

#### Configuration

```nix
{
  config.obsidian = {
    enable = true;
    useGnomeKeyring = false;  # Use plain ssh-agent

    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };
}
```

This is the **default** for Linux if you don't set `useGnomeKeyring = true`.

#### Setup Steps

1. Deploy configuration
2. After login, manually add your key:
   ```bash
   ssh-add ~/.ssh/id_rsa
   # Enter password
   ```
3. Key remains in agent until logout/reboot

**Limitation:** You must run `ssh-add` after every reboot.

#### Auto-add on First SSH Use

You can configure SSH to automatically add keys when first used:

```nix
programs.ssh.extraConfig = ''
  AddKeysToAgent yes
'';
```

Then the first time you SSH after reboot, you'll be prompted for password, and the key will be added to the agent for the session.

---

### Option 4: Keychain (Universal Solution)

**Best for:** Any desktop environment, works everywhere

[Keychain](https://www.funtoo.org/Keychain) is a frontend for ssh-agent that manages agent lifetimes.

#### Configuration

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_rsa";
    };
  };

  # Enable keychain
  programs.keychain = {
    enable = true;
    agents = [ "ssh" ];
    keys = [ "id_rsa" ];  # Your key names
  };
}
```

#### How it Works

- First login: prompts for password once
- Creates persistent ssh-agent across sessions
- Subsequent logins: no password needed (agent persists)

---

### Option 5: systemd User Service (Advanced)

**Best for:** Custom setups, specific requirements

Create a systemd user service to manage ssh-agent persistently:

```nix
{
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
}
```

Then add keys manually after reboot:
```bash
ssh-add ~/.ssh/id_rsa
```

---

## Comparison Table

| Solution | Auto-load Keys | Password Storage | Desktop Requirement | Complexity |
|----------|----------------|------------------|---------------------|------------|
| **GNOME Keyring** | ✅ Yes | ✅ Secure GUI storage | GNOME | ⭐ Easy |
| **KDE Wallet** | ✅ Yes | ✅ Secure GUI storage | KDE Plasma | ⭐ Easy |
| **Keychain** | ✅ Yes | ❌ Prompts once per boot | Any | ⭐⭐ Medium |
| **Plain ssh-agent** | ❌ No | ❌ Manual each boot | Any | ⭐ Easy |
| **systemd service** | ❌ No | ❌ Manual each boot | Any | ⭐⭐⭐ Advanced |

## Recommended Approach by Desktop

### GNOME / Ubuntu / Fedora / Pop!_OS
```nix
config.obsidian.useGnomeKeyring = true;
```
✅ Automatic, secure, integrated

### KDE Plasma / Kubuntu
Enable KDE Wallet integration (see Option 2)

### i3 / Sway / XFCE / Minimal
Use Keychain (Option 4) for best experience

### Any Desktop (Fallback)
Use plain ssh-agent (default) and run `ssh-add` after reboot

---

## Testing Your Setup

After configuration and reboot:

```bash
# 1. Check if SSH agent is running
echo $SSH_AUTH_SOCK
# Should show a socket path

# 2. Check if keys are loaded
ssh-add -l
# Should list your key if auto-load is working

# 3. Test SSH without password
ssh -T git@github.com
# or
ssh your-server

# 4. Test rclone (what Obsidian uses)
rclone ls obsidian-remote:
```

If any prompt for password, automatic sync won't work.

---

## Complete Example Configurations

### Example 1: GNOME Desktop with Auto-load

```nix
{
  config.obsidian = {
    enable = true;
    useGnomeKeyring = true;  # Auto-load keys from keyring

    vaultPath = "${config.home.homeDirectory}/Documents/Vault";

    sync = {
      enable = true;
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";

      backgroundSync = {
        enable = true;
        interval = "5min";
      };
    };
  };
}
```

**Setup:**
1. Deploy: `home-manager switch`
2. First SSH: `ssh-add ~/.ssh/id_ed25519` (prompted for password once)
3. Check "Remember password" in GNOME dialog
4. Reboot - key auto-loads!

### Example 2: Minimal i3 Setup with Keychain

```nix
{
  programs.keychain = {
    enable = true;
    agents = [ "ssh" ];
    keys = [ "id_ed25519" ];
  };

  config.obsidian = {
    enable = true;
    # useGnomeKeyring not needed

    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
      sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };
  };
}
```

**Setup:**
1. Deploy: `home-manager switch`
2. First login: Enter password for keychain
3. Subsequent logins: No password needed

### Example 3: Passwordless Key (Simplest)

```nix
{
  config.obsidian = {
    enable = true;
    sync = {
      remoteHost = "vault.example.com";
      remotePath = "/srv/obsidian-vaults/paul.gray";
      # Don't specify sshKeyPath - generates passwordless key
    };
  };
}
```

**Setup:**
1. Deploy: `home-manager switch`
2. Copy printed public key to server
3. Done - works automatically!

---

## Troubleshooting

### SSH agent not found

**Symptom:**
```bash
ssh-add -l
# Could not open a connection to your authentication agent
```

**Solutions:**

1. **Check if agent is running:**
   ```bash
   ps aux | grep ssh-agent
   ```

2. **Check environment variable:**
   ```bash
   echo $SSH_AUTH_SOCK
   # Should show a socket path
   ```

3. **Reload session:**
   ```bash
   # Log out and log back in
   # OR
   source ~/.profile
   ```

### Key not auto-loading

**GNOME Keyring:**
```bash
# Check if GNOME Keyring SSH is enabled
ls -la /run/user/$(id -u)/keyring/

# Restart GNOME Keyring
killall gnome-keyring-daemon
# Log out and log back in
```

**Keychain:**
```bash
# Check keychain status
keychain --list

# View keychain files
ls -la ~/.keychain/
```

### Password prompted every time

This means the password isn't being stored. Solutions:

1. **GNOME:** Make sure to check "Remember password" in the unlock dialog
2. **Keychain:** Check keychain configuration is correct
3. **Fallback:** Use a passwordless key for Obsidian

---

## Security Considerations

### GNOME Keyring / KDE Wallet
- ✅ Secure: Encrypted with your login password
- ✅ Auto-locks when you log out
- ✅ Integrated with desktop security
- ⚠️ Accessible if someone gains access while you're logged in

### Keychain
- ✅ Persistent agent (survives screen lock)
- ⚠️ Agent remains running until explicit shutdown
- 🔒 Secure in encrypted home directory

### Passwordless Key
- ⚠️ Key is unencrypted on disk
- 🔒 Mitigate with SSH key restrictions on server
- 🔒 Use full disk encryption
- ✅ Can't be "forgotten" or expire

**Recommendation:** GNOME Keyring (or KDE Wallet) provides the best security/usability balance on Linux.

---

## Quick Decision Guide

**"I use GNOME/Ubuntu"**
→ Set `useGnomeKeyring = true` ✅

**"I use KDE Plasma"**
→ Enable KDE Wallet integration ✅

**"I use i3/Sway/XFCE"**
→ Use keychain (Option 4) ✅

**"I want simplest setup"**
→ Let it generate a passwordless key ✅

**"I don't mind running ssh-add after reboot"**
→ Use plain ssh-agent (default) ✅
