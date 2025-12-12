#!/bin/bash

# Crear la carpeta...
sudo mkdir -p /etc/lightdm/

# Ruta de origen (puedes modificarla si el archivo está en otro lugar)
ORIG_FILE="./lightdm-gtk-greeter.conf"

# Ruta de destino
DEST_DIR="/etc/lightdm/"

# Verifica si el archivo existe
if [ ! -f "$ORIG_FILE" ]; then
    echo "[-] El archivo $ORIG_FILE no existe."
    exit 1
fi

# Verifica si el directorio de destino existe
if [ ! -d "$DEST_DIR" ]; then
    echo "[-] El directorio $DEST_DIR no existe. Creándolo..."
    sudo mkdir -p "$DEST_DIR"
fi

# Copiar el archivo con sudo
echo "[+] Copiando $ORIG_FILE a $DEST_DIR ..."
sudo cp "$ORIG_FILE" "$DEST_DIR/"

# Confirmación
if [ $? -eq 0 ]; then
    echo "[✓] Archivo copiado exitosamente a $DEST_DIR"
else
    echo "[✗] Error al copiar el archivo."
    exit 1
fi
