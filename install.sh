#!/usr/bin/env bash
set -e
src="$(cd "$(dirname "$0")" && pwd)"
plugins="$HOME/.config/DankMaterialShell/plugins"
conf="$HOME/.config/desk-widgets"
mkdir -p "$plugins" "$conf"
for p in deskSystem deskDev deskOps deskAquario; do
  ln -sfn "$src/$p" "$plugins/$p"
done
[ -f "$conf/config.env" ] || cp "$src/examples/config.env" "$conf/config.env"
if [ ! -f "$conf/secrets.env" ]; then
  cp "$src/examples/secrets.env" "$conf/secrets.env"
  chmod 600 "$conf/secrets.env"
fi
echo "Plugins linkados em $plugins. Edite $conf/config.env e $conf/secrets.env."
