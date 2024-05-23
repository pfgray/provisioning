{pkgs, ...}:

let
  terraform = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "terraform";
      publisher = "hashicorp";
      version = "2.23.0";
      sha256 = "sha256-3v2hEf/cEd7NiXfk7eJbmmdyiQJ7bWl9TuaN+y5k+e0";
    };
  };
  CamelCase = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "CamelCase";
      publisher = "MarioQueiros";
      version = "1.0.5";
      sha256 = "sha256-4HO0pGiTfWRrY1i1G03EDOWoEEdVEgO0VwztyJKjfTI=";
    };
  };

  plantumlExt = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "plantuml";
      publisher = "jebbs";
      version = "2.18.1";
      sha256 = "sha256-o4FN/vUEK53ZLz5vAniUcnKDjWaKKH0oPZMbXVarDng=";
    };
    nativeBuildInputs = [ pkgs.jq pkgs.moreutils ];
    postInstall = ''
      cd "$out/$installPrefix"
      jq '.contributes.configuration.properties."plantuml.java".default = "${pkgs.plantuml}/bin/plantuml"' package.json | sponge package.json
    '';

    meta = {
      description = "A Visual Studio Code extension for supporting Rich PlantUML";
      downloadPage =
        "https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml";
      homepage = "https://github.com/qjebbs/vscode-plantuml";
      changelog =
        "https://marketplace.visualstudio.com/items/jebbs.plantuml/changelog";
      license = pkgs.lib.licenses.mit;
      maintainers = [ pkgs.lib.maintainers.victormignot ];
    };
  };

  ShopifyRubyLSP = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "ruby-lsp";
      publisher = "Shopify";
      version = "0.5.20";
      sha256 = "sha256-dPPTo5DzSXlBSAaId8x54veYP/vy47Y40vTaJA4E+Qc=";
    };
  };
in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    keybindings = import ./keybindings.nix;
    userSettings = import ./userSettings.nix;
    mutableExtensionsDir = false;

    extensions = with pkgs.vscode-extensions; [
      # justusadam.language-haskell
      # ms-azuretools.vscode-docker
      # ms-vscode-remote.remote-ssh
      skyapps.fish-vscode
      # terraform
      plantumlExt
      ShopifyRubyLSP
      esbenp.prettier-vscode
      # CamelCase
      waderyan.gitblame
      # mhutchie.git-graph
      donjayamanne.githistory
      github.copilot
      # not in this version of nixpkgs yet
      # github.copilot-chat
      # brettm12345.nixfmt-vscode
    ];
  };
}
