{ mkDerivation ? (import nix/nixpkgs.nix {}).stdenv.mkDerivation
, coreutils ? (import nix/nixpkgs.nix {}).pkgs.coreutils
, lib ? (import nix/nixpkgs.nix {}).lib
, haskell ? (import nix/nixpkgs.nix {}).haskell
, haskellPackages ? (import nix/nixpkgs.nix {}).pkgs.haskell.packages.ghc864
, foreign ? (import ./nix/foreign.nix {})
, srcOnly ? (import nix/nixpkgs.nix {}).srcOnly
, fetchFromGitHub ? (import nix/nixpkgs.nix {}).fetchFromGitHub
} :

let ihaskellSrc = srcOnly {
      name = "ihaskell-src";
      src = fetchFromGitHub {
         owner = "gibiansky";
         repo = "IHaskell";
         rev = "8e8089dd43dc5f715ddcaa06b252d494112b8657";
         sha256 = "0hvzsfgf3kizciwdl2ra93s0q7m1fi3fg1sak1vphzfmzhcpp7a6";
      };
    };

    diagramsPackages = {
      ihaskell         =
        haskell.lib.overrideCabal
          (diapkgs.callCabal2nix "ihaskell" ihaskellSrc {})
            (_drv: {
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
      ipython-kernel   = diapkgs.callCabal2nix "ipython-kernel" "${ihaskellSrc}/ipython-kernel" {};
      ghc-parser       = diapkgs.callCabal2nix "ghc-parser" "${ihaskellSrc}/ghc-parser" {};
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
      # diagrams-pandoc = drv "diagrams-pandoc" ./diagrams-pandoc;

      diagrams-povray =
        haskell.lib.addBuildDepend (drv "diagrams-povray" ./diagrams-povray) foreign.povray;

      # diagrams-gl = drv "diagrams-gl" ./diagrams-gl;
      # diagrams-sdl = drv "diagrams-sdl" ./diagrams-sdl;
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
        haskell-src-exts = self.haskell-src-exts_1_21_0;
        haskell-src-exts-simple = self.callHackageDirect {
          pkg = "haskell-src-exts-simple";
          ver = "1.21.0.0";
          sha256 = "1kz009a24p6j91klmh7s98sal9zdqp7pygj2qghn71kqswz5a11h";}
          {};
        # zeromq4-haskell = haskell.lib.dontCheck super.zeromq4-haskell;
        zeromq4-haskell = self.callHackage "zeromq4-haskell" "0.8.0" {};
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

in { inherit diapkgs diagramsPackages foreign tests hoogle
ihaskellSrc ; }
