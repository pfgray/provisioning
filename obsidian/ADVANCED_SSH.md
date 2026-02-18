# Advanced SSH Configuration for Obsidian Sync

This guide covers advanced SSH configuration options for the Obsidian sync setup.

## Configuration Methods

There are three places to configure SSH options:

1. **SSH Config** (`programs.ssh.matchBlocks`) - Best for SSH-level options
2. **Rclone Config** (`xdg.configFile."rclone/rclone.conf"`) - Best for SFTP-specific options
3. **Plugin Settings** - Runtime configuration

## Common Use Cases

### 1. Custom SSH Port

If your server uses a non-standard SSH port:

**In `provisioning/obsidian/default.nix`:**

```nix
# SSH config
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    host = config.obsidian.sync.remoteHost;
    port = 2222;  # Add this
    # ... rest of config
  };
};

# Rclone config
xdg.configFile."rclone/rclone.conf" = mkIf config.obsidian.sync.enable {
  text = ''
    [obsidian-remote]
    type = sftp
    host = ${config.obsidian.sync.remoteHost}
    port = 2222
    # ... rest of config
  '';
};
```

### 2. Enable Compression (for slow networks)

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    # ... existing config
    compression = true;
    compressionLevel = 6;  # 1-9, higher = more compression
  };
};
```

### 3. Connection Keepalive (for NAT/firewalls)

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    # ... existing config
    serverAliveInterval = 30;  # Send keepalive every 30s
    serverAliveCountMax = 5;   # Disconnect after 5 failed keepalives
    tcpKeepAlive = true;       # Enable TCP keepalives
  };
};
```

### 4. Jump Host / Bastion

If you need to go through a jump host:

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-jump" = {
    host = "jump.example.com";
    user = "jumpuser";
    identityFile = "~/.ssh/jump_key";
  };

  "obsidian-sync" = {
    host = config.obsidian.sync.remoteHost;
    user = config.obsidian.sync.remoteUser;
    identityFile = config.obsidian.sync.sshKeyPath;
    proxyJump = "obsidian-jump";  # Use jump host
  };
};
```

### 5. Performance Tuning

For high-speed networks:

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    # ... existing config

    # Use faster ciphers (less secure but faster)
    ciphers = [
      "aes128-gcm@openssh.com"
      "chacha20-poly1305@openssh.com"
    ];

    # Disable compression on fast networks
    compression = false;
  };
};

# In rclone config:
xdg.configFile."rclone/rclone.conf" = mkIf config.obsidian.sync.enable {
  text = ''
    [obsidian-remote]
    # ... existing config
    use_fstat = false  # Better for small files
    concurrency = 4    # Parallel transfers
  '';
};
```

### 6. Multiple SSH Keys

If you have multiple keys:

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    # ... existing config
    identityFile = [
      config.obsidian.sync.sshKeyPath
      "~/.ssh/backup_key"
    ];
    identitiesOnly = true;
  };
};
```

### 7. Strict Host Key Checking

For production (recommended):

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    # ... existing config
    strictHostKeyChecking = "yes";
    userKnownHostsFile = "~/.ssh/known_hosts";
  };
};
```

For testing (NOT recommended for production):

```nix
programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
  "obsidian-sync" = {
    # ... existing config
    strictHostKeyChecking = "no";  # INSECURE - testing only
  };
};
```

## Available SSH Options

### Connection Options
- `port` - SSH port (default: 22)
- `connectTimeout` - Connection timeout in seconds
- `connectionAttempts` - Number of connection attempts
- `tcpKeepAlive` - Enable TCP keepalives

### Authentication Options
- `identityFile` - Path to SSH private key
- `identitiesOnly` - Only use specified identities
- `passwordAuthentication` - Enable/disable password auth
- `pubkeyAuthentication` - Enable/disable pubkey auth

### Performance Options
- `compression` - Enable SSH compression
- `compressionLevel` - Compression level (1-9)
- `ciphers` - List of allowed ciphers
- `macs` - List of allowed MACs

