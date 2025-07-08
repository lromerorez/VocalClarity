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
