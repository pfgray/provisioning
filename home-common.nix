{pkgs, ...} @ input:

let
  recursiveMerge = import ./recursiveMerge.nix input;
in
  recursiveMerge [
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
        gnupg

        aws
        ruby
        kubectl
        postgresql
        ripgrep
      ];

      programs = {
        home-manager.enable = true;
      };
    }

    (import ./fish/fish.nix input)
    (import ./vscode/vscode.nix input)
  ]
