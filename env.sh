#!/bin/sh

# pkg-config path
export PKG_CONFIG_PATH=$ENV_ACTIVE/share/pkgconfig:$PKG_CONFIG_PATH

BASE_DIR="$HOME/.local/envs"
VERSION="1.0.0"

# =============================================================================
# UTILIDADES
# =============================================================================

log_info() {
  printf "\033[32m[✓]\033[0m %s\n" "$1"
}

log_error() {
  printf "\033[31m[✗]\033[0m %s\n" "$1" >&2
}

log_warn() {
  printf "\033[33m[!]\033[0m %s\n" "$1"
}

ensure_env_exists() {
  NAME="$1"
  ENV_DIR="$BASE_DIR/$NAME"
  if [ ! -d "$ENV_DIR" ]; then
    log_error "El entorno '$NAME' no existe."
    return 1
  fi
  return 0
}

# =============================================================================
# CREAR ENTORNO
# =============================================================================

create_env() {
  NAME="$1"
  [ -z "$NAME" ] && {
    log_error "Falta nombre del entorno."
    echo "Uso: ./env.sh create <nombre>"
    exit 1
  }

  ENV_DIR="$BASE_DIR/$NAME"

  if [ -d "$ENV_DIR" ]; then
    log_error "El entorno '$NAME' ya existe."
    exit 1
  fi

  # Crear estructura de directorios
  mkdir -p "$ENV_DIR/bin"
  mkdir -p "$ENV_DIR/lib"
  mkdir -p "$ENV_DIR/lib/pkgconfig"
  mkdir -p "$ENV_DIR/include"
  mkdir -p "$ENV_DIR/share"
  mkdir -p "$ENV_DIR/config"
  mkdir -p "$ENV_DIR/src"
  mkdir -p "$ENV_DIR/.env"

  # Crear archivo de metadata
  cat >"$ENV_DIR/.env/metadata.txt" <<EOF
NAME=$NAME
CREATED=$(date +%Y-%m-%d\ %H:%M:%S)
VERSION=$VERSION
EOF

  # Crear archivo de paquetes instalados (vacío)
  touch "$ENV_DIR/.env/packages.txt"

  # Crear archivo de configuración
  cat >"$ENV_DIR/.env/config.sh" <<'EOF'
# Configuración del entorno
# Puedes agregar variables personalizadas aquí
EOF

  log_info "Entorno '$NAME' creado exitosamente"
  echo "  Ubicación: $ENV_DIR"
  echo ""
  echo "Para activarlo: source env.sh activate $NAME"
}

# =============================================================================
# DESACTIVAR ENTORNO
# =============================================================================

deactivate_env() {
  if [ -z "$ENV_ACTIVE" ]; then
    log_warn "No hay entorno activo para desactivar."
    return
  fi

  # Restaurar PATH
  if [ -n "$_OLD_PATH" ]; then
    export PATH="$_OLD_PATH"
    unset _OLD_PATH
  fi

  # Restaurar PS1
  if [ -n "$_OLD_PS1" ]; then
    export PS1="$_OLD_PS1"
    unset _OLD_PS1
  fi

  # Restaurar PKG_CONFIG_PATH
  if [ -n "$_OLD_PKG_CONFIG_PATH" ]; then
    export PKG_CONFIG_PATH="$_OLD_PKG_CONFIG_PATH"
    unset _OLD_PKG_CONFIG_PATH
  else
    unset PKG_CONFIG_PATH
  fi

  # Restaurar LD_LIBRARY_PATH
  if [ -n "$_OLD_LD_LIBRARY_PATH" ]; then
    export LD_LIBRARY_PATH="$_OLD_LD_LIBRARY_PATH"
    unset _OLD_LD_LIBRARY_PATH
  else
    unset LD_LIBRARY_PATH
  fi

  # Restaurar CFLAGS y LDFLAGS
  if [ -n "$_OLD_CFLAGS" ]; then
    export CFLAGS="$_OLD_CFLAGS"
    unset _OLD_CFLAGS
  else
    unset CFLAGS
  fi

  if [ -n "$_OLD_LDFLAGS" ]; then
    export LDFLAGS="$_OLD_LDFLAGS"
    unset _OLD_LDFLAGS
  else
    unset LDFLAGS
  fi

  ENV_NAME=$(basename "$ENV_ACTIVE")
  log_info "Entorno '$ENV_NAME' desactivado"
  unset ENV_ACTIVE
  unset ENV_NAME
}

# =============================================================================
# ACTIVAR ENTORNO
# =============================================================================

