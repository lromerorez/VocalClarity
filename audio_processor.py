import os
import subprocess
import shutil
from pathlib import Path

# --- CONFIGURACIÓN ---
# Nombre del entorno virtual de Spleeter (debe coincidir con el que creaste con pyenv)
SPLEETER_VENV_NAME = "spleeter_env"
# Versión de Python asociada a tu entorno virtual de Spleeter
PYTHON_VERSION = "3.8.10" # Asegúrate de que esta sea la versión que usaste con pyenv
# Directorio donde se encuentran tus archivos de audio de entrada
INPUT_DIR = Path("./audios_a_procesar")
# Directorio donde se guardarán los resultados (se creará si no existe)
OUTPUT_DIR = Path("./audios_procesados")
# Duración de la muestra de ruido en segundos (ej: del segundo 0 al 2)
NOISE_SAMPLE_START = "0"
NOISE_SAMPLE_DURATION = "2"
# Factor de reducción de ruido (experimenta con valores como "0.1" a "0.5")
NOISE_REDUCTION_FACTOR = "0.21"

# --- RUTAS A HERRAMIENTAS ---
# pyenv se instala en el HOME del usuario
PYENV_ROOT = os.environ.get('PYENV_ROOT', Path.home() / ".pyenv")
SPLEETER_CMD = PYENV_ROOT / "versions" / PYTHON_VERSION / "envs" / SPLEETER_VENV_NAME / "bin" / "spleeter"

def run_command(command, description=""):
    """Ejecuta un comando de shell y maneja errores."""
    print(f"\n[EJECUTANDO] {description}: {' '.join(command)}")
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        print(f"[SALIDA] {result.stdout}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Falló {description}.")
        print(f"Comando: {' '.join(command)}")
        print(f"Error de salida: {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"[ERROR] El comando '{command[0]}' no fue encontrado. Asegúrate de que esté en tu PATH.")
        return False

def check_dependencies():
    """Verifica si las herramientas necesarias están instaladas."""
    print("Verificando dependencias...")
    if not run_command(["sox", "--version"], "Verificar SoX"): return False
    if not run_command(["ffmpeg", "-version"], "Verificar FFmpeg"): return False
    if not run_command(["pyenv", "--version"], "Verificar pyenv"): return False
    if not SPLEETER_CMD.exists():
        print(f"El binario de Spleeter no se encontró en '{SPLEETER_CMD}'.")
        print(f"Asegúrate de que el entorno virtual '{SPLEETER_VENV_NAME}' exista y Spleeter esté instalado dentro de él.")
        return False
    print("Dependencias verificadas exitosamente.")
    return True

def process_audio_file(audio_path):
    """Procesa un solo archivo de audio."""
    filename = audio_path.name
    filename_no_ext = audio_path.stem
    print(f"\n--- Procesando: {filename} ---")

    # Rutas temporales y finales
    temp_dir = OUTPUT_DIR / "temp" / filename_no_ext
    temp_dir.mkdir(parents=True, exist_ok=True) # Asegura que el directorio temporal exista

    temp_wav = temp_dir / f"{filename_no_ext}.wav"
    temp_norm = temp_dir / f"{filename_no_ext}_norm.wav"
    temp_noise_sample = temp_dir / f"noise_sample_{filename_no_ext}.wav"
    temp_noise_profile = temp_dir / f"noise_{filename_no_ext}.prof"
    temp_clean = temp_dir / f"{filename_no_ext}_sin_ruido.wav"
    
    final_output_dir = OUTPUT_DIR / "final_output"
    final_output_dir.mkdir(parents=True, exist_ok=True)
    final_vocals = final_output_dir / f"{filename_no_ext}_vocals_final_norm.wav"

    spleeter_output_subfolder = temp_dir / f"spleeter_output_{filename_no_ext}"

    # 1. Convertir a WAV y Normalizar
    if not run_command(["ffmpeg", "-i", str(audio_path), str(temp_wav)], "Convertir a WAV"):
        return False
    if not run_command(["sox", str(temp_wav), str(temp_norm), "norm"], "Normalizar inicial"):
        return False

    # 2. Reducción de Ruido
    print("2. Reduciendo ruido...")
    if not run_command(["sox", str(temp_norm), str(temp_noise_sample), "trim", NOISE_SAMPLE_START, NOISE_SAMPLE_DURATION], "Extraer muestra de ruido"):
        print(f"Advertencia: No se pudo extraer la muestra de ruido para '{filename}'. Saltando reducción de ruido para este archivo.")
        shutil.copy(temp_norm, temp_clean) # Copia el archivo normalizado como "limpio"
    else:
        if not run_command(["sox", str(temp_noise_sample), "-n", "noiseprof", str(temp_noise_profile), "0.2"], "Crear perfil de ruido"):
            return False
        if not run_command(["sox", str(temp_norm), str(temp_clean), "noisered", str(temp_noise_profile), NOISE_REDUCTION_FACTOR], "Aplicar reducción de ruido"):
            return False

    # 3. Separación de Voces con Spleeter
    print("3. Separando voces con Spleeter...")
    # Spleeter creará una subcarpeta dentro del -o destino
    if not run_command([str(SPLEETER_CMD), "separate", "-o", str(spleeter_output_subfolder), str(temp_clean)], "Ejecutar Spleeter"):
        return False
    
    vocals_raw_path = spleeter_output_subfolder / filename_no_ext / "vocals.wav"
    
    # 4. Normalizar Voces Finales
    print("4. Normalizando voces finales...")
    if vocals_raw_path.exists():
        if not run_command(["sox", str(vocals_raw_path), str(final_vocals), "norm"], "Normalizar voces finales"):
            return False
        print(f"Procesado completado para {filename}. Voces finales en: {final_vocals}")
    else:
        print(f"Error: No se encontró el archivo de voces separadas para '{filename}' en '{vocals_raw_path}'. Spleeter pudo haber fallado.")
        return False

    return True

def main():
    if not check_dependencies():
        print("\n[ERROR FATAL] Faltan dependencias o configuración incorrecta. Abortando.")
        return

    # Crear directorios de salida
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / "temp").mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / "final_output").mkdir(parents=True, exist_ok=True)

    print("\nIniciando proceso de automatización...")
    print(f"Los archivos de entrada se esperan en: {INPUT_DIR}")
    print(f"Los archivos procesados se guardarán en: {OUTPUT_DIR}/final_output/")

    processed_count = 0
    failed_count = 0

    if not INPUT_DIR.exists():
        print(f"[ERROR] El directorio de entrada '{INPUT_DIR}' no existe. Por favor, créalo y coloca tus audios allí.")
        return

    for audio_file in INPUT_DIR.iterdir():
        # Procesar solo archivos de audio (basado en extensiones comunes)
        if audio_file.is_file() and audio_file.suffix.lower() in ['.mp3', '.wav', '.flac', '.ogg']:
            if process_audio_file(audio_file):
                processed_count += 1
            else:
                failed_count += 1
        else:
            print(f"Saltando '{audio_file.name}': No es un archivo de audio compatible o es un directorio.")

    print("\n--- RESUMEN DEL PROCESO ---")
    print(f"Archivos procesados exitosamente: {processed_count}")
    print(f"Archivos que fallaron: {failed_count}")

    # Limpieza de archivos temporales
    print("\nLimpiando archivos temporales...")
    shutil.rmtree(OUTPUT_DIR / "temp", ignore_errors=True)
    print("¡Proceso de automatización finalizado!")

if __name__ == "__main__":
    main()