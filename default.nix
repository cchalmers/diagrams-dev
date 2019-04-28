{ nixpkgs ? import nix/nixpkgs.nix {}, compiler ? "ghc864" }:
let haskellPackages = nixpkgs.pkgs.haskell.packages.${compiler};
    diapkgs = import ./diapkgs.nix {
      coreutils = nixpkgs.pkgs.coreutils;
      inherit (nixpkgs) lib haskell;
      inherit haskellPackages;
    };

in diapkgs.diagramsPackages
