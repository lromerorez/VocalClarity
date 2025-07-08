🎧 VocalClarity: Herramienta de Auditoría de Audio en Linux
📝 Descripción General
VocalClarity es un sistema automatizado diseñado para procesar archivos de audio en entornos Linux. Su objetivo principal es limpiar grabaciones, reducir el ruido de fondo, separar voces del acompañamiento musical y normalizar niveles de volumen para mejorar la inteligibilidad y la calidad general del audio.

🎯 Ideal para podcasters, músicos, ingenieros de audio aficionados y cualquiera que necesite mejorar la calidad de grabaciones de voz.

✨ Características Principales
🔇 Reducción de Ruido: Elimina ruido de fondo con perfiles generados automáticamente usando SoX.

🎤 Separación de Voces: Aísla las pistas vocales usando Spleeter.

🎚️ Normalización de Volumen: Ajusta niveles de audio a un rango óptimo.

💻 Compatibilidad Multi-Distribución: Soporte para Kali Linux / Nethunter (Debian) y Arch Linux.

🧭 Interfaz Guiada por Terminal: Un launcher interactivo que simplifica la instalación y uso.

💻 Requisitos del Sistema
🖥️ Hardware
CPU: Recomendado con múltiples núcleos.

RAM: Mínimo 8 GB (16 GB recomendados).

Almacenamiento: Espacio suficiente para audios temporales y procesados.

🧰 Software
SoX: Normalización y reducción de ruido.

FFmpeg: Conversión de formatos.

pyenv: Gestión de versiones de Python.

Python 3.8.10: Requerido por Spleeter.

Spleeter: Separación de fuentes de audio.

📁 Estructura del Repositorio
bash
Copiar
Editar
├── install_launcher.sh       # Script principal de instalación y lanzamiento.
├── audio_processor.py        # Script que realiza el procesamiento de audio.
├── requirements.txt          # Dependencias de Python.
├── README.md                 # Este archivo.
└── audios_a_procesar/        # Carpeta para archivos de entrada.
📂 El directorio audios_procesados/ será creado automáticamente para guardar resultados.

🧪 Guía de Instalación y Uso
✅ 1. Instalar y configurar pyenv (¡Paso crucial!)
⚠️ NO uses sudo para esta instalación. Hazlo como tu usuario normal.

bash
Copiar
Editar
curl https://pyenv.run | bash
Una vez instalado, reinicia tu terminal o ejecuta:

bash
Copiar
Editar
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc
Verifica que pyenv esté disponible:

bash
Copiar
Editar
command -v pyenv
Si muestra una ruta válida, estás listo ✅

⚙️ 2. Ejecutar el script install_launcher.sh
bash
Copiar
Editar
chmod +x install_launcher.sh
sudo ./install_launcher.sh
Selecciona en el menú:

🧰 "Instalar dependencias y configurar entorno"

El script:

Instala Python 3.8.10 con pyenv.

Crea el entorno virtual spleeter_env.

Instala las dependencias de requirements.txt.

🚀 3. Lanzar VocalClarity
bash
Copiar
Editar
sudo ./install_launcher.sh
Selecciona:

🎙️ "Lanzar script de procesamiento de audio"

👁️‍🗨️ 4. Auditoría Visual (Opcional, Recomendado)
Usa un editor gráfico como Audacity para revisar resultados:

🧩 Instalar Audacity
bash
Copiar
Editar
# Debian / Kali / Nethunter
sudo apt install audacity

# Arch Linux
sudo pacman -S audacity
Abre los archivos con sufijo _vocals_final_norm.wav desde:

bash
Copiar
Editar
./audios_procesados/final_output/
🛠️ Solución de Problemas Comunes
Problema	Solución
❌ externally-managed-environment o errores con pip	Reinicia tu terminal tras instalar pyenv y vuelve a ejecutar el script.
❌ sox o ffmpeg no encontrados	Verifica instalación con sox --version o ffmpeg -version.
❌ pyenv no funciona tras instalar	Asegúrate de agregar pyenv en tu ~/.bashrc o ~/.zshrc. Reinicia la terminal.
🐢 Procesamiento muy lento	Spleeter es intensivo. Sé paciente si usas un dispositivo limitado como Nethunter.
❓ No aparece vocals.wav	Revisa errores en la terminal. Podrías intentar reinstalar dependencias desde el launcher.

🤝 Contribuciones
¡Las contribuciones son bienvenidas! Para colaborar:

Haz un fork del repositorio.

Crea una rama:

bash
Copiar
Editar
git checkout -b feature/nueva-funcionalidad
Aplica tus cambios y haz commit.

Abre un pull request explicando tus modificaciones.

📄 Licencia
Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
