#!/bin/bash

# --- VARIABLES DE CONFIGURACIÓN ---
SPLEETER_VENV_NAME="spleeter_env"
PYTHON_VERSION="3.8.10" # Versión de Python compatible con Spleeter
PROJECT_DIR="$(pwd)" # El directorio actual donde se ejecuta el script

# --- ARCHIVOS DE REQUISITOS Y SCRIPT PRINCIPAL (asegúrate de que existan) ---
REQUIREMENTS_FILE="requirements.txt"
AUDIO_PROCESSOR_SCRIPT="audio_processor.py"

# --- ARCHIVO FLAG DE INSTALACIÓN ---
INSTALL_FLAG_FILE=".installation_complete_flag" # Nombre del archivo flag

# --- FUNCIONES DE INSTALACIÓN POR DISTRIBUCIÓN ---

install_debian_dependencies() {
    echo "## Configurando dependencias para Debian/Kali/Nethunter ##"
    echo "Actualizando el sistema y instalando paquetes esenciales..."
    sudo apt update && sudo apt upgrade -y || { echo "Error al actualizar/instalar paquetes apt. Abortando."; return 1; }
    sudo apt install sox ffmpeg python3 python3-pip python3-venv \
        build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
        libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y || \
        { echo "Error al instalar dependencias de Debian. Abortando."; return 1; }
    echo "Dependencias de Debian instaladas correctamente."
    return 0
}

install_arch_dependencies() {
    echo "## Configurando dependencias para Arch Linux ##"
    echo "Actualizando el sistema y instalando paquetes esenciales..."
    sudo pacman -Syu || { echo "Error al actualizar/instalar paquetes pacman. Abortando."; return 1; }
    sudo pacman -S sox ffmpeg python python-pip python-virtualenv \
        base-devel openssl zlib bzip2 readline sqlite libffi ncurses xz tk --noconfirm || \
        { echo "Error al instalar dependencias de Arch. Abortando."; return 1; }

    echo "Verificando instalación de yay (o paru)..."
    if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
        echo "Yay o Paru no encontrados. Se recomienda instalar uno para pyenv."
        read -p "¿Deseas instalar yay? (s/n): " install_yay
        if [[ "$install_yay" =~ ^[Ss]$ ]]; then
            echo "Instalando yay..."
            sudo pacman -S --needed git base-devel --noconfirm
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            (cd /tmp/yay && makepkg -si --noconfirm) || { echo "Error al instalar yay. Abortando."; return 1; }
            rm -rf /tmp/yay
        else
            echo "pyenv deberá ser instalado manualmente si no usas un AUR helper."
        fi
    fi
    echo "Dependencias de Arch instaladas correctamente."
    return 0
}

# --- FUNCIONES COMUNES DE PYENV Y SPLEETER ---

# MODIFICACIÓN CLAVE: install_pyenv ahora verifica la existencia del ejecutable de pyenv directamente.
install_pyenv() {
    echo "## Verificando pyenv ##"
    if [ -z "$SUDO_USER" ]; then
        echo "Error: SUDO_USER no está definido. Este script debe ejecutarse con 'sudo'."
        return 1
    fi

    # Obtener el directorio personal del usuario que invocó sudo
    # Usamos 'sudo -u "$SUDO_USER" printenv HOME' para asegurarnos de obtener el HOME correcto del usuario.
    USER_HOME_DIR=$(sudo -u "$SUDO_USER" printenv HOME)
    # Ruta esperada del ejecutable de pyenv
    PYENV_EXECUTABLE="${USER_HOME_DIR}/.pyenv/bin/pyenv"

    # Verificar si el ejecutable de pyenv existe en el directorio esperado del usuario
    if [ ! -f "$PYENV_EXECUTABLE" ]; then
        echo "pyenv no encontrado en la ubicación esperada para el usuario '$SUDO_USER': $PYENV_EXECUTABLE."
        echo "Para que VocalClarity funcione, pyenv debe estar instalado y configurado en tu usuario."
        echo "Por favor, sigue estos pasos:"
        echo "  1. Ejecuta el siguiente comando SIN 'sudo' como tu usuario '$SUDO_USER':"
        echo "     curl https://pyenv.run | bash"
        echo "  2. Después de que el comando anterior finalice, REINICIA TU TERMINAL por completo."
        echo "     (Cierra y vuelve a abrir la ventana de la terminal)."
        echo "  3. Vuelve a ejecutar este script de instalación con 'sudo':"
        echo "     sudo ./install_launcher.sh"
        echo ""
        echo "El script se detendrá ahora. Por favor, realiza los pasos indicados."
        return 1 # Indica fallo para detener el proceso de instalación
    else
        echo "pyenv ya está instalado en '$PYENV_EXECUTABLE' para el usuario '$SUDO_USER'."
    fi
    return 0
}

