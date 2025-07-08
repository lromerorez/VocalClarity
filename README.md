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

### Requisitos de Software

VocalClarity requiere las siguientes herramientas de sistema operativo:

* **SoX (Sound eXchange):** Utilizado para la normalización y reducción de ruido.
* **FFmpeg:** Para la conversión de formatos de audio.
* **pyenv:** Un gestor de versiones de Python esencial para manejar el entorno de Python de forma aislada y evitar conflictos de dependencias del sistema.
* **Python 3.8.10:** La versión específica de Python en la que Spleeter funciona de manera más estable.
* **Spleeter:** La librería principal de Python para la separación de fuentes de audio.


## Estructura del Repositorio

Para entender la organización de este proyecto, aquí tienes un esquema de los archivos y directorios principales:

```
├── install_launcher.sh       # Script principal de instalación y lanzamiento.
├── audio_processor.py        # Script de Python que realiza el procesamiento de audio.
├── requirements.txt          # Dependencias de Python para audio_processor.py.
├── README.md                 # Este archivo.
└── audios_a_procesar/        # Directorio donde debes colocar tus archivos de audio de entrada.




```
*(El directorio `audios_procesados/` será creado automáticamente por el script para almacenar los resultados.)*

## Guía de Instalación

Sigue estos pasos para configurar VocalClarity en tu sistema.

1.  **Clonar el Repositorio (o descargar los archivos):**
    Si estás utilizando Git, clona el repositorio a tu máquina:
    ```bash
    git clone https://github.com/lromerorez/VocalClarity
    cd VocalClarity # Navega al directorio del proyecto
    ```
    Si descargaste los archivos manualmente (por ejemplo, como un archivo ZIP), asegúrate de que `install_launcher.sh`, `audio_processor.py`, `requirements.txt` y este `README.md` estén en el mismo directorio. Crea también una carpeta vacía llamada `audios_a_procesar/`.

2.  **Preparar el Launcher:**
    Asigna permisos de ejecución al script instalador:
    ```bash
    chmod +x install_launcher.sh
    ```

3.  **Ejecutar el Instalador/Launcher:**
    Ejecuta el script principal con privilegios de superusuario, ya que instalará paquetes del sistema:
    ```bash
    sudo ./install_launcher.sh
    ```
    * El launcher intentará detectar tu distribución Linux (Arch o Debian/Kali/Nethunter) o te preguntará si no puede identificarla.
    * **Atención - Paso crucial para `pyenv`:** Si es la primera vez que instalas `pyenv` o si tu terminal no está configurada para él, el launcher te indicará un mensaje similar a:
        ```
        Configuración de pyenv añadida. Por favor, REINICIA TU TERMINAL o ejecuta 'source /home/tu_usuario/.bashrc' AHORA.
        Una vez que la terminal se haya reiniciado, vuelve a ejecutar este script.
        ```
        Este paso es **manual y obligatorio**. Debes cerrar y volver a abrir tu terminal (o ejecutar el comando `source` indicado) para que las configuraciones de `pyenv` se apliquen a tu entorno de shell.
    * **Después de reiniciar tu terminal**, ejecuta `sudo ./install_launcher.sh` **de nuevo**. El launcher detectará que `pyenv` ya está configurado y procederá automáticamente con la instalación de Python `3.8.10` y la creación del entorno virtual de Spleeter con sus dependencias.

    Una vez que la instalación haya finalizado con éxito (y el launcher ya no te pida reiniciar la terminal y muestre el menú principal de VocalClarity), estarás listo para usar el sistema.

## Uso de VocalClarity

Después de que la instalación se haya completado, VocalClarity estará listo para procesar tus archivos de audio.

1.  **Prepara tus Archivos de Audio:**
    Coloca todos los archivos de audio que deseas procesar (en formatos comunes como `.mp3`, `.wav`, `.flac`, `.ogg`, etc.) dentro de la carpeta `./audios_a_procesar/` en el directorio raíz de VocalClarity.

2.  **Configura el Procesador de Audio:**
    Abre el archivo `audio_processor.py` con un editor de texto y revisa la sección `--- CONFIGURACIÓN ---` al principio del script. Es crucial que ajustes los siguientes parámetros según las características de tus grabaciones:
    * `NOISE_SAMPLE_START`: El segundo de inicio de una sección de audio que contenga **solo ruido de fondo puro** (sin voz ni música). Por ejemplo, si los primeros 2 segundos de tu grabación son solo ruido, usa `"0"`.
    * `NOISE_SAMPLE_DURATION`: La duración en segundos de la muestra de ruido puro. Por ejemplo, si usas los primeros 2 segundos, usa `"2"`.
    * `NOISE_REDUCTION_FACTOR`: El factor de reducción de ruido que aplicará SoX. Este valor va de `0.0` a `1.0`. Valores más altos reducen más ruido pero pueden afectar la calidad del audio deseado. Un valor entre `"0.1"` y `"0.5"` suele ser un buen punto de partida para experimentar.
    * `INPUT_DIR` y `OUTPUT_DIR`: Por defecto, están configurados para `./audios_a_procesar` y `./audios_procesados`. Ajústalos si has organizado tus carpetas de manera diferente.

