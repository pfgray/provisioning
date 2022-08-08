system: {pkgs}:
  pkgs.stdenv.mkDerivation {
    name = "init";
    src = ./.;

    buildInputs = [
      pkgs.envsubst
      pkgs.makeWrapper
      pkgs.nix
      pkgs.coreutils
    ];

    installPhase = ''
      mkdir $out
      cp -rv $src/* $out
    '';

    postFixup = ''
      wrapProgram $out/bin/init \
        --set PATH ${pkgs.lib.makeBinPath [
          pkgs.envsubst
          pkgs.nix
          pkgs.coreutils
        ]}
    '';
  }