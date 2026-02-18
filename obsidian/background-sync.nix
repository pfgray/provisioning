{ config, lib, pkgs, ... }:

with lib;

# Background sync service that runs independently of Obsidian
# This ensures your vault stays synced even when Obsidian is closed

let
  syncScript = pkgs.writeShellScript "obsidian-sync" ''
    set -e

    VAULT_PATH="${config.obsidian.vaultPath}"
    REMOTE="obsidian-remote:${config.obsidian.sync.remotePath}"

    # Check if vault exists
    if [ ! -d "$VAULT_PATH" ]; then
      echo "Vault directory does not exist: $VAULT_PATH"
      exit 1
    fi

    # Run rclone bisync
    ${pkgs.rclone}/bin/rclone bisync \
      "$VAULT_PATH" \
      "$REMOTE" \
      --create-empty-src-dirs \
      --compare size,modtime,checksum \
      --conflict-resolve ${config.obsidian.sync.conflictStrategy} \
      --resilient \
      --recover \
      --max-delete 10 \
      --exclude ".trash/**" \
      --exclude ".git/**" \
      --exclude ".obsidian/workspace*" \
      --log-level INFO
  '';

in {
  options.obsidian.sync.backgroundSync = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable background sync service (syncs even when Obsidian is closed)";
    };

    interval = mkOption {
      type = types.str;
      default = "5min";
      description = "How often to sync in the background (systemd timer format: 5min, 10min, 1h, etc.)";
    };
  };

  config = mkIf (config.obsidian.enable && config.obsidian.sync.enable && config.obsidian.sync.backgroundSync.enable) {
    # macOS: launchd service
    launchd.agents.obsidian-sync = mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [ "${syncScript}" ];
        StartInterval = 300; # 5 minutes in seconds
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/obsidian-sync.log";
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/obsidian-sync.log";
      };
    };

    # Linux: systemd service
    systemd.user.services.obsidian-sync = mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "Obsidian vault background sync";
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${syncScript}";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.timers.obsidian-sync = mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "Obsidian vault sync timer";
      };

      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = config.obsidian.sync.backgroundSync.interval;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