3.  **Lanza el Procesamiento de Audio:**
    Ejecuta el launcher nuevamente:
    ```bash
    sudo ./install_launcher.sh
    ```
    Ahora, el menú principal te mostrará la opción **"1. Lanzar script de procesamiento de audio"**. Selecciona esta opción.

    El script `audio_processor.py` comenzará a procesar secuencialmente cada archivo en `./audios_a_procesar/`. Mostrará el progreso en la terminal y guardará los resultados (incluyendo las pistas vocales separadas y normalizadas) en el directorio `./audios_procesados/final_output/`. Los archivos temporales se eliminarán automáticamente al finalizar.

4.  **Auditoría Visual (Opcional, pero Recomendada):**
    Para una revisión detallada de las pistas procesadas y para realizar ajustes finos si es necesario, te recomendamos usar un editor de audio con interfaz gráfica:
    * **Instala Audacity (si no lo tienes):**
        * Para Debian/Kali/Nethunter: `sudo apt install audacity`
        * Para Arch Linux: `sudo pacman -S audacity`
    * Abre Audacity (o tu editor de audio preferido, como Ocenaudio, Ardour, etc.) e importa los archivos de audio con el sufijo `_vocals_final_norm.wav` que encontrarás en la carpeta `./audios_procesados/final_output/`. Podrás visualizar las ondas de audio, escuchar las voces aisladas y hacer cualquier edición manual.

## Solución de Problemas Comunes

* **`externally-managed-environment` o errores relacionados con la instalación de Python/Pip:**
    Este problema suele resolverse asegurándote de seguir las instrucciones del launcher para **reiniciar tu terminal** después de la instalación inicial de `pyenv`. Debes ejecutar `sudo ./install_launcher.sh` **de nuevo** después de reiniciar para que el proceso de instalación continúe correctamente.
* **Comandos como `sox` o `ffmpeg` no encontrados:**
    Verifica que estas herramientas del sistema se instalaron correctamente para tu distribución. Puedes confirmarlo manualmente abriendo una nueva terminal y ejecutando `sox --version` o `ffmpeg -version`. Si no se encuentran, la fase de instalación del launcher podría haber fallado (revisa la salida para errores de `apt` o `pacman`).
* **`pyenv` no funciona o no está en el PATH después de la instalación:**
    Asegúrate de que las líneas de configuración de `pyenv` (`export PYENV_ROOT="$HOME/.pyenv"` y `eval "$(pyenv init -)"`) estén correctamente añadidas a tu archivo de configuración de shell (`~/.bashrc` o `~/.zshrc`) y que hayas **reiniciado tu terminal** por completo después de la instalación de `pyenv`.
* **El procesamiento de audio es muy lento:**
    La separación de voces con Spleeter, especialmente en modelos más complejos, es una tarea intensiva en recursos de CPU (y potencialmente GPU si estuviera configurado para ello). Si estás ejecutando VocalClarity en un dispositivo móvil con Nethunter o en una máquina con recursos limitados, el procesamiento tomará considerablemente más tiempo que en una computadora de escritorio potente. Ten paciencia, especialmente con archivos de audio largos.
* **No se encontraron las voces separadas (`vocals.wav`):**
    Esto puede indicar un problema durante la ejecución de Spleeter. Revisa la salida de la terminal para cualquier mensaje de error de Spleeter. Podría deberse a un archivo de entrada corrupto o a un problema de instalación de Spleeter o sus modelos. Puedes intentar una "Reinstalación de dependencias" a través del launcher.

## Contribuciones

¡Las contribuciones a VocalClarity son bienvenidas! Si deseas mejorar este proyecto, por favor:

1.  Haz un "fork" de este repositorio.
2.  Crea una nueva rama para tus cambios (`git checkout -b feature/tu-nueva-caracteristica`).
3.  Implementa tus mejoras y asegúrate de que el código sea limpio y funcional.
4.  Si es posible, añade pruebas para tus cambios.
5.  Envía un "pull request" detallado explicando tus modificaciones.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` (si lo incluyes en tu repositorio) para más detalles.
