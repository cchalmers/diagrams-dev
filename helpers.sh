DIAGRAMS_IMPORTS="-idiagrams-solve/src -iactive/src -igeometry/src -idiagrams/src"

function backend-test {
  ghcid -c "ghci $DIAGRAMS_IMPORTS $1 -idiagrams-backend-tests/src diagrams-backend-tests/tests/$2" -T ":main diagrams-backend-tests/ref"
}

function svg-tests {
  backend-test "-idiagrams-svg/src" "Svg.hs"
}

function cairo-tests {
  backend-test "-idiagrams-cairo/src" "Cairo.hs"
}

function pgf-tests {
  backend-test "-idiagrams-pgf/src" "Pgf.hs"
}
