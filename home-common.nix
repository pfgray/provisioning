{pkgs, ...} @input:

{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    curl
    wget
    jq
    nodejs
    tmux
    vim
    whois

    aws
    ruby
    docker
    kubernetes
    postgresql
    httpie
    ripgrep
  ];

  programs = {
    home-manager.enable = true;
    vscode.enable = true;
  };

} // (import ./fish/fish.nix input)