# MODIFICACIÓN CLAVE: setup_spleeter_env ejecuta comandos pyenv como SUDO_USER
setup_spleeter_env() {
    echo "## Configurando entorno virtual de Spleeter ##"
    if [ -z "$SUDO_USER" ]; then
        echo "Error: SUDO_USER no está definido. Esta función debe ejecutarse en un contexto sudo."
        return 1
    fi

    # Ejecutar comandos pyenv como el usuario original (SUDO_USER)
    # '-lc' simula un shell de login interactivo para que pyenv se inicialice correctamente.
    sudo -u "$SUDO_USER" bash -lc "
        echo 'Ejecutando operaciones de pyenv como usuario $SUDO_USER...'
        if ! command -v pyenv &> /dev/null; then
            # Fallback a la ruta directa si command -v falla en este subshell
            if [ -f \"${USER_HOME_DIR}/.pyenv/bin/pyenv\" ]; then
                export PATH=\"${USER_HOME_DIR}/.pyenv/bin:\$PATH\"
                eval \"\$(\"${USER_HOME_DIR}/.pyenv/bin/pyenv\" init --path)\"
                eval \"\$(\"${USER_HOME_DIR}/.pyenv/bin/pyenv\" virtualenv-init -)\"
            else
                echo 'Error: pyenv no está disponible para el usuario $SUDO_USER. Asegúrate de que fue instalado y tu terminal ha sido reiniciada.'
                exit 1
            fi
        fi
        
        if ! pyenv versions --bare | grep -q \"^${PYTHON_VERSION}$\"; then
            echo \"Instalando Python ${PYTHON_VERSION} con pyenv. Esto puede tardar...\"
            pyenv install \"${PYTHON_VERSION}\" || { echo \"Error al instalar Python ${PYTHON_VERSION}. Abortando.\"; exit 1; }
        else
            echo \"Python ${PYTHON_VERSION} ya está instalado con pyenv.\"
        fi

        if ! pyenv virtualenvs --bare | grep -q \"^${SPLEETER_VENV_NAME}$\"; then
            echo \"Creando entorno virtual '${SPLEETER_VENV_NAME}'...\"
            pyenv virtualenv \"${PYTHON_VERSION}\" \"${SPLEETER_VENV_NAME}\" || { echo \"Error al crear el entorno virtual. Abortando.\"; exit 1; }
        else
            echo \"El entorno virtual '${SPLEETER_VENV_NAME}' ya existe.\"
        fi

        # Activar el entorno virtual para instalar dependencias
        set +e # Deshabilitar salida inmediata en error para que 'pyenv activate' no falle si venv no se activa
        pyenv activate \"${SPLEETER_VENV_NAME}\"
        if [ \$? -ne 0 ]; then
            echo \"Error al activar el entorno virtual '${SPLEETER_VENV_NAME}'. Asegúrate de que pyenv esté configurado correctamente.\"
            exit 1
        fi
        set -e # Re-habilitar salida inmediata

        echo \"Instalando librerías de Python desde '${PROJECT_DIR}/${REQUIREMENTS_FILE}' en '${SPLEETER_VENV_NAME}'...\"
        pip install -r \"${PROJECT_DIR}/${REQUIREMENTS_FILE}\" || { echo \"Error al instalar librerías con pip. Abortando.\"; exit 1; }
        echo \"Librerías de Python instaladas correctamente en el entorno virtual.\"

        # Desactivar el entorno virtual al finalizar (opcional, pero buena práctica)
        pyenv deactivate
    " || { echo "Error: Fallo en la configuración del entorno virtual de Spleeter para el usuario '$SUDO_USER'. Abortando."; return 1; }
    return 0
}

# --- FUNCIONES DE ACCIÓN ---

do_install() {
    echo -e "\n### INICIANDO INSTALACIÓN DE DEPENDENCIAS ###"
    # Verificar si el script se ejecuta como root (sudo) para apt/pacman
    if [ "$EUID" -ne 0 ]; then
        echo "Este paso de instalación requiere privilegios de superusuario."
        echo "Por favor, ejecuta este script con 'sudo bash install_launcher.sh' o 'sudo ./install_launcher.sh'."
        return 1
    fi

    # Verificar si el archivo de requisitos existe
    if [ ! -f "${PROJECT_DIR}/${REQUIREMENTS_FILE}" ]; then
        echo "Error: No se encontró el archivo de requisitos de Python ('${REQUIREMENTS_FILE}') en el directorio actual."
        echo "Asegúrate de que este script y '${REQUIREMENTS_FILE}' estén en la misma carpeta."
        return 1
    fi

    # Verificar si el script principal existe (para recordar al usuario dónde está)
    if [ ! -f "${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}" ]; then
        echo "Advertencia: El script principal de procesamiento de audio ('${AUDIO_PROCESSOR_SCRIPT}') no se encontró."
        echo "Asegúrate de que esté en el mismo directorio para usarlo después de la instalación."
    fi

    # Detección/Selección de Distribución
    DISTRO=""
    if grep -qi "kali" /etc/os-release || grep -qi "debian" /etc/os-release; then
        DISTRO="debian"
        echo "Detectada distribución basada en Debian (Kali/Nethunter)."
    elif grep -qi "arch" /etc/os-release; then
        DISTRO="arch"
        echo "Detectada distribución Arch Linux."
    else
        echo "No se pudo detectar la distribución automáticamente."
        read -p "¿Es Debian/Kali/Nethunter (d) o Arch Linux (a)? [d/a]: " choice
        case "$choice" in
            [Dd]* ) DISTRO="debian";;
            [Aa]* ) DISTRO="arch";;
            * ) echo "Opción inválida. Abortando."; return 1;;
        esac
    fi

    # Ejecutar instalación de dependencias del sistema
    if [ "$DISTRO" = "debian" ]; then
        install_debian_dependencies || return 1
    elif [ "$DISTRO" = "arch" ]; then
        install_arch_dependencies || return 1
    fi

    # Instalar y configurar pyenv (Pide reiniciar terminal si no está configurado)
    # MODIFICACIÓN: Esta función ahora solo verifica y pide al usuario que instale pyenv si es necesario.
    install_pyenv || return 1 # Si install_pyenv retorna 1 (fallo), detiene la instalación principal

    # Configurar entorno virtual de Spleeter
    setup_spleeter_env || return 1

    # Crear el archivo flag indicando que la instalación base se ha completado
    touch "${PROJECT_DIR}/${INSTALL_FLAG_FILE}"
    echo "Instalación base completada en $(date)." >> "${PROJECT_DIR}/${INSTALL_FLAG_FILE}"

    echo -e "\n### INSTALACIÓN COMPLETA Y MARCADA ###"
    echo "Puedes lanzar el script de procesamiento de audio ahora."
    echo "Si tuviste que reiniciar la terminal por pyenv, el launcher ahora te dará la opción 'Lanzar'."
    return 0
}

