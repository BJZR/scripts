#!/usr/bin/env bash

# download by curl - Descargador minimalista con interfaz TUI
# Requiere: curl

set -euo pipefail

VERSION="1.0"

# Colores suaves
BOLD="\e[1m"
GREEN="\e[32m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

function banner() {
  clear
  echo -e "${BOLD}dload${RESET}  v$VERSION"
  echo "----------------------------------------"
  echo
}

function pause() {
  echo
  read -rp "Presiona ENTER para continuar..."
}

function get_filename_from_url() {
  basename "${1%%\?*}"
}

function download() {
  local url="$1"
  local output="$2"

  echo
  echo -e "${CYAN}Descargando:${RESET} $url"
  echo -e "${CYAN}Destino:${RESET} $output"
  echo

  curl \
    --fail \
    --location \
    --continue-at - \
    --progress-bar \
    --output "$output" \
    "$url"

  echo
  echo -e "${GREEN}Descarga finalizada.${RESET}"
}

function main_menu() {
  banner
  echo "1) Nueva descarga"
  echo "2) Salir"
  echo
  read -rp "Selecciona opción: " opt

  case $opt in
  1) new_download ;;
  2) exit 0 ;;
  *) main_menu ;;
  esac
}

function new_download() {
  banner
  read -rp "URL: " url

  if [[ -z "$url" ]]; then
    echo -e "${RED}URL inválida${RESET}"
    pause
    main_menu
  fi

  default_name=$(get_filename_from_url "$url")
  read -rp "Nombre de archivo [$default_name]: " filename
  filename=${filename:-$default_name}

  read -rp "Directorio destino [$(pwd)]: " directory
  directory=${directory:-$(pwd)}

  mkdir -p "$directory"

  fullpath="$directory/$filename"

  download "$url" "$fullpath"

  pause
  main_menu
}

main_menu
