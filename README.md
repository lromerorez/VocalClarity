# VocalClarity: Herramienta de Auditoría de Audio en Linux

## Descripción General

VocalClarity es un sistema automatizado diseñado para procesar archivos de audio en entornos Linux. Su objetivo principal es limpiar grabaciones al reducir el ruido de fondo, separar las pistas vocales del acompañamiento musical y normalizar los niveles de volumen para mejorar la inteligibilidad y la calidad general del audio.

Este proyecto es ideal para podcasters, músicos, ingenieros de audio aficionados y cualquier persona que necesite mejorar la calidad de las grabaciones de voz de manera eficiente.

## Características Principales

* **Reducción de Ruido:** Elimina el ruido de fondo utilizando perfiles de ruido generados automáticamente por SoX.
* **Separación de Voces:** Aísla las pistas vocales de las instrumentales usando Spleeter.
* **Normalización de Volumen:** Ajusta los niveles de audio a un rango óptimo.
* **Compatibilidad Multi-Distribución:** Soporte para Kali Linux / Nethunter (Debian) y Arch Linux.
* **Interfaz Guiada por Terminal:** Un launcher interactivo que simplifica la instalación y el uso.

## Requisitos del Sistema

### Requisitos de Hardware
* **Procesador (CPU):** Se recomiendan múltiples núcleos para un procesamiento eficiente.
* **Memoria RAM:** Mínimo 8 GB (16 GB o más recomendados para archivos grandes y uso intensivo).
* **Almacenamiento:** Espacio suficiente para archivos de audio de entrada, temporales y de salida. Spleeter y los archivos WAV pueden ocupar bastante espacio.

### Requisitos de Software y Dependencias
* **Linux:** Compatible con distribuciones basadas en Debian (como Kali Linux / Nethunter) y Arch Linux.
* **Bash:** El script principal (`install_launcher.sh`) requiere Bash.
* **Git:** Necesario para clonar el repositorio.
* **curl:** Necesario para descargar `pyenv`.
* **pyenv:** Una herramienta de gestión de versiones de Python. Se te guiará para instalarlo manualmente si aún no lo tienes.
* **Sox y FFmpeg:** Herramientas de procesamiento de audio. Se instalarán automáticamente por el script `install_launcher.sh`.
* **Python 3.8.10:** La versión específica de Python que se instalará y usará dentro de un entorno virtual gestionado por `pyenv`.
* **`requirements.txt`:** El archivo que lista las bibliotecas Python necesarias (incluyendo Spleeter) para el proyecto. Debe estar en el mismo directorio que el launcher.
* **`audio_processor.py`:** El script principal de procesamiento de audio. Debe estar en el mismo directorio que el launcher.

## Guía de Instalación y Uso

Sigue estos pasos para instalar y configurar VocalClarity en tu sistema Linux:

#### 1. Clonar el Repositorio y Preparar el Script

Abre tu terminal y ejecuta los siguientes comandos para descargar el proyecto y darle permisos de ejecución al script de instalación:

```bash
git clone https://github.com/lromerorez/VocalClarity.git
cd VocalClarity
chmod +x install_launcher.sh
```

#### 2. Instalar y configurar pyenv (Paso crucial, ¡hazlo primero!)

pyenv es una herramienta esencial para gestionar las versiones de Python de forma aislada y sin conflictos con el sistema. Debes instalarlo como tu usuario normal (NO con sudo) antes de ejecutar el script principal de instalación.

Abre tu terminal y ejecuta:

```bash
curl https://pyenv.run | bash
```

Después de que la instalación de pyenv finalice, es IMPRESCINDIBLE que reinicies tu terminal o apliques los cambios a tu configuración de shell. Para reiniciar, simplemente cierra la ventana de la terminal y ábrela de nuevo. Alternativamente, puedes ejecutar:

```bash
# Si usas Bash:
source ~/.bashrc

# Si usas Zsh:
source ~/.zshrc
```

