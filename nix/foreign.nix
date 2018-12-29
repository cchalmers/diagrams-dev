{ nixpkgs ? import ./nixpkgs.nix {} }:

# foreign (non-haskell) dependencies
# This is not (yet) an exhustive list of non-haskell dependencies, for now it's
# just the command line tools that get used, which are each to change.
{ latex       = nixpkgs.texlive.combined.scheme-small;
  context     = nixpkgs.texlive.combined.scheme-context;
  gs          = nixpkgs.ghostscript;
  rsvg        = nixpkgs.librsvg;
  imagemagick = nixpkgs.imagemagick;

  # a version of povray without sdl support
  povray = nixpkgs.pkgs.callPackage ./povray.nix {};
}
