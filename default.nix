{ nixpkgs ? (import <nixpkgs> {}) }:

with nixpkgs;
let
  hs = haskellPackages.callCabal2nix "ghc-homepage" ./. {};
  scripts = stdenv.mkDerivation {
    name = "ghc-homepage-scripts";
    buildInputs = [ sshfs linkchecker ];
    nativeBuildInputs = [ makeWrapper ];
    src = ./.;
    installPhase = ''
      mkdir -p $out/bin
      substitute upload.sh $out/bin/upload.sh --replace sshfs ${sshfs}/bin/sshfs
      substitute check.sh $out/bin/check.sh --replace linkchecker ${linkchecker}/bin/linkchecker
      chmod ugo+rx $out/bin/upload.sh $out/bin/check.sh
    '';
  };

in buildEnv { name = "ghc-homepage-utils"; paths = [ hs scripts ]; }
