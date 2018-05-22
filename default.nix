{ nixpkgs ? (import <nixpkgs> {}) }:

with nixpkgs;
let
  hs = haskellPackages.callCabal2nix "ghc-homepage" ./. {};
  upload = stdenv.mkDerivation {
    name = "ghc-homepage-upload";
    buildInputs = [ sshfs ];
    nativeBuildInputs = [ makeWrapper ];
    src = ./.;
    installPhase = ''
      mkdir -p $out/bin
      substitute upload.sh $out/bin/upload.sh --replace sshfs ${sshfs}/bin/sshfs
      chmod ugo+rx $out/bin/upload.sh
    '';
  };

in buildEnv { name = "ghc-homepage-utils"; paths = [ hs upload ]; }
