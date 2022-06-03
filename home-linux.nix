{pkgs, lib, ...}:

{
  home.packages = with pkgs; [
    docker
    docker-compose
  ];

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}