{ nixpkgs ? import ./nixpkgs.nix {} }:

# foreign (non-haskell) dependencies
# These are listed here explicitly so it's easy to see and modify non-haskell dependencies.
{ latex       = nixpkgs.texlive.combined.scheme-small;
  context     = nixpkgs.texlive.combined.scheme-context;
  gs          = nixpkgs.ghostscript;
  rsvg        = nixpkgs.librsvg;
  imagemagick = nixpkgs.imagemagick;

  harfbuzz = nixpkgs.harfbuzz.dev;
  freetype = nixpkgs.freetype.dev;

  glib = nixpkgs.glib;
  pango = nixpkgs.pango;

  SDL2 = nixpkgs.SDL2;

  pkg-config = nixpkgs.pkg-config;

  # a version of povray without sdl support
  povray = nixpkgs.pkgs.callPackage ./povray.nix {};
}
