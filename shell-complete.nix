let diapkgs = import ./diapkgs.nix {};
    env = (diapkgs.diapkgs.shellFor {
      buildInputs =
        [ diapkgs.diapkgs.ghcid
          diapkgs.diapkgs.cabal-install
          diapkgs.diapkgs.hoogle
          (import ./ihaskell.nix {}).ihaskell
          ];
      haskellInputs =
        [ diapkgs.diapkgs.diagrams
          diapkgs.diapkgs.diagrams-backend-tests
          diapkgs.diapkgs.diagrams-builder
          diapkgs.diapkgs.diagrams-cairo
          diapkgs.diapkgs.diagrams-canvas
          diapkgs.diapkgs.diagrams-contrib
          diapkgs.diapkgs.diagrams-haddock
          # diapkgs.diapkgs.diagrams-pandoc
          diapkgs.diapkgs.diagrams-pgf
          diapkgs.diapkgs.diagrams-povray
          diapkgs.diapkgs.diagrams-rasterific
          diapkgs.diapkgs.diagrams-svg
          diapkgs.diapkgs.force-layout
          diapkgs.diapkgs.geometry
          diapkgs.diapkgs.plots
          ];
      packages = p:
        [ p.diagrams-backend-tests
        ];
    });
in env
