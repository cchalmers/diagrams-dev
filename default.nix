{ nixpkgs ? import nix/nixpkgs.nix {}, compiler ? "ghc843" }:
let haskellPackages = nixpkgs.pkgs.haskell.packages.${compiler};
    diagramsPackages = {
      active         = drv "active" ./active;
      diagrams       = drv "diagrams" ./diagrams;
      diagrams-solve = drv "diagrams-solve" ./diagrams-solve;
      diagrams-pgf   = drv "diagrams-pgf" ./diagrams-pgf;
      diagrams-canvas= drv "diagrams-canvas" ./diagrams-canvas;
      force-layout= drv "force-layout" ./force-layout;
      diagrams-contrib = drv "diagrams-contrib" ./diagrams-contrib;
      diagrams-svg   = drv "diagrams-svg" ./diagrams-svg;
      diagrams-rasterific   = drv "diagrams-rasterific" ./diagrams-rasterific;
      diagrams-backend-tests   = drv "diagrams-backend-tests" ./diagrams-backend-tests;
      diagrams-graphviz   = drv "diagrams-graphviz" ./diagrams-graphviz;
      potrace-diagrams   = drv "potrace-diagrams" ./potrace-diagrams;
      geometry       = drv "geometry" ./geometry;
      monoid-extras  = drv "monoid-extras" ./monoid-extras;
      plots  = drv "plots" ./plots;
    };
    overrides = self: super: diagramsPackages;
    source-overrides = {};

    filterHaskellSource = src:
      builtins.filterSource (path: type:
        nixpkgs.lib.all (i: i != baseNameOf path)
        [ ".git" "dist-newstyle" "cabal.project.local"
          "dist" ".stack-work" ".DS_Store" "default.nix" "result"
        ]
          && nixpkgs.lib.all (i: !(nixpkgs.lib.hasSuffix i path)) [ ".lkshf" ]
          && nixpkgs.lib.all
              (i: !(nixpkgs.lib.hasPrefix i (baseNameOf path)))
              [ "cabal.project.local" ".ghc.environment." ]
        ) src;

    diaPkgs =
      haskellPackages.extend (
        nixpkgs.lib.composeExtensions (
          haskellPackages.packageSourceOverrides source-overrides
        ) overrides
      );

    # Normal nix derivation
    drv = name: src: diaPkgs.callCabal2nix name (filterHaskellSource src) {};

in diagramsPackages
