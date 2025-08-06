{ pkgs, lib, ... }:

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

  devcontainers = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "remote-containers";
      publisher = "ms-vscode-remote";
      version = "0.388.0";
      sha256 = "sha256-dik1x6h8+DsEW5gH5BekCOvezTCGtiebIh4VIGGQbLE=";
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

  cline = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "claude-dev";
      publisher = "saoudrizwan";
      version = "3.1.8";
      sha256 = "sha256-td9Wk1QubVdds7N1L02OYwl1OtBRiF+yF1fwYA2EC9o=";
    };
  };

  copilot-chat = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "copilot-chat";
      publisher = "GitHub";
      version = "0.27.0";
      sha256 = "sha256-i7KKW+aM8P1nrgnLZssgAlKm1kaQyeh285EnoN9Bwps=";
    };
  };

  vscode-custom = import ./custom-vscode.nix { inherit pkgs; };

in
{
  programs.vscode = {
    enable = true;
    package = vscode-custom;
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
      copilot-chat
      devcontainers
      ms-vscode-remote.remote-ssh
      cline
      # not in this version of nixpkgs yet
      # github.copilot-chat
      # brettm12345.nixfmt-vscode
    ];
  };

}
