{buildGoModule, fetchFromGitHub, ...}:

buildGoModule rec {
  pname = "rapture";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "daveadams";
    repo = "go-rapture";
    rev = "v${version}";
    sha256 = "sha256-aqY/O6mE2nQPNhRhuHUpXSD/CYyvMSHJ9KzsacWkKmQ=";
  };

  vendorSha256 = "sha256-+xqTeDLyNagXmm6Aj6Up8lccAa67ygYvapA+Y6ZeFzQ";

}