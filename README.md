# diagrams-dev

This is a repository for a development environment for the diagrams 2.0 library. Details about the changes in diagrams-2.0 can be found in the readme of the diagrams repo.

The different diagrams packages are linked as submodules and are tied together in this repo using nix expressions and a cabal project file.

## Getting started

To clone this repository and all the submodules run

```
git clone git@github.com:cchalmers/diagrams-dev --recursive
```

After cloning the repository, you also need to update the submodules by
running

```
git submodule update --init --recursive
```

## Nix

Nix is the recommended way to use this repository. Nix is a purely functional package manager that can handle the external dependencies of diagrams as well as the Haskell ones. Nix is used for travis CI and is the best supported method for developing diagrams.

To install nix see https://nixos.org/nix/download.html

### diagrams cache

There is a diagrams nix cache using cachix. To use the cache first
install cachix

```
nix-env -iA cachix -f https://cachix.org/api/v1/install
```

Then use the diagrams cache (this may need sudo):

```
cachix use diagrams
```

The cache is updated from CI so it should hopefully always be up to
date.

### Jupyter

You can get a Jupyter environment using ihaskell from a nix expression.  First open a terminal and `cd` into the root directory of the `diagrams-dev` repository.  Then the one-liner to get an ihaskell lab is (replace `lab` with `notebook` for a notebook):

```
$(nix-build --no-out-link ihaskell.nix)/bin/ihaskell-lab
```

This should open a browser with jupyter notebook. Be aware that you may need to remove any `.ghc.environment` files from the directory you run `ihaskell` from. You can test this by making a new haskell notebook and running a cell with (note that diagrams need a concrete type to be rendered):

```
square 3 # fc dodgerblue :: Diagram V2
```

### Shells

#### Development

The nix shell provides an environment with all the external dependencies of diagrams as well as cabal-install and ghcid. To get a ghcid for the diagrams-svg package you can run;

```
nix-shell --pure
cd diagrams-svg
ghcid -c "cabal new-repl"
cabal new-build
```

There are also mega-ghci helper functions defined in `helpers.sh` (automatically sourced when in the nix shell) that will run the backend tests for the chosen backend and automatically reload and generate the test output

```
svg-tests
```

If you make changes to any of the diagrams dependencies this will
rebuild all the necessary parts and rerun the tests, outputting the
result to `cairo.html`.

### hoogle

To get a local hoogle server with all the diagrams packages and their
dependencies run:

```
$(nix-build diapkgs.nix -A hoogle)/bin/hoogle server --port 8081 --local
```

### Building the tests

The diagrams-backend-tests module contains a number of simple tests to check that the backend is basically working. The results are displayed in a html document that compares the output from the chosen backend to the reference images.

To build the tests using nix there are separate derivations for each backend. For example the derivation of the rasterific backend test:

```
nix-build diapkgs.nix -A tests.rasterific
```

will produce a `result` symbolic link that contains an `index.html` file with a comparison to .


## Without nix

Nix is not a requirement to use this repository but without it you will need to get the external dependencies yourself. This is a (possibly incomplete) list of current external dependencies.

  - cairo (diagrams-cairo)
  - jupyter (ihaskell-diagrams)
  - zmq (ihaskell-diagrams)
  - povray (diagrams-povray)
  - tex (diagrams-pgf)
  - librsvg (diagrams-backend-tests)
  - image-magick (diagrams-backend-tests)
  - ghostscript (diagrams-backend-tests)
  - graphviz (diagrams-graphviz)
  - sdl (diagrams-sdl)
  - harfbuzz (letters)
  - freetype (letters)
