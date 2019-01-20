{ mkDerivation ? (import nix/nixpkgs.nix {}).stdenv.mkDerivation
, coreutils ? (import nix/nixpkgs.nix {}).pkgs.coreutils
, lib ? (import nix/nixpkgs.nix {}).lib
, haskell ? (import nix/nixpkgs.nix {}).haskell
, haskellPackages ? (import nix/nixpkgs.nix {}).pkgs.haskell.packages.ghc843
, foreign ? (import ./nix/foreign.nix {})
} :
let diagramsPackages = {
      active         = drv "active" ./active;
      diagrams       = drv "diagrams" ./diagrams;
      diagrams-solve = drv "diagrams-solve" ./diagrams-solve;
      diagrams-cairo = drv "diagrams-cairo" ./diagrams-cairo;
      diagrams-pgf   = haskell.lib.overrideCabal (drv "diagrams-pgf" ./diagrams-pgf)
        (drv: {
          postPatch = ''
            sed -i -e 's:"pdflatex":"${foreign.latex}/bin/pdflatex":' src/Diagrams/Backend/PGF/Surface.hs;
            sed -i -e 's:"context":"${foreign.context}/bin/context":' src/Diagrams/Backend/PGF/Surface.hs
          '';
        });
      diagrams-canvas= drv "diagrams-canvas" ./diagrams-canvas;
      diagrams-haddock = drv "diagrams-haddock" ./diagrams-haddock;
      diagrams-pandoc = drv "diagrams-pandoc" ./diagrams-pandoc;

      diagrams-povray =
        haskell.lib.addBuildDepend (drv "diagrams-povray" ./diagrams-povray) foreign.povray;

      diagrams-gl = drv "diagrams-gl" ./diagrams-gl;
      diagrams-sdl = drv "diagrams-sdl" ./diagrams-sdl;
      diagrams-builder = drv "diagrams-builder" ./diagrams-builder;
      force-layout= drv "force-layout" ./force-layout;
      ihaskell-diagrams   = drv "ihaskell-diagrams" ./ihaskell-diagrams;
      diagrams-contrib = drv "diagrams-contrib" ./diagrams-contrib;
      diagrams-svg   = drv "diagrams-svg" ./diagrams-svg;
      diagrams-rasterific   = drv "diagrams-rasterific" ./diagrams-rasterific;
      diagrams-backend-tests   =
        haskell.lib.overrideCabal
          (drv "diagrams-backend-tests" ./diagrams-backend-tests)
        (drv: {
          postPatch = ''
            sed -i -e 's:"gs":"${foreign.gs}/bin/gs":' src/Diagrams/Tests.hs
            sed -i -e 's:"rsvg-convert":"${foreign.rsvg}/bin/rsvg-convert":' src/Diagrams/Tests.hs
            sed -i -e 's:"convert":"${foreign.imagemagick}/bin/convert":' src/Diagrams/Tests.hs
           '';
        });
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

    mkBackendTest = backend:
      mkDerivation {
        name = "backend-test-" + backend;
        phases = ["buildPhase" "installPhase" "fixupPhase"];
        propagatedBuildInputs =
          [diagramsPackages.diagrams-backend-tests];
        buildPhase = ''
          ${diagramsPackages.diagrams-backend-tests}/bin/test-${backend}
          '';
        installPhase = ''
          mv ${backend}-tests $out
          '';
      };

    rasterific-test = mkBackendTest "rasterific";
    testNames = ["cairo" "rasterific" "pgf" "svg"];
    tests = lib.genAttrs testNames mkBackendTest;

    hoogle = diapkgs.hoogleLocal
      { packages = [diagramsPackages.diagrams-backend-tests
      diagramsPackages.diagrams-builder
      diagramsPackages.diagrams-cairo]; };

in { inherit diapkgs diagramsPackages foreign tests hoogle; }
