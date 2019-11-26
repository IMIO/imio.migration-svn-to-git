let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  #  imioGitHub = import (pkgs.fetchFromGitHub {
  #    owner = "IMIO";
  #    repo = "imio.github";
  #    rev = "51f4484fd930c5eb870f0a59cace6c260e8701b1";
  #    sha256 = "1g4cjzyarhr5wb8h19172n17zldfhj5yv4wcwfsv019k9yvr3iqr";
  #  });
  #imioGitHub = import (./imio.github/default.nix);
  imioGitHub = import (sources."imio.github");

in pkgs.mkShell {
  buildInputs = [
    pkgs.gitAndTools.pre-commit
    pkgs.gitAndTools.svn-all-fast-export
    imioGitHub
  ];
}
