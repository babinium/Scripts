#!/bin/bash

# Script para listar programas instalados, agrupados por tipo de paquete y letra.

# --- Definición de Colores y Estilos ---
export BOLD_CYAN=$(printf '\033[1;36m')
export GREEN=$(printf '\033[1;32m')
export NC=$(printf '\033[0m')

# --- Función de Formateo Portátil ---
format_and_print() {
    # awk agrupa los paquetes por letra, sort los ordena alfabéticamente,
    # y sed se encarga del formato final.
    awk '
    {
        if ($0 ~ /^[[:space:]]*$/) next; # Ignorar líneas vacías
        char = toupper(substr($0, 1, 1));
        if (char !~ /[A-Z]/) { char = "#" }; # Agrupar no-letras
        packages[char] = packages[char] $0 ", ";
    }
    END {
        for (key in packages) {
            # Elimina la coma y el espacio finales
            sub(/, $/, "", packages[key]);
            print key "@@@" packages[key];
        }
    }' | sort | sed -e "s/\\(.*\\)@@@\\(.*\\)/\\1:\\n  \\2/" -e "G"
}

# --- Función para Imprimir Encabezados ---
print_header() {
    echo ""
    echo -e "${BOLD_CYAN}#####################################################################${NC}"
    echo -e "${BOLD_CYAN}# $1${NC}"
    echo -e "${BOLD_CYAN}#####################################################################${NC}"
    echo ""
}

# --- SECCIÓN 1: Paquetes .deb ---
print_header "Programas instalados como paquetes .deb"
dpkg-query -W -f='${binary:Package}\n' | grep -v -- '-dev\b' | format_and_print

# --- SECCIÓN 2: Paquetes Flatpak ---
if command -v flatpak &> /dev/null; then
    print_header "Programas instalados como Flatpaks"
    # Usamos '--columns=application' para obtener un ID único y consistente.
    flatpak list --app --columns=application | format_and_print
else
    print_header "Flatpak no encontrado"
    echo "El gestor de paquetes Flatpak no parece estar instalado."
fi

# --- SECCIÓN 3: Paquetes Snap ---
if command -v snap &> /dev/null; then
    print_header "Programas instalados como Snaps"
    # Tomamos solo la primera columna (nombre del paquete) del listado.
    snap list | awk 'NR>1 {print $1}' | format_and_print
else
    print_header "Snap no encontrado"
    echo "El gestor de paquetes Snap no parece estar instalado."
fi

echo ""
echo "---------------------------------------------------------------------"
echo "Análisis de programas completado."
echo "---------------------------------------------------------------------"
