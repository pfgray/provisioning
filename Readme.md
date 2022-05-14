On MacOS, run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake "github:pfgray/provisioning#darwin"
```

on Linux, run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake "github:pfgray/provisioning#linux"
```


Or, if you clone locally & make changes you can run:

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#darwin"
```

```sh
nix run --impure github:nix-community/home-manager#home-manager \
  --no-write-lock-file -- switch --flake ".#linux"
```