activate_env() {
  NAME="$1"
  [ -z "$NAME" ] && {
    log_error "Falta nombre del entorno."
    echo "Uso: source env.sh activate <nombre>"
    return
  }

  ENV_DIR="$BASE_DIR/$NAME"
  [ ! -d "$ENV_DIR" ] && {
    log_error "El entorno '$NAME' no existe."
    return
  }

  # Evitar activar el mismo entorno
  if [ "$ENV_ACTIVE" = "$ENV_DIR" ]; then
    log_warn "El entorno '$NAME' ya está activo."
    return
  fi

  # Desactivar entorno previo
  if [ -n "$ENV_ACTIVE" ]; then
    deactivate_env
  fi

  export ENV_ACTIVE="$ENV_DIR"

  # Guardar y modificar PATH
  export _OLD_PATH="$PATH"
  export PATH="$ENV_DIR/bin:$PATH"

  # Guardar y modificar PKG_CONFIG_PATH
  export _OLD_PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
  export PKG_CONFIG_PATH="$ENV_DIR/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

  # Guardar y modificar LD_LIBRARY_PATH
  export _OLD_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH="$ENV_DIR/lib:${LD_LIBRARY_PATH:-}"

  # Guardar y modificar CFLAGS
  export _OLD_CFLAGS="$CFLAGS"
  export CFLAGS="-I$ENV_DIR/include ${CFLAGS:-}"

  # Guardar y modificar LDFLAGS
  export _OLD_LDFLAGS="$LDFLAGS"
  export LDFLAGS="-L$ENV_DIR/lib ${LDFLAGS:-}"

  # Modificar prompt
  if [ -n "$PS1" ]; then
    export _OLD_PS1="$PS1"
    export PS1="(env:$NAME) $PS1"
  fi

  # Cargar configuración personalizada si existe
  if [ -f "$ENV_DIR/.env/config.sh" ]; then
    . "$ENV_DIR/.env/config.sh"
  fi

  log_info "Entorno '$NAME' activado"
  echo "  PATH: $ENV_DIR/bin"
  echo "  Paquetes instalados: $(wc -l <"$ENV_DIR/.env/packages.txt" 2>/dev/null || echo 0)"
  echo ""
  echo "Usa estos comandos:"
  echo "  ./env.sh install <paquete>  - Instalar paquete"
  echo "  ./env.sh packages           - Listar paquetes"
  echo "  ./env.sh freeze [archivo]   - Exportar dependencias"
}

# =============================================================================
# ELIMINAR ENTORNO
# =============================================================================

remove_env() {
  NAME="$1"
  [ -z "$NAME" ] && {
    log_error "Falta nombre del entorno."
    echo "Uso: ./env.sh remove <nombre>"
    exit 1
  }

  ENV_DIR="$BASE_DIR/$NAME"

  if [ ! -d "$ENV_DIR" ]; then
    log_error "El entorno '$NAME' no existe."
    exit 1
  fi

  # Prevenir eliminar entorno activo
  if [ "$ENV_ACTIVE" = "$ENV_DIR" ]; then
    log_error "No puedes eliminar el entorno activo."
    echo "Primero desactívalo con: deactivate_env"
    exit 1
  fi

  # Confirmación
  printf "¿Estás seguro de eliminar el entorno '%s'? [y/N] " "$NAME"
  read -r confirm
  case "$confirm" in
  [yY] | [yY][eE][sS])
    rm -rf "$ENV_DIR"
    log_info "Entorno '$NAME' eliminado."
    ;;
  *)
    log_warn "Operación cancelada."
    ;;
  esac
}

# =============================================================================
# LISTAR ENTORNOS
# =============================================================================

