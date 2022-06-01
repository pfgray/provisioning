{pkgs, lib, ...}:

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
  ruby = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "ruby";
        publisher = "rebornix";
        version = "0.28.1";
        sha256 = "sha256-HAUdv+2T+neJ5aCGiQ37pCO6x6r57HIUnLm4apg9L50=";
      };
    };
  
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
in {

  home.packages = with pkgs; [
      pkgs.ruby
      rubocop
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      ruby
      ruby-rubocop
      rails
      vscode-gemfile
    ];
  };
}