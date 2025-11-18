#!/bin/sh

# Inicializamos contador
editors_count=0
editors_list=""

# Función de chequeo
check() {
  command -v "$1" >/dev/null 2>&1 && echo "$2"
}

# Editores de texto comunes
[ -n "$(check vim Vim)" ] && editors_list="$editors_list Vim" && editors_count=$((editors_count + 1))
[ -n "$(check nano Nano)" ] && editors_list="$editors_list Nano" && editors_count=$((editors_count + 1))
[ -n "$(check emacs Emacs)" ] && editors_list="$editors_list Emacs" && editors_count=$((editors_count + 1))
[ -n "$(check code VSCode)" ] && editors_list="$editors_list VSCode" && editors_count=$((editors_count + 1))
[ -n "$(check subl SublimeText)" ] && editors_list="$editors_list SublimeText" && editors_count=$((editors_count + 1))
[ -n "$(check gedit Gedit)" ] && editors_list="$editors_list Gedit" && editors_count=$((editors_count + 1))
[ -n "$(check kate Kate)" ] && editors_list="$editors_list Kate" && editors_count=$((editors_count + 1))
[ -n "$(check micro Micro)" ] && editors_list="$editors_list Micro" && editors_count=$((editors_count + 1))
[ -n "$(check neovim Neovim)" ] && editors_list="$editors_list Neovim" && editors_count=$((editors_count + 1))
[ -n "$(check joe Joe)" ] && editors_list="$editors_list Joe" && editors_count=$((editors_count + 1))

# Mostrar resultados
echo "Editores de texto encontrados: $editors_count ->$editors_list"
