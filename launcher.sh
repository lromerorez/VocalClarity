#!/bin/bash

# (Aquí incluir otras funciones de tu launcher existentes)

print_progress_bar() {
    local progress=$1
    local total=$2
    local width=40
    local percent=$(( 100 * progress / total ))
    local filled=$(( width * progress / total ))
    local empty=$(( width - filled ))
    printf "\r["
    for ((i=0; i<filled; i++)); do printf "#"; done
    for ((i=0; i<empty; i++)); do printf "-"; done
    printf "] %d%% (%d/%d)" "$percent" "$progress" "$total"
}

do_batch_process() {
    echo -e "\n### PROCESAMIENTO BATCH DE CARPETAS ###"

    if [ -z "$SUDO_USER" ]; then
        echo "Error: SUDO_USER no definido. Ejecuta este script con sudo."
        return 1
    fi

    read -p "Introduce la ruta completa de la carpeta o archivo a procesar: " input_path
    if [ ! -e "$input_path" ]; then
        echo "Error: La ruta '$input_path' no existe."
        return 1
    fi

    read -p "¿Quieres aplicar mejoras forenses? (s/N): " forensic_choice
    if [[ "$forensic_choice" =~ ^[Ss]$ ]]; then
        forensic_flag="--forensic"
    else
        forensic_flag=""
    fi

    read -p "¿Quieres activar la diarización y graficación? (s/N): " diarize_choice
    if [[ "$diarize_choice" =~ ^[Ss]$ ]]; then
        diarize_flag="--diarize"
    else
        diarize_flag=""
    fi

    OUTPUT_DIR="${PROJECT_DIR}/batch_output"
    mkdir -p "$OUTPUT_DIR"

    echo "Iniciando procesamiento batch..."

    sudo -u "$SUDO_USER" bash -c "
        cd \"$PROJECT_DIR\"
        python3 batch_audio_processor.py \"$input_path\" --output \"$OUTPUT_DIR\" $forensic_flag $diarize_flag
    " | while IFS= read -r line; do
        if [[ "$line" =~ PROGRESS\ ([0-9]+)/([0-9]+) ]]; then
            current=\${BASH_REMATCH[1]}
            total=\${BASH_REMATCH[2]}
            print_progress_bar "$current" "$total"
        elif [[ "$line" == "PROGRESS DONE" ]]; then
            print_progress_bar "$total" "$total"
            echo -e "\nProcesamiento completo."
        else
            echo "$line"
        fi
    done
}

# Integrar al menú principal, por ejemplo:

main_menu() {
    echo "### Menú VocalClarity Mejorado ###"
    if [ -f "${PROJECT_DIR}/${INSTALL_FLAG_FILE}" ]; then
        echo "1) Lanzar procesamiento batch de carpetas"
        echo "2) Lanzar script de procesamiento de audio (archivo único)"
        echo "3) Reinstalar dependencias"
        echo "4) Salir"
        read -p "Selecciona una opción [1-4]: " choice
        case "$choice" in
            1) do_batch_process ;;
            2) do_launch ;;  # suponiendo que existe do_launch para archivo individual
            3) do_reinstall ;;
            4) exit 0 ;;
            *) echo "Opción inválida." ;;
        esac
    else
        echo "Sistema no configurado."
        echo "1) Instalar dependencias y configurar"
        echo "2) Salir"
        read -p "Selecciona [1-2]: " choice
        case "$choice" in
            1) do_install ;;
            2) exit 0 ;;
            *) echo "Opción inválida." ;;
        esac
    fi
}

# Ejecución principal
main_menu
