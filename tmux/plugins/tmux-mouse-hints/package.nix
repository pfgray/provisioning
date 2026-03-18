{ pkgs, configFile }:

pkgs.stdenv.mkDerivation {
  pname = "tmux-mouse-hints";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    # Install the handler script with config file path substituted
    substitute scripts/handle-click.sh $out/bin/.tmux-mouse-hints-handler-wrapped \
      --replace '@CONFIG_FILE@' '${configFile}' \
      --replace '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'

    chmod +x $out/bin/.tmux-mouse-hints-handler-wrapped

    # Wrap the script to ensure tmux and jq are in PATH
    makeWrapper $out/bin/.tmux-mouse-hints-handler-wrapped $out/bin/tmux-mouse-hints-handler \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.tmux pkgs.jq ]}
  '';

  meta = {
    description = "Tmux plugin for clicking on regex patterns with custom commands";
    platforms = pkgs.lib.platforms.all;
  };
}
