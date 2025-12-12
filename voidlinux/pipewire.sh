#!/bin/bash
set -e

# 🎨 Colores
VERDE='\033[1;32m'
AZUL='\033[1;34m'
RESET='\033[0m'

echo -e "${AZUL}"
echo "╔════════════════════════════════════════════════════╗"
echo "║         🎧 Instalador PipeWire para Void           ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Paso 1: Instalar paquetes
echo -e "📦 ${AZUL}Instalando paquetes necesarios...${RESET}"
sudo xbps-install -y pipewire wireplumber blueman libspa-bluetooth pavucontrol

# Paso 2: Agregar usuario al grupo bluetooth
echo -e "👤 ${AZUL}Agregando el usuario '$USER' al grupo bluetooth...${RESET}"
sudo usermod -aG bluetooth "$USER"

# Paso 3: Activar el servicio bluetooth
echo -e "👤 ${AZUL}Agregando el servicio bluetooth...${RESET}"
sudo ln -s /etc/sv/bluetoothd /var/service

# Mensaje final
echo -e "\n${VERDE}✅ Instalación y configuración completada.${RESET}"
echo -e "${AZUL}🔁 Reinicia tu sesión o el sistema para aplicar los cambios.${RESET}\n"
