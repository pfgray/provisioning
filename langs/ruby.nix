{pkgs, lib, config, ...}:

let
  ruby-rubocop = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "ruby-rubocop";
        publisher = "misogi";
        version = "0.8.6";
        sha256 = "sha256-6hgJzOerGCCXcpADnISa7ewQnRWLAn6k6K4kLJR09UI=";
      };
      meta = {
        license = lib.licenses.mit;
      };
    };

  # This extension doesn't work with nix ootb because it tries to modify
  # a file in the nix store...
  # specifically the file: dist/server/shims/env.Users.paul.gray..nix-profile.bin.fish.fish
  #
  # The solution here is to modify this derivation's
  # postInstall hook to create that file, then the extension
  # doesn't try to create the file 
  ruby = (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "ruby";
        publisher = "rebornix";
        version = "0.28.1";
        sha256 = "sha256-HAUdv+2T+neJ5aCGiQ37pCO6x6r57HIUnLm4apg9L50=";
      };
    }).overrideAttrs (attrs: {
      # TODO: will probably need to change the name of the file depending on the user
      postInstall = (attrs.postInstall or "") + ''
      mkdir -p $out/$installPrefix/dist/server/shims
      echo "#!${config.home.homeDirectory}/.nix-profile/bin/fish
for name in (set -nx)
  if string match --quiet '*PATH' \$name
    echo \$name=(string join : -- \$\$name)
  else
    echo \$name="\$\$name"
  end
end
      " > $out/$installPrefix/dist/server/shims/env.Users.paul.gray..nix-profile.bin.fish.fish

      chmod +x $out/$installPrefix/dist/server/shims/env.Users.paul.gray..nix-profile.bin.fish.fish
      '';
    });
  
  rails = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "rails";
        publisher = "bung87";
        version = "0.17.8";
        sha256 = "sha256-Unz/V6wQxE+MhsU2btdeBd4bqicm3w5HxucYDrcG2tw";
      };
    };

  vscode-gemfile = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-gemfile";
        publisher = "bung87";
        version = "0.4.2";
        sha256 = "sha256-KWDQCd0hcTKu5AUOK3ZfjWpL71LXJkt5SdWp6M7nBM4=";
      };
    };
  
  # This depends on htmlbeautifier
  vscode-erb-beautify = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-erb-beautify";
        publisher = "aliariff";
        version = "0.3.5";
        sha256 = "sha256-kAdS+SFJfFzb/2Umpd1DYlIk5jH9ZoNwpVBUbpN6d/M=";
      };
    };

  htmlbeautifier = import ../tools/htmlbeautifier pkgs;

in {

  options = {
    langs.ruby = {
      enable = lib.mkEnableOption "The Ruby language";
    };
  };

  config = {
    home.packages = with pkgs; [
      rubocop
      bundix
      htmlbeautifier
      watchman
    ];

    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        # This extension tries to modify it's 
        # extension directory
        ruby
        ruby-rubocop
        rails
        vscode-gemfile
        vscode-erb-beautify
      ];
    };
  };
}