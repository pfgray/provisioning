system: {pkgs}:
  pkgs.stdenv.mkDerivation {
    name = "init";
    src = ./.;

    buildInputs = [pkgs.envsubst];

    installPhase = ''
      mkdir $out
      cp -rv $src/* $out
    '';
  }