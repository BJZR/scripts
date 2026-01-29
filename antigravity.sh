#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------
# Antigravity (Google fork of VS Code)
# User-local installer
# ------------------------------------------

APP_NAME="Antigravity"
APP_DIR="$HOME/.local/opt/antigravity"
BIN_LINK="$HOME/.local/bin/antigravity"

DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.15.8-5724687216017408/linux-x64/Antigravity.tar.gz"
TARBALL="$(mktemp -p /tmp antigravity-XXXXXX.tar.gz)"

DESKTOP_FILE="$HOME/.local/share/applications/antigravity.desktop"
ICON_PATH="$APP_DIR/resources/app/resources/linux/code.png"

print_help() {
  echo "Usage: $0 {install|update|remove|status}"
}

install_app() {
  echo "➡ Installing $APP_NAME…"

  mkdir -p "$APP_DIR"
  mkdir -p "$(dirname "$BIN_LINK")"
  mkdir -p "$(dirname "$DESKTOP_FILE")"

  echo "Downloading from:"
  echo "  $DOWNLOAD_URL"
  curl -L "$DOWNLOAD_URL" -o "$TARBALL"

  tar -xzf "$TARBALL" -C "$APP_DIR" --strip-components=1

  # Correct binary path (VS Code style)
  if [[ -x "$APP_DIR/bin/antigravity" ]]; then
    ln -sf "$APP_DIR/bin/antigravity" "$BIN_LINK"
  else
    echo "❌ Error: bin/antigravity no encontrado"
    exit 1
  fi

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$BIN_LINK %U
Icon=$ICON_PATH
Type=Application
Categories=Development;IDE;
StartupNotify=true
Terminal=false
EOF

  echo "✅ $APP_NAME instalado correctamente"
}

update_app() {
  echo "⬆ Actualizando $APP_NAME…"
  remove_app
  install_app
}

remove_app() {
  echo "🗑 Eliminando $APP_NAME…"
  rm -rf "$APP_DIR"
  rm -f "$BIN_LINK"
  rm -f "$DESKTOP_FILE"
  echo "🗑 Eliminado"
}

status_app() {
  if [[ -x "$BIN_LINK" ]]; then
    echo "✅ $APP_NAME instalado"
    echo "  Binario: $BIN_LINK"
    echo "  Directorio: $APP_DIR"
  else
    echo "❌ $APP_NAME no está instalado"
  fi
}

case "${1:-}" in
  install) install_app ;;
  update) update_app ;;
  remove) remove_app ;;
  status) status_app ;;
  *) print_help ;;
esac

