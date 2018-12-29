let diapkgs = import ./diapkgs.nix {};
    env = (diapkgs.diapkgs.shellFor {
      buildInputs =
        [diapkgs.diapkgs.ghcid diapkgs.diapkgs.cabal-install];
      packages = p:
        [
          p.diagrams
          p.diagrams-backend-tests
          p.diagrams-builder
          p.diagrams-canvas
          p.diagrams-contrib
          p.diagrams-haddock
          p.diagrams-pandoc
          p.diagrams-pgf
          p.diagrams-rasterific
          p.diagrams-svg
          p.force-layout
          p.geometry
          p.plots
          p.diagrams-povray
        ];
    });
in env
