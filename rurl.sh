#!/usr/bin/env bash

# rurl - Frontend sencillo para curl para reques manuales
# Requiere: curl

set -e

VERSION="1.0"

function header() {
    echo "========================================="
    echo " rurl - Cliente HTTP sencillo con curl"
    echo " Versión $VERSION"
    echo "========================================="
    echo
}

function usage() {
    cat <<EOF
Uso:
  curlx.sh [opciones]

Opciones:
  -u URL                URL de destino
  -X METODO             Método HTTP (GET, POST, PUT, DELETE, PATCH)
  -d DATA               Datos para enviar (JSON o query string)
  -H HEADER             Header adicional (puede repetirse)
  -a                    Activar autenticación básica
  -o ARCHIVO            Guardar respuesta en archivo
  -v                    Modo verbose
  -h                    Mostrar ayuda

Ejemplo:
  ./curlx.sh -u https://api.ejemplo.com -X POST -d '{"name":"juan"}' -H "Content-Type: application/json"

EOF
    exit 0
}

URL=""
METHOD="GET"
DATA=""
AUTH=""
OUTPUT=""
VERBOSE=0
HEADERS=()

while getopts "u:X:d:H:ao:vh" opt; do
    case $opt in
        u) URL="$OPTARG" ;;
        X) METHOD="$OPTARG" ;;
        d) DATA="$OPTARG" ;;
        H) HEADERS+=("-H" "$OPTARG") ;;
        a)
            read -p "Usuario: " USER
            read -s -p "Password: " PASS
            echo
            AUTH="-u $USER:$PASS"
            ;;
        o) OUTPUT="$OPTARG" ;;
        v) VERBOSE=1 ;;
        h) usage ;;
        *) usage ;;
    esac
done

if [[ -z "$URL" ]]; then
    echo "Error: Debes especificar una URL con -u"
    exit 1
fi

header

CMD=(curl -X "$METHOD" "$URL")

if [[ -n "$DATA" ]]; then
    CMD+=(-d "$DATA")
fi

if [[ ${#HEADERS[@]} -gt 0 ]]; then
    CMD+=("${HEADERS[@]}")
fi

if [[ -n "$AUTH" ]]; then
    CMD+=($AUTH)
fi

if [[ -n "$OUTPUT" ]]; then
    CMD+=(-o "$OUTPUT")
fi

if [[ $VERBOSE -eq 1 ]]; then
    CMD+=(-v)
else
    CMD+=(-s -w "\nHTTP Status: %{http_code}\n")
fi

echo "Ejecutando:"
echo "${CMD[@]}"
echo

"${CMD[@]}"

