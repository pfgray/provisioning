{buildGo118Module, fetchFromGitHub, ...}:

buildGo118Module rec {
  pname = "vaulted";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "miquella";
    repo = "vaulted";
    rev = "v${version}";
    sha256 = "sha256-slFlC4pbOhzbNMaYIPkbclhNlmzdMO8rTTSrmehlNd4=";
  };

  vendorSha256 = "sha256-BbKbzbSAZjX4geDsSKvdIX8Dj3E7qA0h8k98JfkBSP4=";

}