{pkgs, config, ...}:

pkgs.kubectl.overrideAttrs(oldAttrs: rec {
  pname = "kubectl";
  version = "1.22.7";
  src = pkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v1.22.7";
      sha256 = "sha256-BZERIONXPJkv0Dd9+8fCXvN7MXygY7XyXr708u5Si54=";
  };
  # postInstall = ''
  #   mv $out/bin/kubectl $out/bin/kubectl1_21
  # '';
})