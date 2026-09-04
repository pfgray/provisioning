# FRP Reverse Proxy Client

A home-manager module for [frp](https://github.com/fatedier/frp) (fast reverse proxy) with a convenient `proxy` CLI wrapper.

## What is this?

This module provides a self-hosted alternative to ngrok for temporarily exposing local development servers to the internet. It tunnels a local port (e.g., `localhost:3000`) through your home server and makes it accessible at `local.paulgray.net`.

**Architecture:**
```
Laptop (frpc) --tunnel--> Home server (frps) <--nginx-- Internet
     ↑                                                      ↓
localhost:3000                              https://local.paulgray.net
```

## Setup

### 1. Enable the module

In your home-manager configuration:

```nix
{
  config.frp = {
    enable = true;
    configText = ''
      serverAddr = "your-server.example.com"
      serverPort = 7000

      auth.method = "token"
      auth.token = "{{ .Envs.FRP_TOKEN }}"

      [[proxies]]
      name = "local-debug"
      type = "tcp"
      localIP = "127.0.0.1"
      localPort = {{ .Envs.FRP_LOCAL_PORT }}
      remotePort = 6000
    '';
  };
}
```

The configuration uses [frp's Go template syntax](https://gofrp.org/en/docs/reference/client-configures/) for environment variable substitution:
- `{{ .Envs.FRP_TOKEN }}` - Auth token (see below)
- `{{ .Envs.FRP_LOCAL_PORT }}` - Local port to expose (set by the `proxy` command)

### 2. Store your auth token

Create a secret file with your frp server's auth token:

```bash
mkdir -p ~/.secrets
echo -n "your-secret-token-here" > ~/.secrets/frp-token
chmod 600 ~/.secrets/frp-token
```

Alternatively, set the `FRP_TOKEN` environment variable when running the command.

### 3. Apply the configuration

```bash
home-manager switch
```

## Usage

### Basic usage

```bash
# Expose localhost:3000 (default port)
proxy

# Expose a different port
proxy -p 4000
```

The tunnel will run in the foreground. Press Ctrl+C to stop.

### Command options

```
Usage: proxy [-p PORT]

Options:
  -p PORT    Local port to expose (default: 3000)
  -h         Show help

Environment:
  FRP_TOKEN  Auth token (or store in ~/.secrets/frp-token)
```

### Tab completion

This module includes a [tabry](https://github.com/evanbattaglia/tabry) completion file for the `proxy` command. If you have tabry enabled in your home-manager config, you'll get tab completion for the `-p` flag.

## How it works

1. The `proxy` command reads `FRP_TOKEN` from `~/.secrets/frp-token` (or the environment)
2. It sets `FRP_LOCAL_PORT` based on the `-p` flag (default: 3000)
3. It runs `frpc -c ~/.config/frp/frpc.toml`, which connects to your frp server
4. The frp server forwards incoming traffic to your laptop's local port
5. Your local dev server is now accessible at your configured public URL

## Configuration

The module creates two main components:

1. **`~/.config/frp/frpc.toml`** - frpc client configuration (generated from `configText`)
2. **`proxy` command** - Convenience wrapper installed to `$PATH`

### Customizing the config

You can customize any frpc settings via the `configText` option. See the [frp documentation](https://gofrp.org/en/docs/reference/client-configures/) for all available options.

Common customizations:
- Change `remotePort` if your server uses a different port
- Add multiple `[[proxies]]` sections for different tunnels
- Use `type = "http"` or `type = "https"` instead of `"tcp"`

## Troubleshooting

### "FRP_TOKEN not set and ~/.secrets/frp-token not found"

Create the token file as described in step 2 of Setup, or set the `FRP_TOKEN` environment variable:

```bash
FRP_TOKEN=your-token proxy -p 3000
```

### "Port must be a number"

The `-p` flag requires a numeric port between 1 and 65535:

```bash
proxy -p 3000  # ✓ correct
proxy -p foo   # ✗ error
```

### "unmarshal ProxyConfig error"

This usually means the `frpc.toml` configuration is invalid. Check that:
- `localPort` is unquoted (it must be an integer, not a string)
- Environment variables are properly set
- The TOML syntax is valid

### Connection refused

If frpc can't connect to the server:
1. Verify the server is running: `curl http://your-server:7000` (should refuse or timeout, not resolve error)
2. Check firewall rules allow port 7000
3. Verify `serverAddr` and `serverPort` in your config are correct

## Server setup

This module only handles the **client side** (frpc). You'll need a working frp server (frps) to tunnel through. See `~/Documents/handoff.md` for details on the server-side Docker/NixOS setup.
