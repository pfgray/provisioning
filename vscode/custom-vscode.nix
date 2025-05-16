{ pkgs }:

# pkgs.vscode.overrideAttrs (oldAttrs: {
#   version = "1.100.2"; # Specify your desired version

#   src = pkgs.fetchFromGitHub {
#     owner = "microsoft";
#     repo = "vscode";
#     rev = "1.100.2"; # Use a specific tag or commit
#     sha256 = "sha256-yGJ+R04obzF0v5PlDKRT04X0rcZ6dip4shBAh14sI+o="; # Update with the correct hash
#   };

# })

let
  vscode-custom = pkgs.stdenv.mkDerivation {
    pname = "vscode";
    version = "1.100.2";

    src = pkgs.fetchurl {
      url = "https://update.code.visualstudio.com/1.100.2/darwin-arm64/stable";
      sha256 = "sha256-uhahtAqwk7ZdqqY6oemrpwLFPeipg6n0wZiDyA75hsU="; # Replace with actual hash
      name = "VSCode-darwin-arm64.zip";
    };

    nativeBuildInputs = with pkgs; [ unzip ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications
      cp -r "Visual Studio Code.app" $out/Applications
      mkdir -p $out/bin
      
      # Link the code binary to bin directory
      ln -s "$out/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" $out/bin/code
      
      # Find and fix any executable bits that need to be set
      find $out/Applications/Visual\ Studio\ Code.app -type f -name "*.sh" -exec chmod +x {} \;
      find $out/Applications/Visual\ Studio\ Code.app -type f -name "rg" -exec chmod +x {} \;
      find $out/Applications/Visual\ Studio\ Code.app -type f -path "*/bin/*" -exec chmod +x {} \;

    '';

    meta = {
      description = "Microsoft VSCode v1.100.2";
      homepage = "https://code.visualstudio.com/";
      platforms = [ "aarch64-darwin" ];
    };
  };
in
vscode-custom
