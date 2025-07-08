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

install_pyenv() {
    echo "## Instalando y configurando pyenv ##"
    if ! command -v pyenv &> /dev/null; then
        echo "pyenv no encontrado. Procediendo con la instalación."
        curl https://pyenv.run | bash || { echo "Error al instalar pyenv. Abortando."; return 1; }

        LOCAL_SHELL=$(basename "$SHELL")
        RC_FILE=""
        if [ "$LOCAL_SHELL" = "bash" ]; then
            RC_FILE="$HOME/.bashrc"
        elif [ "$LOCAL_SHELL" = "zsh" ]; then
            RC_FILE="$HOME/.zshrc"
        else
            echo "Advertencia: Tu shell ($LOCAL_SHELL) no es Bash ni Zsh. Deberás añadir las siguientes líneas a tu archivo de configuración de shell manualmente."
            RC_FILE=""
        fi

        if [ -n "$RC_FILE" ]; then
            echo "Añadiendo configuración de pyenv a $RC_FILE..."
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$RC_FILE"
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$RC_FILE"
            echo 'eval "$(pyenv init -)"' >> "$RC_FILE"
            echo "Configuración de pyenv añadida. Por favor, REINICIA TU TERMINAL o ejecuta 'source $RC_FILE' AHORA."
            echo "Una vez que la terminal se haya reiniciado, vuelve a ejecutar este script."
            exit 0
        fi
    else
        echo "pyenv ya está instalado."
    fi
    return 0
}

setup_spleeter_env() {
    echo "## Configurando entorno virtual de Spleeter ##"
    if ! command -v pyenv &> /dev/null; then
        echo "Error: pyenv no está disponible. Asegúrate de que fue instalado y tu terminal ha sido reiniciada."
        return 1
    fi

    if ! pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
        echo "Instalando Python ${PYTHON_VERSION} con pyenv. Esto puede tardar..."
        pyenv install "${PYTHON_VERSION}" || { echo "Error al instalar Python ${PYTHON_VERSION}. Abortando."; return 1; }
    else
        echo "Python ${PYTHON_VERSION} ya está instalado con pyenv."
    fi

    if ! pyenv virtualenvs --bare | grep -q "^${SPLEETER_VENV_NAME}$"; then
        echo "Creando entorno virtual '${SPLEETER_VENV_NAME}'..."
        pyenv virtualenv "${PYTHON_VERSION}" "${SPLEETER_VENV_NAME}" || { echo "Error al crear el entorno virtual. Abortando."; return 1; }
    else
        echo "El entorno virtual '${SPLEETER_VENV_NAME}' ya existe."
    fi

    PYTHON_VENV_BIN="${PYENV_ROOT}/versions/${PYTHON_VERSION}/envs/${SPLEETER_VENV_NAME}/bin/python"
    PIP_VENV_BIN="${PYENV_ROOT}/versions/${PYTHON_VERSION}/envs/${SPLEETER_VENV_NAME}/bin/pip"

    if [ ! -f "$PIP_VENV_BIN" ]; then
        echo "Error: No se encontró el binario pip en el entorno virtual. Abortando."
        return 1
    fi

    echo "Instalando librerías de Python desde '${REQUIREMENTS_FILE}' en '${SPLEETER_VENV_NAME}'..."
    "$PIP_VENV_BIN" install -r "${PROJECT_DIR}/${REQUIREMENTS_FILE}" || { echo "Error al instalar librerías con pip. Abortando."; return 1; }
    echo "Librerías de Python instaladas correctamente en el entorno virtual."
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
    install_pyenv || return 1

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

do_launch() {
    echo -e "\n### LANZANDO SCRIPT DE PROCESAMIENTO DE AUDIO ###"
    if [ ! -f "${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}" ]; then
        echo "Error: El script de procesamiento de audio ('${AUDIO_PROCESSOR_SCRIPT}') no se encontró."
        echo "Asegúrate de que esté en el mismo directorio que este launcher."
        return 1
    fi

    # Obtener el binario de Python del entorno virtual
    PYTHON_VENV_BIN_PATH="${PYENV_ROOT}/versions/${PYTHON_VERSION}/envs/${SPLEETER_VENV_NAME}/bin/python"

    if [ ! -f "$PYTHON_VENV_BIN_PATH" ]; then
        echo "Error: El entorno virtual '${SPLEETER_VENV_NAME}' o Python ${PYTHON_VERSION} no parece estar configurado correctamente."
        echo "Considera la opción de 'Reinstalar Dependencias' si esto persiste."
        return 1
    fi

    echo "Ejecutando script: ${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}"
    # Ejecutar el script usando el python del entorno virtual
    "$PYTHON_VENV_BIN_PATH" "${PROJECT_DIR}/${AUDIO_PROCESSOR_SCRIPT}"
    echo -e "\nScript de procesamiento de audio finalizado."
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
main_menu "$@"