#!/bin/sh

echo "=== Información del Sistema ==="
echo "Usuario: $(whoami)"
echo "Host: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Distro: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '\"')"

echo
echo "=== Hardware ==="
echo "CPU: $(lscpu | grep 'Nombre del modelo' | cut -d ':' -f2 | sed 's/^ //')"
echo "RAM total: $(free -h | awk '/Mem:/ {print $2}')"
echo "Espacio disco /: $(df -h / | awk 'NR==2 {print $4 " libres de " $2}')"

echo
echo "=== Entorno ==="
echo "Shell: $SHELL"
echo "Terminal: $TERM"
