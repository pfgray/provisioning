{pkgs, ...} @ input:

let
  recursiveMerge = import ./recursiveMerge.nix input;
in
  recursiveMerge [
    (import ./home-common.nix input)

    {
      home.packages = with pkgs; [
        docker
        docker-compose
      ];

      services.gpg-agent = {
        enable = true;
        defaultCacheTtl = 1800;
        enableSshSupport = true;
      };
    }
  ]