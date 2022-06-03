{pkgs, ...}:

{
  home.packages = with pkgs; [
    jdk8
  ];

  programs = {
    java = {
      enable = true;
      package = pkgs.jdk8;
    };
  };
}