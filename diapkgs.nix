{ coreutils ? (import nix/nixpkgs.nix {}).pkgs.coreutils
, lib ? (import nix/nixpkgs.nix {}).lib
, haskell ? (import nix/nixpkgs.nix {}).haskell
, haskellPackages ? (import nix/nixpkgs.nix {}).pkgs.haskell.packages.ghc843
} :
let diagramsPackages = {
      active         = drv "active" ./active;
      diagrams       = drv "diagrams" ./diagrams;
      diagrams-solve = drv "diagrams-solve" ./diagrams-solve;
      diagrams-pgf   = drv "diagrams-pgf" ./diagrams-pgf;
      diagrams-canvas= drv "diagrams-canvas" ./diagrams-canvas;
      diagrams-haddock = drv "diagrams-haddock" ./diagrams-haddock;
      diagrams-pandoc = drv "diagrams-pandoc" ./diagrams-pandoc;
      diagrams-povray = drv "diagrams-povray" ./diagrams-povray;
      diagrams-gl = drv "diagrams-gl" ./diagrams-gl;
      diagrams-sdl = drv "diagrams-sdl" ./diagrams-sdl;
      diagrams-builder = drv "diagrams-builder" ./diagrams-builder;
      force-layout= drv "force-layout" ./force-layout;
      ihaskell-diagrams   = drv "ihaskell-diagrams" ./ihaskell-diagrams;
      diagrams-contrib = drv "diagrams-contrib" ./diagrams-contrib;
      diagrams-svg   = drv "diagrams-svg" ./diagrams-svg;
      diagrams-rasterific   = drv "diagrams-rasterific" ./diagrams-rasterific;
      diagrams-backend-tests   = drv "diagrams-backend-tests" ./diagrams-backend-tests;
      diagrams-graphviz   = drv "diagrams-graphviz" ./diagrams-graphviz;
      potrace-diagrams   = drv "potrace-diagrams" ./potrace-diagrams;
      geometry       = drv "geometry" ./geometry;
      monoid-extras  = drv "monoid-extras" ./monoid-extras;
      plots  = drv "plots" ./plots;
      letters  = drv "letters" ./letters;
      # nanovg  = drv "nanovg" ./nanovg;
    };
      overrides = self: super: diagramsPackages // {
        sdl2 = haskell.lib.dontCheck super.sdl2;
        nanovg = haskell.lib.dontCheck super.nanovg;
        zeromq4-haskell = haskell.lib.dontCheck super.zeromq4-haskell;
        ihaskell = haskell.lib.overrideCabal super.ihaskell (_drv: {
          preCheck = ''
            export HOME=$(${coreutils}/bin/mktemp -d)
            export PATH=$PWD/dist/build/ihaskell:$PATH
            export GHC_PACKAGE_PATH=$PWD/dist/package.conf.inplace/:$GHC_PACKAGE_PATH
          '';
          configureFlags = (_drv.configureFlags or []) ++ [
            # otherwise the tests are agonisingly slow and the kernel times out
            "--enable-executable-dynamic"
          ];
          doHaddock = false;
        });
      };
    source-overrides = {};

    filterHaskellSource = src:
      builtins.filterSource (path: type:
        lib.all (i: i != baseNameOf path)
        [ ".git" "dist-newstyle" "cabal.project.local"
          "dist" ".stack-work" ".DS_Store" "default.nix" "result"
        ]
          && lib.all (i: !(lib.hasSuffix i path)) [ ".lkshf" ]
          && lib.all
              (i: !(lib.hasPrefix i (baseNameOf path)))
              [ "cabal.project.local" ".ghc.environment." ]
        ) src;

    diapkgs =
      haskellPackages.extend (
        lib.composeExtensions (
          haskellPackages.packageSourceOverrides source-overrides
        ) overrides
      );

    # Normal nix derivation
    drv = name: src: diapkgs.callCabal2nix name (filterHaskellSource src) {};

    povray = (import nix/nixpkgs.nix {}).pkgs.callPackage ./nix/povray.nix { };

in { inherit diapkgs diagramsPackages povray; }
