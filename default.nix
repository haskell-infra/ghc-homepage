{ nixpkgs ? (import <nixpkgs> {}) }:

with nixpkgs;
let
  hs = haskellPackages.callCabal2nix "ghc-homepage" ./. {};
in stdenv.mkDerivation {
  name = "ghc-homepage-utils";
  buildInputs = [ hs ];
  nativeBuildInputs = [ makeWrapper ];
  src = ./.;
  installPhase = ''
    mkdir $out
    substitute upload.sh $out/upload.sh --replace sshfs ${sshfs}/bin/sshfs
    chmod ugo+rx $out/upload.sh
  '';
}

