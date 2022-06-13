{pkgs, lib, ...}:

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
    enable = true;
    package = pkgs.vscode;
    keybindings = import ./keybindings.nix;
    # userSettings = {
    #   "terraform-ls.terraformExecPath": pkgs.terraform-ls
    # };
    extensions = with pkgs.vscode-extensions; [
      justusadam.language-haskell
      silvenon.mdx
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      skyapps.fish-vscode
      terraform
    ];
  };
}