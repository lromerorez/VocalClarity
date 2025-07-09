# VocalClarity - Procesamiento Batch y Barra de Progreso

Este proyecto amplía VocalClarity para procesar múltiples archivos o carpetas completas de audio con una barra de progreso visual en la terminal.

## Características nuevas

- Procesamiento batch automático de archivos dentro de carpetas.
- Barra de progreso visual en consola que indica % y archivos procesados.
- Opciones para mejoras forenses y diarización/grafica con un flag.
- Integrado al launcher para seleccionar procesamiento batch fácil.

## Uso

### Preparación previa

1. Instala pyenv y configura Python 3.8.10 según instrucciones iniciales.
2. Instala dependencias con el launcher `install_launcher.sh` ejecutado con sudo.
3. Asegúrate de tener el directorio de trabajo y el script `batch_audio_processor.py` en la carpeta del proyecto.
4. Clonaciòn de repositorio


```bash
git clone https://github.com/tu-usuario/VocalClarity.git
cd VocalClarity
chmod +x install_launcher.sh
```

### Procesamiento batch con barra de progreso

Ejecuta el launcher con:

```bash
sudo ./install_launcher.sh
```

En el menú elige:

```
1) Lanzar procesamiento batch de carpetas
```

Luego ingresa la ruta absoluta de la carpeta o archivo a procesar, y responde si deseas activar:

- Mejoras forenses (mejora vocal forense)
- Diarización y graficación (detectar hablantes y crear gráficos)

La barra de progreso mostrará el avance real en tiempo de cada archivo procesado.

### Salida

Los archivos procesados se guardan en la carpeta `batch_output` dentro del proyecto, con nombre indicativo (e.g., `audio1_voz_clarificada.wav`).

---

## Cómo funciona internamente

- El script Python `batch_audio_processor.py` procesa cada archivo uno a uno, imprime en stdout el progreso.
- El launcher en Bash lee esa salida, detecta líneas `PROGRESS X/Y` y actualiza la barra.
- Así se logra feedback visual sin perder información ni logs del procesamiento.

---

## Personalización y extensibilidad

- Puedes modificar filtros en `batch_audio_processor.py` para ajustar la mejora del audio.
- Puedes implementar la diarización y graficación modular en el mismo script.
- El launcher puede extenderse para más funcionalidades, siempre leyendo la salida Python para UI dinámica.

---

## Contacto

Para más detalles o soporte, abre un issue o contacta al autor.

---

¡Disfruta mejorando tu audio con VocalClarity batch!
