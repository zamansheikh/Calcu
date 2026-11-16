#!/bin/bash
# Rebuilds the app icon from tool/icon/make.py.
#
#   tool/icon/build.sh
#
# Draws the SVG layers, rasterizes them with headless Chrome into
# assets/icon/ and store/play/, resizes the web icons, then regenerates the
# Android and iOS launcher icons from flutter_launcher_icons.yaml.
set -euo pipefail
cd "$(dirname "$0")/../.."

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp tool/icon/make.py "$WORK/make.py"
python3 "$WORK/make.py" >/dev/null

render() {  # render <layer> <output.png>
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 --default-background-color=00000000 \
    --window-size=1024,1024 --screenshot="$2" "file://$WORK/$1.svg" \
    >/dev/null 2>&1
}

mkdir -p assets/icon store/play
render legacy     assets/icon/ic_launcher.png
render foreground assets/icon/ic_launcher_foreground.png
render background assets/icon/ic_launcher_background.png
render monochrome assets/icon/ic_launcher_monochrome.png
render full       "assets/icon/AppIcon~ios-marketing.png"
# Google Play wants a 512 px icon; it applies its own mask.
sips -Z 512 "assets/icon/AppIcon~ios-marketing.png" \
  --out store/play/icon-512.png >/dev/null

# The web build's favicon and install icons.
sips -z 16 16 "assets/icon/AppIcon~ios-marketing.png" --out web/favicon.png >/dev/null
for size in 192 512; do
  for name in Icon Icon-maskable; do
    sips -z $size $size "assets/icon/AppIcon~ios-marketing.png" \
      --out "web/icons/$name-$size.png" >/dev/null
  done
done

dart run flutter_launcher_icons
