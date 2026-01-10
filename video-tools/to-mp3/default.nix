{ffmpeg, writeShellApplication, ...}:


writeShellApplication {
  name = "to-mp3";
  runtimeInputs = [ffmpeg];
  text = builtins.readFile ./to-mp3.sh;
}