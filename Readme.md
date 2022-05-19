
Use this flake to pull in common provisioning configs.
Define a flake locally which looks like:

```
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

For Linux:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#linux"
```

For MacOS:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#darwin"
```
