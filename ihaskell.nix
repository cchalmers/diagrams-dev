{ nixpkgs ? import nix/nixpkgs.nix {}, compiler ? "ghc843" }:
let haskellPackages = nixpkgs.pkgs.haskell.packages.${compiler};
    diapkgs = import ./diapkgs.nix {
      coreutils = nixpkgs.pkgs.coreutils;
      inherit (nixpkgs) lib haskell;
      inherit haskellPackages;
    };
    ihaskell = import ./build-ihaskell.nix { haskellPackages = diapkgs; };

in { inherit ihaskell; }
