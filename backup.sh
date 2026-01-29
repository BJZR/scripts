#!/usr/bin/env bash

# ==============================================================================
# Backup de configuraciones bash, zsh y scripts personalizados
# ==============================================================================

# Directorios y archivos a respaldar
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"
SCRIPTS_DIR="/home/bjzr/Proyectos/sh/scripts"

# Carpeta donde se guardarÃ¡n los respaldos
BACKUP_DIR="$HOME/backups-shell"

# Crear la carpeta si no existe
mkdir -p "$BACKUP_DIR"

# Nombre del archivo final con fecha
DATE=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="$BACKUP_DIR/backup_shell_$DATE.tar.gz"

echo "[INFO] Creando backup..."
echo "       -> bashrc: $BASHRC"
echo "       -> zshrc:  $ZSHRC"
echo "       -> scripts: $SCRIPTS_DIR"
echo "       -> destino: $BACKUP_FILE"

# Crear un directorio temporal
TMP_DIR=$(mktemp -d)

# Copiar archivos si existen
[ -f "$BASHRC" ] && cp "$BASHRC" "$TMP_DIR/" || echo "[WARN] No se encontrÃ³ .bashrc"
[ -f "$ZSHRC" ] && cp "$ZSHRC" "$TMP_DIR/" || echo "[WARN] No se encontrÃ³ .zshrc"
[ -d "$SCRIPTS_DIR" ] && cp -r "$SCRIPTS_DIR" "$TMP_DIR/scripts" || echo "[WARN] No se encontrÃ³ carpeta de scripts"

# Comprimir backup
tar -czf "$BACKUP_FILE" -C "$TMP_DIR" .

# Borrar temporal
rm -rf "$TMP_DIR"

echo "[OK] Backup creado correctamente:"
echo "     $BACKUP_FILE"
