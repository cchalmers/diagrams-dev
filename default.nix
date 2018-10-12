{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc843" }:
let haskellPackages = nixpkgs.pkgs.haskell.packages.${compiler};
    diagramsPackages = {
      active         = drv "active" ./active;
      diagrams       = drv "diagrams" ./diagrams;
      diagrams-solve = drv "diagrams-solve" ./diagrams-solve;
      diagrams-pgf   = drv "diagrams-pgf" ./diagrams-pgf;
      diagrams-svg   = drv "diagrams-svg" ./diagrams-svg;
      diagrams-rasterific   = drv "diagrams-rasterific" ./diagrams-rasterific;
      geometry       = drv "geometry" ./geometry;
      monoid-extras  = drv "monoid-extras" ./monoid-extras;
      Glob = haskellPackages.callHackage "Glob" "0.9.3" {};
      monad-par = drv "monad-par" ./monad-par/monad-par;
      criterion = diaPkgs.callHackage "criterion" "1.5.1.0" {};
        # base-compat-batteries = diaPkgs.callHackage "base-compat-batteries" "0.10.4" {};
      # criterion-measurement = diaPkgs.callHackage "criterion-measurement" "0.1.1.0" {};
      # };
    };
    overrides = self: super: diagramsPackages;
    monad-par-src = nixpkgs.fetchFromGitHub {
      owner = "simonmar";
      repo = "monad-par";
      rev = "ccd7b1c3a937245648f2d37e4d86141211257b8c";
      sha256 = "1k1df7ydqjfmm9m6wx3dhcb4hi1cd056j00bxij8bfi9wpm035kx";
    };
    source-overrides = {
      vector-binary-instances = nixpkgs.fetchFromGitHub {
        owner = "bos";
        repo = "vector-binary-instances";
        rev = "9108b7e404cad5bcf20c0ee452bf0e1459639514";
        sha256 = "1cawqc6glylgw94w924kzs6sn4v2rq94j5vrkgnq6mxz7cn91q9m";
      };
      JuicyPixels = nixpkgs.fetchFromGitHub {
        owner = "Twinside";
        repo = "Juicy.Pixels";
        rev = "4a3ae263df3e91a7081ce764d76b8c9f15bcbd29";
        sha256 = "0z77rzc7n541rf6i9m0jcyw0hni9cnih1p45ggzd16w7w0z654yw";
      };
    };

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

in diagramsPackages // { inherit filterHaskellSource; }
