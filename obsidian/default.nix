{ config, lib, pkgs, ... }:

with lib;

let
  rsyncSyncPlugin = import ./plugin { inherit pkgs; };

  # Default vault path based on platform
  defaultVaultPath =
    if pkgs.stdenv.isDarwin
    then "${config.home.homeDirectory}/Documents/ObsidianVault"
    else "${config.home.homeDirectory}/obsidian-vault";

in {
  imports = [
    ./background-sync.nix
  ];

  options.obsidian = {
    enable = mkEnableOption "Obsidian with rsync sync";

    vaultPath = mkOption {
      type = types.str;
      default = defaultVaultPath;
      description = "Local path to Obsidian vault";
      example = "\${config.home.homeDirectory}/my-vault";
    };

    useGnomeKeyring = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable GNOME Keyring for SSH agent (Linux only).
        Provides automatic password management for SSH keys.
        Recommended for GNOME-based desktops.
      '';
    };

    sync = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic syncing";
      };

      remoteHost = mkOption {
        type = types.str;
        default = "";
        description = "Remote NixOS server hostname";
      };

      remoteUser = mkOption {
        type = types.str;
        default = "obsidian-sync";
        description = "SSH user for rsync";
      };

      remotePath = mkOption {
        type = types.str;
        default = "";
        description = "Remote vault directory path";
      };

      sshKeyPath = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.ssh/obsidian_sync_ed25519";
        description = ''
          SSH key for passwordless sync.
          Set to your default SSH key (e.g., "~/.ssh/id_ed25519") to use existing key.
          If the file doesn't exist, a new key will be generated.
        '';
      };

      pullIntervalMinutes = mkOption {
        type = types.int;
        default = 5;
        description = "How often to check for remote changes (in minutes)";
      };

      debounceSeconds = mkOption {
        type = types.int;
        default = 5;
        description = "Wait time after last change before syncing (in seconds)";
      };

      conflictStrategy = mkOption {
        type = types.enum [ "newest" "server" "client" ];
        default = "newest";
        description = "How to resolve conflicts (newest, server, client)";
      };
    };
  };

  config = mkIf (config.provisioning.enableGui && config.obsidian.enable) {
    # Install Obsidian and rclone
    home.packages = with pkgs; [ obsidian rclone ];

    # Create vault directory and .obsidian structure
    home.activation.obsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
      VAULT="${config.obsidian.vaultPath}"

      if [ ! -d "$VAULT" ]; then
        $DRY_RUN_CMD mkdir -p "$VAULT"
        $DRY_RUN_CMD echo "# My Obsidian Vault" > "$VAULT/README.md"
        echo "Created Obsidian vault at $VAULT"
      fi

      # Create .obsidian directory structure
      $DRY_RUN_CMD mkdir -p "$VAULT/.obsidian/plugins"

      # Enable community plugins list
      PLUGINS_FILE="$VAULT/.obsidian/community-plugins.json"
      if [ ! -f "$PLUGINS_FILE" ]; then
        # Create new file with our plugin
        $DRY_RUN_CMD echo '["obsidian-rsync-sync"]' > "$PLUGINS_FILE"
      else
        # Add our plugin to existing list if not already there
        if ! grep -q "obsidian-rsync-sync" "$PLUGINS_FILE"; then
          # Read existing plugins, add ours, write back
          $DRY_RUN_CMD ${pkgs.jq}/bin/jq '. += ["obsidian-rsync-sync"]' "$PLUGINS_FILE" > "$PLUGINS_FILE.tmp"
          $DRY_RUN_CMD mv "$PLUGINS_FILE.tmp" "$PLUGINS_FILE"
        fi
      fi
    '';

    # Install custom plugin to vault's plugin directory
    home.file."${config.obsidian.vaultPath}/.obsidian/plugins/obsidian-rsync-sync" = mkIf config.obsidian.sync.enable {
      source = rsyncSyncPlugin;
      recursive = true;
    };

    # Plugin settings (data.json) in vault
    home.file."${config.obsidian.vaultPath}/.obsidian/plugins/obsidian-rsync-sync/data.json" = mkIf config.obsidian.sync.enable {
      text = builtins.toJSON {
        enabled = true;
        rclonePath = "${pkgs.rclone}/bin/rclone";
        remoteHost = config.obsidian.sync.remoteHost;
        remoteUser = config.obsidian.sync.remoteUser;
        remotePath = config.obsidian.sync.remotePath;
        sshKeyPath = config.obsidian.sync.sshKeyPath;
        pullIntervalMinutes = config.obsidian.sync.pullIntervalMinutes;
        debounceSeconds = config.obsidian.sync.debounceSeconds;
        conflictStrategy = config.obsidian.sync.conflictStrategy;
        excludePatterns = [".trash" ".git" ".obsidian/workspace*"];
        syncOnStartup = true;
        syncOnFileChange = true;
      };
    };

    # SSH key generation
    home.activation.obsidianSyncKey = mkIf config.obsidian.sync.enable (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        KEYPATH="${config.obsidian.sync.sshKeyPath}"
        if [ ! -f "$KEYPATH" ]; then
          $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen \
            -t ed25519 \
            -f "$KEYPATH" \
            -N "" \
            -C "obsidian-sync-$(hostname)"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "New SSH key created for Obsidian sync."
          echo "Add this public key to your NixOS server:"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          cat "$KEYPATH.pub"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
      ''
    );

    # Rclone config for SFTP remote (writable file, not symlink)
    home.activation.rcloneConfig = mkIf config.obsidian.sync.enable (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        RCLONE_CONFIG="${config.home.homeDirectory}/.config/rclone/rclone.conf"
        $DRY_RUN_CMD mkdir -p "$(dirname "$RCLONE_CONFIG")"

        # Only create if it doesn't exist, to preserve any rclone-managed settings
        if [ ! -f "$RCLONE_CONFIG" ]; then
          $DRY_RUN_CMD cat > "$RCLONE_CONFIG" << EOF
[obsidian-remote]
type = sftp
host = ${config.obsidian.sync.remoteHost}
user = ${config.obsidian.sync.remoteUser}
shell_type = unix
# Note: key_file is intentionally omitted to use SSH agent
# This allows password-protected keys to work via ssh-agent
EOF
          echo "Created rclone config at $RCLONE_CONFIG"
        fi
      ''
    );

    # SSH config
    programs.ssh.matchBlocks = mkIf config.obsidian.sync.enable {
      "obsidian-sync" = {
        host = config.obsidian.sync.remoteHost;
        user = config.obsidian.sync.remoteUser;
        identityFile = config.obsidian.sync.sshKeyPath;
        identitiesOnly = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };

    # SSH agent configuration (platform-specific)
    programs.ssh.extraConfig = mkIf config.obsidian.sync.enable ''
      ${optionalString pkgs.stdenv.isDarwin ''
      # macOS: Use Keychain for SSH keys (supports password-protected keys)
      # This retrieves passphrases from Keychain automatically after reboot
      UseKeychain yes
      ''}

      # Automatically add keys to agent when they're used
      AddKeysToAgent yes
    '';

    # macOS: Auto-load SSH keys from Keychain on login
    # This eliminates the need to run ssh-add after reboot
    launchd.agents.ssh-add-keychain = mkIf (pkgs.stdenv.isDarwin && config.obsidian.sync.enable) {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.openssh}/bin/ssh-add"
          "--apple-load-keychain"
        ];
        RunAtLoad = true;
        StandardErrorPath = "/dev/null";
        StandardOutPath = "/dev/null";
      };
    };

    # Linux Option 1: GNOME Keyring (recommended for GNOME desktops)
    # Provides automatic password management similar to macOS Keychain
    services.gnome-keyring = mkIf (pkgs.stdenv.isLinux && config.obsidian.sync.enable && config.obsidian.useGnomeKeyring) {
      enable = true;
      components = [ "ssh" "secrets" ];
    };

    # Linux Option 2: Plain ssh-agent service (for non-GNOME desktops)
    # Requires manual ssh-add after reboot, but more universal
    services.ssh-agent.enable = mkIf (pkgs.stdenv.isLinux && config.obsidian.sync.enable && !config.obsidian.useGnomeKeyring) true;
  };
}
