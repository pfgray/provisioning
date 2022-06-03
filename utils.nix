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
        lsd
        bat
        gopass
        graphviz
        # mutagen
    ];

    programs = {
        home-manager.enable = true;
    };
}