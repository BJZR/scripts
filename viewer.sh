#!/usr/bin/env bash

# Carpeta con archivos
folder="${1:-.}"  # por defecto la carpeta actual

# Leer todos los archivos (solo regulares)
files=($(find "$folder" -maxdepth 1 -type f | sort))

# Función para mostrar el menú de archivos
menu() {
  local selected=0
  while true; do
    clear
    echo "Selecciona un archivo con Enter (Esc para salir):"
    for i in "${!files[@]}"; do
      if [[ $i -eq $selected ]]; then
        echo -e "> \033[1;32m$(basename "${files[$i]}")\033[0m"
      else
        echo "  $(basename "${files[$i]}")"
      fi
    done

    # Leer tecla
    read -rsn1 key
    case "$key" in
      $'\x1b')  # Esc
        exit 0
        ;;
      $'\x0a')  # Enter
        view_file "${files[$selected]}"
        ;;
      $'\x1b')  # Arrow keys start with escape sequence
        read -rsn2 key2
        case "$key2" in
          '[A') ((selected--)); [[ $selected -lt 0 ]] && selected=0 ;;
          '[B') ((selected++)); [[ $selected -ge ${#files[@]} ]] && selected=$((${#files[@]}-1)) ;;
        esac
        ;;
    esac
  done
}

# Función para ver archivo con scroll
view_file() {
  local file="$1"
  mapfile -t lines < "$file"
  local rows=$(tput lines)
  local start=0
  local end=$((rows-2))

  while true; do
    clear
    echo "Archivo: $(basename "$file")"
    for i in $(seq $start $end); do
      [[ $i -ge ${#lines[@]} ]] && break
      echo "${lines[$i]}"
    done
    if ((end >= ${#lines[@]}-1)); then
      echo "--- Fin del archivo ---"
    elif ((start == 0)); then
      echo "--- Comienzo del archivo ---"
    else
      echo "--- ---"
    fi

    # Leer flecha
    read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key2
      case "$key2" in
        '[A') ((start--)); ((end--)); ((start<0)) && start=0; end=$((start+rows-2)) ;;
        '[B') ((start++)); ((end++)); ((end>=${#lines[@]})) && end=${#lines[@]}-1; start=$((end-rows+2)); ((start<0)) && start=0 ;;
      esac
    elif [[ $key == $'\x1b' ]]; then  # Esc para salir del archivo
      return
    fi
  done
}

menu