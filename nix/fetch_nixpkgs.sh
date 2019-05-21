#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz

## Utility to automatically update nixpkgs.json quickly and easily from either
## the Nixpkgs upstream or a custom fork. Runs interactively using `nix-shell`
## for zero-install footprint.
set -e

API="https://api.github.com/repos"
REPO="nixpkgs-channels"
BRANCH="nixos-19.03"
URL="https://github.com/nixos/${REPO}"

if [[ "x$1" == "x" ]]; then
  echo "No revision, so grabbing latest upstream Nixpkgs master commit... "
  REV=$(curl -s "${API}/nixos/${REPO}/commits/${BRANCH}" | jq -r '.sha')
  echo "OK, got ${REV:0:6}"
else
  if [[ "x$2" == "x" ]]; then
    REV="$1"
    echo "Custom revision (but no repo) provided, using ${URL}"
  else
    REV="$2"
    URL="$1"
    echo "Custom revision in upstream ${URL} will be used"
  fi
fi

DOWNLOAD="$URL/archive/$REV.tar.gz"
echo "Updating to nixpkgs revision ${REV:0:6} from $URL"
SHA256=$(nix-prefetch-url --unpack "$DOWNLOAD")

cat > $(git rev-parse --show-toplevel)/nix/nixpkgs.json <<EOF
{
  "url":    "$DOWNLOAD",
  "rev":    "$REV",
  "sha256": "$SHA256"
}
EOF

echo "Updated nixpkgs.json"