list_env() {
  mkdir -p "$BASE_DIR"

  if [ -z "$(ls -A "$BASE_DIR" 2>/dev/null)" ]; then
    log_warn "No hay entornos creados."
    echo "Crea uno con: ./env.sh create <nombre>"
    return
  fi

  echo "Entornos disponibles:"
  echo ""

  for env in "$BASE_DIR"/*; do
    if [ -d "$env" ]; then
      ENV_NAME=$(basename "$env")
      METADATA="$env/.env/metadata.txt"
      PKG_COUNT=$(wc -l <"$env/.env/packages.txt" 2>/dev/null || echo 0)

      if [ "$ENV_ACTIVE" = "$env" ]; then
        printf "  \033[32m●\033[0m %s (activo)\n" "$ENV_NAME"
      else
        printf "    %s\n" "$ENV_NAME"
      fi

      if [ -f "$METADATA" ]; then
        CREATED=$(grep "^CREATED=" "$METADATA" | cut -d= -f2)
        printf "      Creado: %s\n" "$CREATED"
      fi

      printf "      Paquetes: %d\n" "$PKG_COUNT"
      printf "      Ubicación: %s\n" "$env"
      echo ""
    fi
  done
}

# =============================================================================
# ESTADO
# =============================================================================

status_env() {
  if [ -z "$ENV_ACTIVE" ]; then
    log_warn "No hay entorno activo."
    echo ""
    echo "Entornos disponibles:"
    list_env
    return
  fi

  ENV_NAME=$(basename "$ENV_ACTIVE")
  METADATA="$ENV_ACTIVE/.env/metadata.txt"
  PKG_COUNT=$(wc -l <"$ENV_ACTIVE/.env/packages.txt" 2>/dev/null || echo 0)

  echo "Estado del entorno:"
  echo ""
  echo "  Nombre: $ENV_NAME"
  echo "  Ubicación: $ENV_ACTIVE"
  echo "  Paquetes instalados: $PKG_COUNT"

  if [ -f "$METADATA" ]; then
    CREATED=$(grep "^CREATED=" "$METADATA" | cut -d= -f2)
    echo "  Creado: $CREATED"
  fi

  echo ""
  echo "Variables de entorno:"
  echo "  PATH: $ENV_ACTIVE/bin"
  echo "  PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
  echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
}

# =============================================================================
# INSTALAR PAQUETE
# =============================================================================

install_pkg() {
  if [ -z "$ENV_ACTIVE" ]; then
    log_error "Debes activar un entorno primero."
    echo "Uso: source env.sh activate <nombre>"
    return 1
  fi

  RECIPE="$1"
  [ -z "$RECIPE" ] && {
    log_error "Falta nombre del paquete o URL."
    echo "Uso: install <paquete|url>"
    return 1
  }

  ENV_NAME=$(basename "$ENV_ACTIVE")
  RECIPE_DIR="$HOME/.local/envs/.recipes"

  # Verificar si es una receta conocida
  if [ -f "$RECIPE_DIR/$RECIPE.sh" ]; then
    log_info "Instalando '$RECIPE' desde receta..."
    . "$RECIPE_DIR/$RECIPE.sh"
    install_recipe

    # Registrar paquete instalado
    echo "$RECIPE:$(date +%Y-%m-%d)" >>"$ENV_ACTIVE/.env/packages.txt"
    log_info "Paquete '$RECIPE' instalado exitosamente"
  else
    # Instalación manual desde URL o tarball
    log_info "Instalación manual de: $RECIPE"
    echo "Descarga el paquete y compílalo con:"
    echo "  cd $ENV_ACTIVE/src"
    echo "  wget <url>"
    echo "  tar -xzf <archivo>.tar.gz"
    echo "  cd <carpeta>"
    echo "  ./configure --prefix=\"\$ENV_ACTIVE\" && make && make install"
    echo "O con meson:"
    echo "  meson setup build --prefix=\"\$ENV_ACTIVE\""
    echo "  ninja -C build && ninja -C build install"
  fi
}

# =============================================================================
# LISTAR PAQUETES INSTALADOS
# =============================================================================

list_packages() {
  if [ -z "$ENV_ACTIVE" ]; then
    log_error "Debes activar un entorno primero."
    return 1
  fi

  ENV_NAME=$(basename "$ENV_ACTIVE")
  PKG_FILE="$ENV_ACTIVE/.env/packages.txt"

  if [ ! -s "$PKG_FILE" ]; then
    log_warn "No hay paquetes instalados en '$ENV_NAME'."
    return
  fi

  echo "Paquetes instalados en '$ENV_NAME':"
  echo ""

  while IFS=: read -r pkg date; do
    printf "  • %s (instalado: %s)\n" "$pkg" "$date"
  done <"$PKG_FILE"
}

# =============================================================================
# EXPORTAR/CONGELAR DEPENDENCIAS
# =============================================================================

freeze_env() {
  if [ -z "$ENV_ACTIVE" ]; then
    log_error "Debes activar un entorno primero."
    return 1
  fi

  ENV_NAME=$(basename "$ENV_ACTIVE")
  OUTPUT="${1:-$ENV_NAME-freeze.txt}"

  cat >"$OUTPUT" <<EOF
# Entorno: $ENV_NAME
# Creado: $(date +%Y-%m-%d\ %H:%M:%S)
# Generado por env.sh v$VERSION

EOF

  cat "$ENV_ACTIVE/.env/packages.txt" >>"$OUTPUT"

  log_info "Dependencias exportadas a: $OUTPUT"
}

# =============================================================================
# CLONAR ENTORNO
# =============================================================================

clone_env() {
  SOURCE="$1"
  TARGET="$2"

  [ -z "$SOURCE" ] || [ -z "$TARGET" ] && {
    log_error "Faltan argumentos."
    echo "Uso: ./env.sh clone <origen> <destino>"
    exit 1
  }

  SOURCE_DIR="$BASE_DIR/$SOURCE"
  TARGET_DIR="$BASE_DIR/$TARGET"

  if [ ! -d "$SOURCE_DIR" ]; then
    log_error "El entorno '$SOURCE' no existe."
    exit 1
  fi

  if [ -d "$TARGET_DIR" ]; then
    log_error "El entorno '$TARGET' ya existe."
    exit 1
  fi

  log_info "Clonando entorno '$SOURCE' → '$TARGET'..."
  cp -r "$SOURCE_DIR" "$TARGET_DIR"

  # Actualizar metadata
  sed -i "s/NAME=$SOURCE/NAME=$TARGET/" "$TARGET_DIR/.env/metadata.txt"
  echo "CLONED_FROM=$SOURCE" >>"$TARGET_DIR/.env/metadata.txt"
  echo "CLONED_AT=$(date +%Y-%m-%d\ %H:%M:%S)" >>"$TARGET_DIR/.env/metadata.txt"

  log_info "Entorno clonado exitosamente"
}

# =============================================================================
# INFORMACIÓN DEL ENTORNO
# =============================================================================

info_env() {
  NAME="$1"
  [ -z "$NAME" ] && {
    log_error "Falta nombre del entorno."
    echo "Uso: ./env.sh info <nombre>"
    exit 1
  }

  ensure_env_exists "$NAME" || exit 1

  ENV_DIR="$BASE_DIR/$NAME"
  METADATA="$ENV_DIR/.env/metadata.txt"

  echo "Información del entorno '$NAME':"
  echo ""

  if [ -f "$METADATA" ]; then
    while IFS= read -r line; do
      echo "  $line"
    done <"$METADATA"
  fi

  echo ""
  echo "Estructura:"
  echo "  Binarios: $ENV_DIR/bin ($(find "$ENV_DIR/bin" -type f 2>/dev/null | wc -l) archivos)"
  echo "  Librerías: $ENV_DIR/lib ($(find "$ENV_DIR/lib" -type f 2>/dev/null | wc -l) archivos)"
  echo "  Headers: $ENV_DIR/include"
  echo "  Código fuente: $ENV_DIR/src"

  PKG_COUNT=$(wc -l <"$ENV_DIR/.env/packages.txt" 2>/dev/null || echo 0)
  echo ""
  echo "  Paquetes instalados: $PKG_COUNT"
}

# =============================================================================
# CLI
# =============================================================================

case "$1" in
create)
  create_env "$2"
  ;;
activate)
  activate_env "$2"
  ;;
deactivate)
  deactivate_env
  ;;
remove)
  remove_env "$2"
  ;;
list)
  list_env
  ;;
status)
  status_env
  ;;
install)
  install_pkg "$2"
  ;;
packages)
  list_packages
  ;;
freeze)
  freeze_env "$2"
  ;;
clone)
  clone_env "$2" "$3"
  ;;
info)
  info_env "$2"
  ;;
version)
  echo "env.sh version $VERSION"
  ;;
*)
  cat <<'EOF'
env.sh - Gestor de Entornos Virtuales para C/C++

Uso:
  Gestión de entornos:
    ./env.sh create <nombre>           Crear nuevo entorno
    source env.sh activate <nombre>    Activar entorno
    deactivate_env                     Desactivar entorno actual
    ./env.sh remove <nombre>           Eliminar entorno
    ./env.sh clone <origen> <destino>  Clonar entorno
    
  Información:
    ./env.sh list                      Listar todos los entornos
    ./env.sh status                    Ver entorno activo
    ./env.sh info <nombre>             Ver información detallada
    
  Paquetes:
    install <paquete>                  Instalar paquete (con entorno activo)
    packages                           Listar paquetes instalados
    freeze [archivo]                   Exportar dependencias
    
  Otros:
    ./env.sh version                   Ver versión

Ejemplo de flujo:
  ./env.sh create mi_proyecto
  source env.sh activate mi_proyecto
  cd $ENV_ACTIVE/src
  # ... compilar e instalar librerías ...
  packages
  freeze mi_proyecto-deps.txt
  deactivate_env

EOF
  ;;
esac

