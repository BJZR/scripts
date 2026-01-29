#!/usr/bin/env bash
# SuperShell - VersiÃ³n funcional y sencilla

# 1. Verificar que se ejecute en un terminal interactivo
if ! tty -s; then
  echo "SuperShell debe ejecutarse en un terminal interactivo." >&2
  exit 1
fi

# 2. Relanzar como shell interactivo si es necesario
if [[ $- != *i* ]]; then
  exec bash --rcfile <(echo ". $0; exit") -i
  exit
fi

# 3. Directorios base
SUPERSHELL_DIR="$HOME/.supershell"
HISTFILE="$SUPERSHELL_DIR/history"
PLUGINS_DIR="$SUPERSHELL_DIR/plugins"
LOGS_DIR="$SUPERSHELL_DIR/logs"
mkdir -p "$SUPERSHELL_DIR" "$PLUGINS_DIR" "$LOGS_DIR"

# 4. Prompt con colores
PS1="|Shell|$ "

# 5. Alias internos
declare -A ALIASES

log_cmd() {
  echo "$(date '+%H:%M:%S') | $1" >>"$LOGS_DIR/$(date '+%Y-%m-%d').log"
}

execute_internal() {
  local cmd="$1"
  shift
  case "$cmd" in
  exit)
    echo "Cerrando SuperShellâ€¦"
    exit 0
    ;;
  cd)
    cd "$1" 2>/dev/null || echo "[ERR] No se puede entrar a: $1"
    ;;
  alias)
    if [[ -z "$1" ]]; then
      for a in "${!ALIASES[@]}"; do
        echo "$a='${ALIASES[$a]}'"
      done
    else
      key="${1%%=*}"
      val="${1#*=}"
      ALIASES["$key"]="$val"
    fi
    ;;
  help)
    echo "Comandos internos: exit, cd, alias, help"
    ;;
  *)
    return 1
    ;;
  esac
  return 0
}

# 6. Loop principal
while true; do
  read -e -p "$PS1" cmd_raw
  echo "$cmd_raw" >>"$HISTFILE"
  log_cmd "$cmd_raw"
  cmd="$(echo "$cmd_raw" | sed 's/^[ \t]*//;s/[ \t]*$//' | tr 'A-Z' 'a-z')"
  [[ -z "$cmd" ]] && continue
  args=($cmd)
  execute_internal "${args[@]}"
  if [[ $? -eq 0 ]]; then
    continue
  fi
  for a in "${!ALIASES[@]}"; do
    [[ "$cmd" == "$a"* ]] && cmd="${cmd//$a/${ALIASES[$a]}}"
  done
  eval "$cmd_raw" 2>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "[ERR] Comando no reconocido: $cmd_raw"
  fi
done
