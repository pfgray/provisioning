This flake contains home-manager configurations for my environment.

It specifies things like fish config files, cli programs, vscode & its plugins.

The way it works, is I create a new `flake.nix` on each machine, with the machine-specific settings for it. There's a template for this, that I initiate by running:

```sh
nix run github:pfgray/provisioning#init
```

This script prompts me for my user/home directory/system, but can make educated guesses for each of those. This creates a `flake.nix` file which is setup to pull in the configurations form this repo. I then add any customizations to that flake which might not belong on other machines (i.e. proprietary work tools).

To apply the settings, run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#base"
```
