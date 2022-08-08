

This flake contains home-manager configurations for my environment.

It specifies things like fish config files, cli programs, vscode & its plugins.

The way it works, is I create a new `flake.nix` on each machine, with the machine-specific settings for it. There's a template for this, that I initiate by running:

```sh
nix run github:pfgray/provisioning#init
```

This script prompts me for my user/home directory/system, but can make educated guesses for each of those. This 


```nix
{
  inputs = {
    provisioning.url = "github:pfgray/provisioning";
  };

  outputs = { provisioning, ... }:
    provisioning.provision {
      systemConfig = {
        system = "x86_64-linux";
        username = "paul";
        homeDirectory = "/home/paul";
      };
      overrides = {};
    };
}
```

Providing your `system`, `username`, `homeDirectory`. `overrides` wil be recursively merged with the default config, so you can use it to tweak the configs.

To provision an environment, run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#base"
```