Verifica que pyenv esté disponible ejecutando:

```bash
command -v pyenv
```

Si muestra una ruta, ¡estás listo para el siguiente paso!

#### 3. Ejecutar el script install_launcher.sh

Este script se encargará de instalar las dependencias del sistema y, si pyenv está correctamente configurado para tu usuario, procederá a configurar el entorno virtual de Spleeter.

Asegúrate de estar en el directorio VocalClarity (donde se encuentra install_launcher.sh). Luego, ejecuta el script con sudo:

```bash
sudo ./install_launcher.sh
```

El script te presentará un menú. Selecciona la opción para "Instalar dependencias y configurar entorno".

> **Importante:** Si el script detecta que pyenv aún no está disponible para tu usuario, te dará instrucciones específicas para instalarlo manualmente (como se describe en el Paso 2) y luego se detendrá. En ese caso, deberás seguir esas instrucciones y volver a ejecutar `sudo ./install_launcher.sh` una vez que pyenv esté configurado.

Si pyenv ya está configurado para tu usuario, el script procederá automáticamente con la instalación de Python 3.8.10, la creación del entorno virtual spleeter_env y la instalación de las librerías desde requirements.txt.

#### 4. Lanzar VocalClarity

Una vez que la instalación haya finalizado (el script te lo indicará), puedes lanzar VocalClarity:

Asegúrate de estar en el directorio VocalClarity. Luego, vuelve a ejecutar el script install_launcher.sh (aún con sudo, ya que el launcher asume este contexto para su menú principal):

```bash
sudo ./install_launcher.sh
```

Selecciona la opción "Lanzar script de procesamiento de audio". El script ejecutará audio_processor.py dentro del entorno de Spleeter configurado para tu usuario.

## Resolución de Problemas Comunes

### Permiso denegado al ejecutar source /root/.bashrc o similar:
Este es un error común si pyenv fue configurado incorrectamente para el usuario root en lugar de tu usuario. Asegúrate de haber seguido el Paso 2 de la instalación para instalar pyenv como tu usuario y que la última versión del install_launcher.sh esté siendo utilizada.

### pyenv no encontrado o comandos pyenv fallan:
Verifica que pyenv fue instalado correctamente como tu usuario y que tu terminal fue reiniciada o se hizo source del archivo de configuración de tu shell (.bashrc o .zshrc). Si el install_launcher.sh se detuvo pidiéndote que instales pyenv manualmente, asegúrate de haber completado ese paso y luego reinicia la ejecución del launcher.

### El procesamiento de audio es muy lento:
La separación de voces con Spleeter, especialmente en modelos más complejos, es una tarea intensiva en recursos de CPU (y potencialmente GPU si estuviera configurado para ello). Si estás ejecutando VocalClarity en un dispositivo móvil con Nethunter o en una máquina con recursos limitados, el procesamiento tomará considerablemente más tiempo que en una computadora de escritorio potente. Ten paciencia, especialmente con archivos de audio largos.

### No se encontraron las voces separadas (vocals.wav):
Esto puede indicar un problema durante la ejecución de Spleeter. Revisa la salida de la terminal para cualquier mensaje de error de Spleeter. Podría deberse a un archivo de entrada corrupto o a un problema de instalación de Spleeter o sus modelos. Puedes intentar una "Reinstalación de dependencias" a través del launcher.

## Contribuciones

¡Las contribuciones a VocalClarity son bienvenidas! Si deseas mejorar este proyecto, por favor:

1. Haz un "fork" de este repositorio.
2. Crea una nueva rama para tus cambios (`git checkout -b feature/tu-nueva-caracteristica`).
3. Implementa tus mejoras y asegúrate de que el código sea limpio y funcional.
4. Si es posible, añade pruebas para tus cambios.
5. Envía un "pull request" detallado explicando tus modificaciones.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE (si lo incluyes en tu repositorio) para más detalles.
