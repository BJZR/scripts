#!/bin/sh

# Inicializamos contadores
interp=0
comp=0
script=0
embed=0
tools=0

# Función de chequeo
check() {
  command -v "$1" >/dev/null 2>&1 && echo "$2"
}

# Arrays para almacenar nombres
interp_langs=""
comp_langs=""
script_langs=""
embed_langs=""
tools_list=""

# Lenguajes interpretados
[ -n "$(check python Python)" ] && interp_langs="$interp_langs Python" && interp=$((interp + 1))
[ -n "$(check python3 Python3)" ] && interp_langs="$interp_langs Python3" && interp=$((interp + 1))
[ -n "$(check ruby Ruby)" ] && interp_langs="$interp_langs Ruby" && interp=$((interp + 1))
[ -n "$(check perl Perl)" ] && interp_langs="$interp_langs Perl" && interp=$((interp + 1))
[ -n "$(check php PHP)" ] && interp_langs="$interp_langs PHP" && interp=$((interp + 1))
[ -n "$(check node Node.js)" ] && interp_langs="$interp_langs Node.js" && interp=$((interp + 1))
[ -n "$(check lua Lua)" ] && interp_langs="$interp_langs Lua" && interp=$((interp + 1))
[ -n "$(check dart Dart)" ] && interp_langs="$interp_langs Dart" && interp=$((interp + 1))

# Lenguajes compilables
[ -n "$(check gcc C)" ] && comp_langs="$comp_langs C" && comp=$((comp + 1))
[ -n "$(check g++ C++)" ] && comp_langs="$comp_langs C++" && comp=$((comp + 1))
[ -n "$(check javac Java)" ] && comp_langs="$comp_langs Java" && comp=$((comp + 1))
[ -n "$(check rustc Rust)" ] && comp_langs="$comp_langs Rust" && comp=$((comp + 1))
[ -n "$(check go Go)" ] && comp_langs="$comp_langs Go" && comp=$((comp + 1))
[ -n "$(check kotlin Kotlin)" ] && comp_langs="$comp_langs Kotlin" && comp=$((comp + 1))
[ -n "$(check swift Swift)" ] && comp_langs="$comp_langs Swift" && comp=$((comp + 1))
[ -n "$(check scala Scala)" ] && comp_langs="$comp_langs Scala" && comp=$((comp + 1))

# Lenguajes de scripting
[ -n "$(check bash Bash)" ] && script_langs="$script_langs Bash" && script=$((script + 1))
[ -n "$(check zsh Zsh)" ] && script_langs="$script_langs Zsh" && script=$((script + 1))

# Lenguajes embebidos
[ -n "$(check arduino-cli Arduino)" ] && embed_langs="$embed_langs Arduino" && embed=$((embed + 1))
[ -n "$(check esptool esptool)" ] && embed_langs="$embed_langs ESP" && embed=$((embed + 1))

# Herramientas complementarias
[ -n "$(check npm NPM)" ] && tools_list="$tools_list NPM" && tools=$((tools + 1))
[ -n "$(check pip Pip)" ] && tools_list="$tools_list Pip" && tools=$((tools + 1))
[ -n "$(check pip3 Pip3)" ] && tools_list="$tools_list Pip3" && tools=$((tools + 1))
[ -n "$(check cargo Cargo)" ] && tools_list="$tools_list Cargo" && tools=$((tools + 1))

# Mostrar resultados
echo "Interpretados: $interp ->$interp_langs"
echo "Compilables: $comp ->$comp_langs"
echo "Scripting: $script ->$script_langs"
echo "Embebidos: $embed ->$embed_langs"
echo "Herramientas complementarias: $tools ->$tools_list"

# Suma total
total=$((interp + comp + script + embed + tools))
echo "Total detectado: $total"
