{ pkgs, config, lib, ... }:

let
  proxy = pkgs.writeShellScriptBin "proxy" ''
    set -euo pipefail

    PORT=3000
    SECRET_FILE="$HOME/.secrets/frp-token"

    usage() {
      echo "Usage: proxy [-p PORT]"
      echo ""
      echo "Start an FRP tunnel to expose a local port at local.paulgray.net"
      echo ""
      echo "Options:"
      echo "  -p PORT    Local port to expose (default: 3000)"
      echo ""
      echo "Environment:"
      echo "  FRP_TOKEN  Auth token (or store in ~/.secrets/frp-token)"
      exit 1
    }

    while getopts ":p:h" opt; do
      case $opt in
        p)
          PORT="$OPTARG"
          ;;
        h)
          usage
          ;;
        \?)
          echo "Error: Invalid option -$OPTARG" >&2
          usage
          ;;
        :)
          echo "Error: Option -$OPTARG requires an argument" >&2
          usage
          ;;
      esac
    done

    # Validate port is a number
    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
      echo "Error: Port must be a number, got '$PORT'" >&2
      exit 1
    fi

    # Validate port range
    if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
      echo "Error: Port must be between 1 and 65535" >&2
      exit 1
    fi

    # Get token from env var or secret file
    if [ -z "''${FRP_TOKEN:-}" ]; then
      if [ -f "$SECRET_FILE" ]; then
        FRP_TOKEN="$(cat "$SECRET_FILE")"
      else
        echo "Error: FRP_TOKEN not set and $SECRET_FILE not found" >&2
        echo "Either set FRP_TOKEN or create $SECRET_FILE with your token" >&2
        exit 1
      fi
    fi

    export FRP_TOKEN
    export FRP_LOCAL_PORT="$PORT"

    echo "Starting tunnel: localhost:$PORT -> local.paulgray.net"
    exec ${pkgs.frp}/bin/frpc -c "$HOME/.config/frp/frpc.toml"
  '';
in
{
  options = {
    frp = {
      enable = lib.mkEnableOption "FRP reverse proxy client";

      configText = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Contents of the frpc.toml configuration file";
      };
    };
  };

  config = lib.mkIf config.frp.enable {
    home.packages = [
      pkgs.frp
      proxy
    ];

    home.file.".config/frp/frpc.toml".text = lib.mkIf (config.frp.configText != "") config.frp.configText;
  };
}
