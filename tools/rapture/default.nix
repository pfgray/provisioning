{pkgs, config, lib, buildGoModule, fetchFromGitHub, ...}:

let rapture =
  buildGoModule rec {
    pname = "rapture";
    version = "2.0.0";

    src = fetchFromGitHub {
      owner = "daveadams";
      repo = "go-rapture";
      rev = "v${version}";
      sha256 = "sha256-aqY/O6mE2nQPNhRhuHUpXSD/CYyvMSHJ9KzsacWkKmQ=";
    };

    vendorSha256 = "sha256-+xqTeDLyNagXmm6Aj6Up8lccAa67ygYvapA+Y6ZeFzQ";
  };
in {
  options = {
    tools.rapture = {
      enable = lib.mkEnableOption "The Rapture CLI tool";
    };
  };

  config = {
    programs.vscode.extensions = lib.mkIf (config.tools.rapture.enable) [
      pkgs.vscode-extensions.rust-lang.rust-analyzer
    ];

    home.packages = lib.mkIf config.tools.rapture.enable [
      rapture
    ];
  };
}

