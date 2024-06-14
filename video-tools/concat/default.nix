{ffmpeg, mktemp, writeShellApplication, ...}:


writeShellApplication {
  name = "concat";
  runtimeInputs = [ffmpeg mktemp];
  text = builtins.readFile ./concat.sh;
}