# MODIFICACIÓN CLAVE: do_launch también ejecuta el script de audio como SUDO_USER
do_launch() {
    echo -e "\n### LANZANDO SCRIPT DE PROCESAMIENTO DE AUDIO ###"
    if [ ! -f "${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}" ]; then
        echo "Error: El script de procesamiento de audio ('${AUDIO_PROCESSOR_SCRIPT}') no se encontró."
        echo "Asegúrate de que esté en el mismo directorio que este launcher."
        return 1
    fi

    if [ -z "$SUDO_USER" ]; then
        echo "Error: SUDO_USER no está definido. Ejecuta el launcher con 'sudo' para usar esta opción."
        return 1
    fi

    # Ejecutar el script de audio como el usuario original (SUDO_USER)
    # y activar el entorno pyenv para ese usuario
    sudo -u "$SUDO_USER" bash -lc "
        echo 'Lanzando script de audio como usuario $SUDO_USER...'
        if ! command -v pyenv &> /dev/null; then
            # Fallback a la ruta directa si command -v falla en este subshell
            if [ -f \"${USER_HOME_DIR}/.pyenv/bin/pyenv\" ]; then
                export PATH=\"${USER_HOME_DIR}/.pyenv/bin:\$PATH\"
                eval \"\$(\"${USER_HOME_DIR}/.pyenv/bin/pyenv\" init --path)\"
                eval \"\$(\"${USER_HOME_DIR}/.pyenv/bin/pyenv\" virtualenv-init -)\"
            else
                echo 'Error: pyenv no está disponible para el usuario $SUDO_USER. Asegúrate de que fue instalado y tu terminal ha sido reiniciada.'
                exit 1
            fi
        fi
        
        # Activar el entorno virtual de Spleeter
        pyenv activate \"${SPLEETER_VENV_NAME}\" || { echo \"Error al activar el entorno virtual '${SPLEETER_VENV_NAME}'.\"; exit 1; }

        echo \"Ejecutando script: ${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}\"
        python \"${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}\"
        echo -e \"\nScript de procesamiento de audio finalizado.\"

        pyenv deactivate # Desactivar el entorno virtual al finalizar
    " || { echo "Error: Fallo al lanzar el script de audio como usuario '$SUDO_USER'."; return 1; }
    return 0
}

do_reinstall() {
    echo -e "\n### INICIANDO REINSTALACIÓN DE DEPENDENCIAS ###"
    read -p "¿Estás seguro de que quieres reinstalar? Esto podría llevar tiempo. (s/N): " confirm_reinstall
    if [[ ! "$confirm_reinstall" =~ ^[Ss]$ ]]; then
        echo "Reinstalación cancelada."
        return 0
    fi

    # Eliminar el flag para forzar la instalación completa
    rm -f "${PROJECT_DIR}/${INSTALL_FLAG_FILE}"
    echo "Se ha eliminado el archivo flag de instalación. Se procederá con una nueva instalación."
    do_install # Llama a la función de instalación completa
    return $?
}

# --- MENÚ PRINCIPAL ---
main_menu() {
    echo "### Asistente de Auditoría de Audio - Menú Principal ###"

    # Verificar si el script se ejecuta como root (sudo)
    if [ "$EUID" -ne 0 ]; then
        echo "ADVERTENCIA: Se recomienda ejecutar este script con 'sudo' para permisos de instalación."
        echo "Actualmente, solo la opción 'Lanzar' funcionará sin 'sudo'."
    fi

    if [ -f "${PROJECT_DIR}/${INSTALL_FLAG_FILE}" ]; then
        echo "El sistema parece estar configurado."
        echo "1. Lanzar script de procesamiento de audio"
        echo "2. Reinstalar dependencias (para problemas o actualizaciones)"
        echo "3. Salir"
        read -p "Selecciona una opción [1-3]: " choice
        case "$choice" in
            1 ) do_launch;;
            2 ) do_reinstall;;
            3 ) echo "Saliendo."; exit 0;;
            * ) echo "Opción inválida. Por favor, selecciona un número entre 1 y 3."; main_menu;;
        esac
    else
        echo "El sistema aún no está configurado para la auditoría de audio."
        echo "1. Instalar dependencias y configurar entorno"
        echo "2. Salir"
        read -p "Selecciona una opción [1-2]: " choice
        case "$choice" in
            1 ) do_install;;
            2 ) echo "Saliendo."; exit 0;;
            * ) echo "Opción inválida. Por favor, selecciona un número entre 1 y 2."; main_menu;;
        esac
    fi
}

# --- EJECUTAR EL MENÚ ---
main_menu