{pkgs, ...}:

{
    imports = [
        ./home-common-module.nix
        ./fish/fish.nix
        ./vscode/vscode.nix
        ./langs/nix.nix
        ./langs/ruby.nix
    ];
}