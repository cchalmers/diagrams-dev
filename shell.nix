let diapkgs = import ./diapkgs.nix {};
    foreign = import ./nix/foreign.nix {};
    env = (diapkgs.diapkgs.shellFor {
      shellHook = "source ${./helpers.sh}";
      buildInputs =
        # [diapkgs.diapkgs.ghcid diapkgs.diapkgs.cabal-install];
        [ diapkgs.diapkgs.ghcid
        diapkgs.diapkgs.cabal-install
            foreign.gs
            foreign.rsvg
            foreign.imagemagick
            foreign.harfbuzz.dev
            foreign.freetype.dev
            foreign.SDL2.dev
            foreign.pkg-config
        ];
      packages = p:
        [
          p.diagrams
          p.active
          p.diagrams-backend-tests
          p.monoid-extras
          p.diagrams-builder
          p.diagrams-cairo
          p.diagrams-canvas
          p.diagrams-contrib
          p.diagrams-haddock
          p.diagrams-solve
          # p.diagrams-pandoc
          p.diagrams-pgf
          p.diagrams-rasterific
          p.diagrams-svg
          # p.ihaskell-diagrams
          p.force-layout
          p.geometry
          p.plots
          p.diagrams-povray
        ];
    });
in env
