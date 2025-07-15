import os

# Ruta de la carpeta con las imágenes (cámbiala según tu necesidad)
carpeta = './pictures/Pieza5'

# Extensiones de archivo que se consideran imágenes
extensiones = ['.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff', '.webp']

# Obtener lista de archivos de imagen
imagenes = [f for f in os.listdir(carpeta) if os.path.splitext(f)[1].lower() in extensiones]
imagenes.sort()  # Ordena alfabéticamente

# Renombrar las imágenes
for i, nombre_original in enumerate(imagenes, start=1):
    extension = os.path.splitext(nombre_original)[1].lower()
    nuevo_nombre = f'Imagen{i}{extension}'
    ruta_original = os.path.join(carpeta, nombre_original)
    ruta_nueva = os.path.join(carpeta, nuevo_nombre)
    os.rename(ruta_original, ruta_nueva)
    print(f'Renombrado: {nombre_original} → {nuevo_nombre}')
