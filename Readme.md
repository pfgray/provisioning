

To provision the environment, run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake "github:pfgray/provisioning#<config-key>"
```


Or, you can clone locally & make changes, and then run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#<config-key>"
```
