{pkgs, ...}:

{
    # nixpkgs.config.allowUnfree = true;

    nixpkgs.config.allowUnfreePredicate = (pkg: true);
    home.packages = with pkgs; [
        curl
        wget
        jq
        tmux
        vim
        whois
        git
        gnupg
        jwt-cli
        aws
        kubectl
        postgresql
        ripgrep
        dhall
        dhall-json
        lsd
        bat
        gopass
        jdk8
        graphviz
        # mutagen
    ];

    programs = {
        home-manager.enable = true;
        java = {
            enable = true;
            package = pkgs.jdk8;
        };
    };
}