{pkgs, ...} @ input:

{
  # nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  home.packages = with pkgs; [
    curl
    wget
    jq
    nodejs
    tmux
    vim
    whois
    git
    vscode

    aws
    ruby
    kubernetes
    postgresql
    ripgrep
  ];

  programs = {
    home-manager.enable = true;
    vscode.enable = true;
  };

} // (import ./fish/fish.nix input)