### Advanced Options
- `proxyJump` - Jump host
- `proxyCommand` - Custom proxy command
- `forwardAgent` - Enable SSH agent forwarding
- `serverAliveInterval` - Keepalive interval
- `serverAliveCountMax` - Max failed keepalives

## Rclone SFTP Options

Available in `rclone.conf`:

```ini
[obsidian-remote]
type = sftp
host = server.example.com
port = 22
user = obsidian-sync
key_file = /path/to/key

# Performance
use_fstat = false           # Better for small files
concurrency = 4             # Parallel transfers
chunk_size = 32M            # Upload chunk size

# Behavior
set_modtime = true          # Preserve modification times
md5sum_command = md5sum     # MD5 checksum command
sha1sum_command = sha1sum   # SHA1 checksum command

# Security
disable_hashcheck = false   # Enable hash checking
use_insecure_cipher = false # Disable insecure ciphers

# Advanced
shell_type = unix           # Shell type (unix, powershell)
ssh_command = /path/to/ssh  # Custom SSH binary
```

## Testing Your Configuration

After making changes:

```bash
# Rebuild home-manager
cd ~/dev/hm/local-provisioning
home-manager switch

# Test SSH connection
ssh obsidian-sync  # Uses the match block

# Test rclone
rclone lsd obsidian-remote:

# Test with verbose output
rclone lsd obsidian-remote: -vv

# Test bisync (dry run)
cd ~/Documents/ObsidianVault
rclone bisync . obsidian-remote:/srv/obsidian-vaults/paul.gray --dry-run -vv
```

## Troubleshooting

### Connection Times Out

```nix
programs.ssh.matchBlocks.obsidian-sync = {
  connectTimeout = 60;
  serverAliveInterval = 30;
  serverAliveCountMax = 5;
};
```

### Slow Sync Performance

```nix
# Enable compression for slow networks
compression = true;

# OR disable compression for fast networks
compression = false;

# Use faster ciphers
ciphers = ["aes128-gcm@openssh.com"];
```

### Connection Drops Frequently

```nix
serverAliveInterval = 15;  # More frequent keepalives
tcpKeepAlive = true;
```

### Key Authentication Fails

```nix
identitiesOnly = true;  # Only use specified key
# Check key permissions: chmod 600 ~/.ssh/obsidian_sync_ed25519
```

## Example: Complete Advanced Configuration

Here's a full example with common optimizations:

```nix
{ config, lib, pkgs, ... }:

# ... existing module code ...

config = mkIf (config.provisioning.enableGui && config.obsidian.enable) {
  # ... existing config ...

  # Optimized SSH config
  programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
    "obsidian-sync" = {
      host = config.obsidian.sync.remoteHost;
      user = config.obsidian.sync.remoteUser;
      port = 22;

      # Authentication
      identityFile = config.obsidian.sync.sshKeyPath;
      identitiesOnly = true;

      # Connection keepalive
      serverAliveInterval = 30;
      serverAliveCountMax = 5;
      tcpKeepAlive = true;

      # Performance (choose based on your network)
      compression = true;           # Enable for slow networks
      compressionLevel = 6;

      # Fast ciphers (good balance of speed/security)
      ciphers = [
        "aes128-gcm@openssh.com"
        "aes256-gcm@openssh.com"
        "chacha20-poly1305@openssh.com"
      ];

      # Connection
      connectTimeout = 30;
      connectionAttempts = 3;
    };
  };

  # Optimized rclone config
  xdg.configFile."rclone/rclone.conf" = mkIf config.obsidian.sync.enable {
    text = ''
      [obsidian-remote]
      type = sftp
      host = ${config.obsidian.sync.remoteHost}
      user = ${config.obsidian.sync.remoteUser}
      port = 22
      key_file = ${config.obsidian.sync.sshKeyPath}
      shell_type = unix

      # Performance tuning
      use_fstat = false
      concurrency = 4

      # Behavior
      set_modtime = true
      md5sum_command = md5sum
      sha1sum_command = sha1sum
      disable_hashcheck = false
    '';
  };
};
```

## See Also

- SSH config options: `man ssh_config`
- Rclone SFTP docs: https://rclone.org/sftp/
- Main README: `provisioning/obsidian/README.md`
