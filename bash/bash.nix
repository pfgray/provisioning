{pkgs, lib, ...}:
{
  config.programs.bash = {
    enable = true;
    enableCompletion = true;
  };
}
