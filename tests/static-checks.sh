#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
for path in auto/config auto/build scripts/*.sh tests/*.sh config/hooks/normal/*.hook.chroot config/includes.chroot/lib/live/config/* branding/scripts/*.js; do
  [[ -f $path ]] || continue
  case "$path" in *.js) node --check "$path" ;; *) bash -n "$path" ;; esac
done
if command -v xmllint >/dev/null 2>&1; then
  find config/includes.chroot -type f \( -name '*.xml' -o -name '*.svg' \) -print0 | xargs -0 -r -n1 xmllint --noout
else
  echo 'xmllint unavailable; XML and SVG validation not run.'
fi
if command -v desktop-file-validate >/dev/null 2>&1; then
  find config/includes.chroot -type f -name '*.desktop' -print0 | xargs -0 -r -n1 desktop-file-validate
else
  echo 'desktop-file-validate unavailable; desktop entry validation not run.'
fi
node --check branding/scripts/render-plymouth-mark.js
[[ -s config/includes.chroot/usr/share/fonts/truetype/yfit/Fredoka-VF.ttf ]]
sha256sum -c branding/fonts/SHA256SUMS
[[ -s config/includes.chroot/usr/share/plymouth/themes/yfit/yfit-mark.png ]]
if grep -RInE 'TODO|FIXME|placeholder|mock response' --exclude=static-checks.sh --exclude='*.ttf' --exclude='*.png' auto config scripts tests branding; then
  echo 'Review prohibited placeholder markers above.' >&2
  exit 1
fi
printf 'Static source checks passed. These checks do not verify ISO boot or hardware.\n'
