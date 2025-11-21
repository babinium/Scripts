#!/bin/bash

# Script para listar programas instalados, con opciones de filtrado y agrupados por tipo.

# --- Definición de Colores y Estilos ---
export BOLD_CYAN=$(printf '\033[1;36m')
export NC=$(printf '\033[0m')

# --- Función de Formateo Portátil ---
# Recibe la entrada de una lista de programas, los agrupa por letra y los imprime.
format_and_print() {
    # awk agrupa los paquetes por letra, sort los ordena alfabéticamente,
    # y sed se encarga del formato final.
    awk ' \
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

# --- Función Auxiliar para procesar archivos .desktop ---
# Argumentos: Directorios donde buscar los archivos .desktop
process_desktop_files() {
    declare -a dirs_to_process=($@)
    local output

    output=$(find "${dirs_to_process[@]}" -maxdepth 1 -type f -name "*.desktop" 2>/dev/null -exec awk -F= ' \
        BEGIN {
            name_es="";
            name_generic="";
            nodisplay=0;
        }
        /^Name\[es\]=/ { name_es=$2; }
        /^Name=/ { if (name_generic == "") name_generic=$2; }
        /^NoDisplay=true/ { nodisplay=1; }
        END {
            if (nodisplay == 0) {
                if (name_es != "") {
                    print name_es;
                } else if (name_generic != "") {
                    print name_generic;
                }
            }
        }' {} \;)
    
    if [ -n "$output" ]; then
        echo "$output" | sort -u | format_and_print
    else
        echo "  No se encontraron aplicaciones en esta categoría."
        echo ""
    fi
}


# --- FUNCIÓN OPCIÓN 1: Mostrar solo aplicaciones del menú, AGRUPADAS ---
mostrar_aplicaciones_menu() {
    
    print_header "Menú: Paquetes APT/Debian (.deb)"
    process_desktop_files "/usr/share/applications"

    if command -v flatpak &> /dev/null; then
        print_header "Menú: Aplicaciones Flatpak"
        process_desktop_files "/var/lib/flatpak/exports/share/applications"
    fi

    if command -v snap &> /dev/null; then
        print_header "Menú: Aplicaciones Snap"
        process_desktop_files "/var/lib/snapd/desktop/applications"
    fi
    
    print_header "Menú: Aplicaciones de Usuario (.local)"
    process_desktop_files "$HOME/.local/share/applications"
    
    echo "Nota: Lista generada de accesos directos (.desktop). Puede no ser exhaustiva."
}

# --- FUNCIÓN OPCIÓN 2: Mostrar todos los paquetes ---
mostrar_todo() {
    # SECCIÓN 1: Paquetes .deb
    print_header "Todos: Paquetes .deb (APT/dpkg)"
    dpkg-query -W -f='${binary:Package}\n' | grep -v -- '-dev\b' | format_and_print

    # SECCIÓN 2: Paquetes Flatpak
    if command -v flatpak &> /dev/null; then
        print_header "Todos: Aplicaciones Flatpak"
        flatpak list --app --columns=application | format_and_print
    fi

    # SECCIÓN 3: Paquetes Snap
    if command -v snap &> /dev/null; then
        print_header "Todos: Aplicaciones Snap"
        snap list | awk 'NR>1 {print $1}' | format_and_print
    fi
}

# --- MENÚ DE SELECCIÓN ---
echo "Seleccione una opción:"
echo "1) Mostrar solo programas del MENÚ DE APLICACIONES (agrupados por tipo)"
echo "2) Mostrar TODOS los paquetes instalados (agrupados por tipo)"
echo ""
read -p "Opción [1-2]: " choice

case $choice in
    1)
        mostrar_aplicaciones_menu
        ;;
    2)
        mostrar_todo
        ;;
    *)
        echo "Opción no válida. Saliendo."
        exit 1
        ;;
esac

echo ""
echo "---------------------------------------------------------------------"
echo "Análisis de programas completado."
echo "---------------------------------------------------------------------"
