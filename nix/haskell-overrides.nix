{ haskell
, foreign
}:

let gtk2hs-src = builtins.fetchGit {
      url = "git@github.com:simonchatts/gtk2hs";
      rev = "1cf2f9bff2427d39986e32880d1383cfff49ab0e";
    };


in self: super: {
  # circle-packing = haskell.lib.doJailbreak super.circle-packing;

  # microlens = self.callHackageDirect {
  #   pkg = "microlens";
  #   ver = "0.4.11.2";
  #   sha256 = "0sdww9zq7z3l55n3rajk0cgm2w4cs2ph01aikv0r1crgabg4dqgb";}
  #   {};

  # inspection-testing = haskell.lib.doJailbreak super.inspection-testing;

  # sdl2 = haskell.lib.dontCheck super.sdl2;

  # nanovg = haskell.lib.dontCheck super.nanovg;

  # nixpkgs points to bytes-0.15 which depends on an old base
  bytes = self.callHackageDirect {
    pkg = "bytes";
    ver = "0.17";
    sha256 = "0phdlcr24vgacxdjim4g5r32h12y2rjd5qzckpikzgl5s7c6x7j8";}
    {};

  statestack = haskell.lib.doJailbreak super.statestack;
  haskell-src-exts = self.callHackageDirect {
    pkg = "haskell-src-exts";
    ver = "1.22.0";
    sha256 = "1w1fzpid798b5h090pwpz7n4yyxw4hq3l4r493ygyr879dvjlr8d";}
    {};

  haskell-src-exts-simple = super.callHackageDirect {
    pkg = "haskell-src-exts-simple";
    ver = "1.22.0.0";
    sha256 = "1ixx2bpc7g6lclzrdjrnyf026g581rwm0iji1mn1iv03yzl3y215";}
    {};

  # callCabal2nix gets confused which glib and pango to use
  glib = (self.callCabal2nix "glib" "${gtk2hs-src}/glib" {})
    .overrideDerivation (_: {
    buildInputs = [ foreign.glib.dev ];
  });
  pango = (self.callCabal2nix "pango" "${gtk2hs-src}/pango" {})
    .overrideDerivation (_: {
    buildInputs = [ foreign.pango.dev ];
  });


# zeromq4-haskell = haskell.lib.dontCheck super.zeromq4-haskell;
  # zeromq4-haskell = self.callHackage "zeromq4-haskell" "0.8.0" {};
}
