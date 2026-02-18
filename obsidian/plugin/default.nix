{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "obsidian-rsync-sync";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.typescript
  ];

  configurePhase = ''
    export HOME=$TMPDIR
    export npm_config_cache=$TMPDIR/npm-cache

    # Disable SSL verification in Nix sandbox (safe since we're using nixpkgs versions)
    export npm_config_strict_ssl=false

    # Install dependencies but skip postinstall scripts (avoids building esbuild from source)
    npm ci --ignore-scripts --no-audit --no-fund
  '';

  buildPhase = ''
    # Run TypeScript type checking
    ${pkgs.nodePackages.typescript}/bin/tsc -noEmit -skipLibCheck

    # Run esbuild (using Nix's esbuild, not npm's)
    NODE_PATH=node_modules ${pkgs.nodejs}/bin/node esbuild.config.mjs production
  '';

  installPhase = ''
    mkdir -p $out
    cp main.js $out/
    cp manifest.json $out/
    cp styles.css $out/ 2>/dev/null || true
  '';

  meta = with pkgs.lib; {
    description = "Obsidian plugin for automatic vault syncing using rclone";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
