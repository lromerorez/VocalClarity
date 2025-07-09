import os
import sys
import argparse
from spleeter.separator import Separator
import subprocess

def process_file(file_path, output_dir, forensic=False, diarize=False):
    base_name = os.path.splitext(os.path.basename(file_path))[0]
    separated_dir = os.path.join(output_dir, base_name)
    os.makedirs(separated_dir, exist_ok=True)

    print(f"Separando pistas: {file_path}")
    separator = Separator('spleeter:2stems')
    separator.separate_to_file(file_path, output_dir)

    vocals_path = os.path.join(separated_dir, 'vocals.wav')
    accompaniment_path = os.path.join(separated_dir, 'accompaniment.wav')
    vocals_out = os.path.join(output_dir, base_name + '_voz_clarificada.wav')
    music_out = os.path.join(output_dir, base_name + '_fondo_mejorado.wav')

    def enhance_audio(input_file, output_file, forensic):
        filters = ["loudnorm"]
        if forensic:
            filters.extend([
                "highpass=f=150",
                "lowpass=f=7000",
                "equalizer=f=300:t=q:w=1:g=5",
                "afftdn",
                "volume=5dB"
            ])
        filter_chain = ",".join(filters)
        command = [
            'ffmpeg', '-i', input_file,
            '-af', filter_chain,
            '-y',
            output_file
        ]
        subprocess.run(command, check=True)

    if os.path.exists(vocals_path):
        enhance_audio(vocals_path, vocals_out, forensic)
    else:
        print(f"Advertencia: vocals.wav no encontrado para {file_path}")

    if os.path.exists(accompaniment_path):
        enhance_audio(accompaniment_path, music_out, False)
    else:
        print(f"Advertencia: accompaniment.wav no encontrado para {file_path}")

    # TODO: aquí agregar la diarización y graficación modular si se activa

def main():
    parser = argparse.ArgumentParser(description="Procesador batch VocalClarity")
    parser.add_argument('input_path', help='Archivo o carpeta a procesar')
    parser.add_argument('--output', default='output', help='Directorio de salida')
    parser.add_argument('--forensic', action='store_true', help='Mejoras forenses')
    parser.add_argument('--diarize', action='store_true', help='Diarización y graficación')
    args = parser.parse_args()

    input_path = args.input_path
    output_dir = args.output
    forensic = args.forensic
    diarize = args.diarize

    os.makedirs(output_dir, exist_ok=True)

    files_to_process = []
    if os.path.isfile(input_path):
        files_to_process = [input_path]
    elif os.path.isdir(input_path):
        for ext in ['wav','mp3','flac','m4a','aac','ogg']:
            files_to_process.extend(
                [os.path.join(input_path, f) for f in os.listdir(input_path) if f.lower().endswith(ext)]
            )
    else:
        print(f"Error: '{input_path}' no es archivo ni carpeta válida.")
        sys.exit(1)

    total = len(files_to_process)
    if total == 0:
        print("No se encontraron archivos de audio para procesar.")
        sys.exit(0)

    for idx, filepath in enumerate(files_to_process, start=1):
        print(f"PROGRESS {idx}/{total} Procesando archivo: {os.path.basename(filepath)}", flush=True)
        process_file(filepath, output_dir, forensic=forensic, diarize=diarize)

    print("PROGRESS DONE", flush=True)

if __name__ == '__main__':
    main()
