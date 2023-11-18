{pkgs, ...}:

let
  terraform = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "terraform";
        publisher = "hashicorp";
        version = "2.23.0";
        sha256 = "sha256-3v2hEf/cEd7NiXfk7eJbmmdyiQJ7bWl9TuaN+y5k+e0";
      };
    };
in {
  programs.vscode = {
    enable = false;
    package = pkgs.vscode;
    keybindings = import ./keybindings.nix;
    userSettings = import ./userSettings.nix;

    extensions = with pkgs.vscode-extensions; [
      justusadam.language-haskell
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      skyapps.fish-vscode
      terraform
      esbenp.prettier-vscode
    ];
  };
}