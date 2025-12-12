#!/bin/sh
set -e

INSTALL_DIR="$HOME/.local/opt/vscode"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/code.desktop"
SYMLINK="$BIN_DIR/code"

# ========== funciones ==========

detect_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
  x86_64) TARURL="https://update.code.visualstudio.com/latest/linux-x64/stable" ;;
  i686) TARURL="https://update.code.visualstudio.com/latest/linux-ia32/stable" ;;
  armv7l) TARURL="https://update.code.visualstudio.com/latest/linux-armhf/stable" ;;
  aarch64) TARURL="https://update.code.visualstudio.com/latest/linux-arm64/stable" ;;
  *)
    echo "Arquitectura no soportada: $ARCH"
    exit 1
    ;;
  esac
}

install_deps() {
  command -v tar >/dev/null 2>&1 || sudo xbps-install -y tar
}

install_vscode() {
  detect_arch
  install_deps

  mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR"

  TMPFILE=$(mktemp)
  curl -L "$TARURL" -o "$TMPFILE"

  rm -rf "$INSTALL_DIR"/*
  tar -xf "$TMPFILE" -C "$INSTALL_DIR" --strip-components=1
  rm "$TMPFILE"

  ln -sf "$INSTALL_DIR/bin/code" "$SYMLINK"

  ICON_PATH="$INSTALL_DIR/resources/app/resources/linux/code.png"

  cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Editor de código
Exec=$SYMLINK %F
Terminal=false
Type=Application
Icon=$ICON_PATH
Categories=Development;IDE;
StartupNotify=true
EOF

  chmod 644 "$DESKTOP_FILE"
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
  xdg-desktop-menu forceupdate >/dev/null 2>&1 || true

  echo "Instalación completa."
}

update_vscode() {
  if [ ! -d "$INSTALL_DIR" ]; then
    echo "VSCode no está instalado."
    exit 1
  fi
  install_vscode
  echo "Actualización completa."
}

remove_vscode() {
  rm -rf "$INSTALL_DIR"
  rm -f "$SYMLINK"
  rm -f "$DESKTOP_FILE"
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
  xdg-desktop-menu forceupdate >/dev/null 2>&1 || true
  echo "Desinstalación completa."
}

status_vscode() {
  echo "Directorio: $INSTALL_DIR"
  echo "Binario: $SYMLINK"
  echo "Desktop: $DESKTOP_FILE"
  [ -d "$INSTALL_DIR" ] && echo "Estado: instalado" || echo "Estado: no instalado"
}

# ========== parámetros ==========

case "$1" in
install) install_vscode ;;
update) update_vscode ;;
remove) remove_vscode ;;
status) status_vscode ;;
*)
  echo "Uso: $0 {install|update|remove|status}"
  exit 1
  ;;
esac
