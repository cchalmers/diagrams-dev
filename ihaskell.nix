{ nixpkgs ? import nix/nixpkgs.nix {}, compiler ? "ghc843" }:
let haskellPackages = nixpkgs.pkgs.haskell.packages.${compiler};
    diapkgs = import ./diapkgs.nix { inherit (nixpkgs) lib haskell; inherit haskellPackages; };
    ihaskell = nixpkgs.ihaskell.override (old: { inherit (diapkgs) ghcWithPackages; });

in { inherit ihaskell; }
