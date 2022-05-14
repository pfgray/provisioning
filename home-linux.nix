{pkgs, ...} @ input:

(import ./home-common.nix input) // {
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}