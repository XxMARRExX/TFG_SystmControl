# 🧩 Análisis de imagen para control de calidad industrial en la fabricación de planchas de acero

Este repositorio contiene el desarrollo del Trabajo de Fin de Grado centrado en la detección, análisis y encaje geométrico de piezas mediante visión por computador. Dicho desarrollo se llevo a cabo con el lenguaje de programación de `Matlab`. Para la parte de la GUI se uso la utilidad de `appdesigner` una herramienta de diseño de interfaces que permite tener unas herramientas básicas que permiten desarrollar una aplicación gráfica.

## 🔧 Dependencias de MATLAB

El proyecto **VisorBieleApp** se apoya en varios *toolboxes* de MATLAB necesarios para la ejecución completa del sistema de análisis y visualización.  
A continuación se detallan los paquetes requeridos y su justificación técnica:

---

### 🧠 Image processing Toolbox (v24.2)

#### 📁 Archivos con dependencia directa

| Archivo | Funciones / Objetos implicados | Descripción del uso |
|----------|-------------------------------|----------------------|
| **controllers/ToolsController.m** | `drawrectangle`, `images.roi.Rectangle` | Creación y manipulación interactiva de regiones de interés (ROI) sobre el lienzo para definir las áreas de recorte (bounding boxes) y eliminar outliers manualmente. |
| **models/BBox.m** | `images.roi.Rectangle`, `addlistener` (eventos ROI) | Gestión interna de los objetos ROI: detección de movimiento, borrado y actualización de coordenadas en tiempo real. Sin este toolbox no se pueden crear ni manipular rectángulos interactivos sobre la imagen. |
| **visual/svgBinaryMask.m** | `poly2mask` | Conversión de contornos vectoriales (extraídos de SVG) a máscaras binarias rasterizadas. Esta función pertenece a *Image Processing Toolbox* y es esencial para el cálculo de las regiones de la pieza. |
| **visual/pointsError.m** | `bwdist`, `interp2` | Cálculo de mapas de distancia entre bordes y máscaras binarizadas, interpolando a nivel subpíxel para cuantificar el error geométrico de los puntos detectados frente al modelo. |
| **visual/createPieceMask.m** | `convhull`, `poly2mask` | Generación de máscaras etiquetadas a partir de los clústeres de bordes detectados. Se usa para segmentar cada pieza dentro de la imagen original y realizar posteriores análisis. |
| **Canvas.m** | `imagesc`, `colormap`, `axis image` | Visualización de imágenes procesadas en escala de grises o RGB, renderizado de máscaras binarias y superposición de bordes detectados. Todas estas funciones pertenecen a *Image Processing Toolbox*. |
| **finalDetectorIter1.m** | `fspecial`, `conv2`, `sqrt`, `abs`, `bwdist` | Implementación del detector de bordes subpíxel, que realiza filtrado y convoluciones espaciales sobre imágenes, operaciones propias del paquete de procesamiento de imágenes. |

#### ⚙️ Rol del toolbox en el proyecto

El *Image Processing Toolbox* cumple un papel esencial en tres niveles del sistema:

1. **Interacción visual:** permite crear y manipular regiones de interés (ROIs) mediante `drawrectangle` y `images.roi.Rectangle`, base de la interacción usuario-lienzo.
2. **Análisis geométrico:** posibilita el cálculo de máscaras binarias (`poly2mask`, `bwdist`) que representan la forma real de las piezas o sus contornos proyectados desde el SVG.
3. **Procesamiento de imagen:** ofrece las funciones de filtrado y convolución (`fspecial`, `conv2`) utilizadas por los detectores subpíxel para suavizar la señal y estimar gradientes.

---

### 📊 Statistics and Machine Learning Toolbox (v24.2)

#### 📁 Archivos con dependencia directa

| Archivo | Funciones / Objetos implicados | Descripción del uso |
|----------|-------------------------------|----------------------|
| **filterPipeline/piece/analyze/analyzeSubstructuresWithDBSCAN.m** | `dbscan` | Núcleo principal de la dependencia. Se utiliza el algoritmo de agrupamiento **DBSCAN (Density-Based Spatial Clustering of Applications with Noise)** para segmentar puntos de bordes subpíxel en clústeres representativos de las piezas o contornos detectados. |
| **errorPipeline/lace/calculate/pickBestEdgeOrientation.m** | `knnsearch` | Permite buscar correspondencias entre puntos detectados y puntos del modelo SVG mediante búsqueda de vecinos más cercanos. Esta función, parte del toolbox, se emplea para calcular la correspondencia mínima en el error cuadrático medio (RMSE) sin rotación. |
| **errorPipeline/lace/calculate/findInnerContours.m** | `pdist`, `mean` | Calcula la **distancia media entre pares de puntos** dentro de cada clúster para determinar si representa un contorno interno o ruido denso. `pdist` es una función avanzada de *Statistics and Machine Learning Toolbox* usada para evaluar la dispersión espacial. |
| **errorPipeline/ErrorPipeController.m** | `procrustes` | Función estadística de ajuste geométrico que minimiza la distancia cuadrática entre dos conjuntos de puntos (en este caso, entre el modelo SVG y los bordes detectados), base matemática del alineamiento de la pieza. |

#### ⚙️ Rol del toolbox en el proyecto

El *Statistics and Machine Learning Toolbox* cumple un papel esencial en las etapas de **análisis geométrico avanzado**, **ajuste estadístico** y **clasificación espacial** del sistema:

1. **Agrupamiento de bordes y ruido**  
   El algoritmo `dbscan` se emplea para segmentar las nubes de puntos detectados en grupos coherentes (piezas, contornos internos y ruido), sin requerir el número de clústeres a priori, lo cual es crucial en el contexto industrial donde las piezas pueden variar en número o forma.

2. **Alineamiento mediante métodos estadísticos**  
   El uso de `procrustes` permite encontrar la transformación óptima (traslación, rotación y escala) entre la pieza detectada y el modelo SVG, minimizando el error cuadrático medio global.

3. **Medición y validación geométrica**  
   Las funciones `knnsearch` y `pdist` se emplean para comparar posiciones de puntos entre conjuntos (detección vs modelo) y evaluar la dispersión interna de los clústeres, operaciones que son base de los cálculos de error y filtrado geométrico.

---

### 🧠 GUI Layout Toolbox (v2.4.2)

El proyecto depende de la *GUI Layout Toolbox* debido al uso de sus componentes avanzados de diseño y distribución de interfaz gráfica.  
Este Add-On, desarrollado por **David Sampson**, amplía las capacidades nativas de App Designer y GUIDE, permitiendo la creación de interfaces dinámicas y redimensionables basadas en contenedores flexibles (`uix.*`).

#### 📁 Archivos con dependencia directa

| Archivo | Clases / Componentes implicados | Descripción del uso |
|----------|----------------------------------|----------------------|
| **viewWrapper/results/TabPiece.m** | `uix.HBox`, `uix.VBox`, `uix.ScrollingPanel` | Implementa un contenedor de pestaña personalizado para cada pieza detectada. Utiliza `HBox` y `VBox` para organizar los botones de control en filas y columnas con tamaños proporcionales y espaciado uniforme, mientras que `ScrollingPanel` permite el desplazamiento vertical en pestañas con contenido extenso. |
| **viewWrapper/TabParams.m** | `uix.VBox`, `uix.ScrollingPanel` | Utiliza contenedores verticales y paneles con desplazamiento para organizar los distintos grupos de parámetros de configuración (subpixel, DBSCAN, error, etc.) dentro de una única pestaña. Gracias a `ScrollingPanel`, la interfaz se adapta a resoluciones y tamaños de ventana variables sin pérdida de accesibilidad. |

#### ⚙️ Rol del toolbox en el proyecto

El *GUI Layout Toolbox* actúa como base del **sistema de disposición y diseño adaptable** de la aplicación.  
Su incorporación permite:

1. **Organización jerárquica del contenido:**  
   Los contenedores `uix.VBox` y `uix.HBox` facilitan la alineación automática de secciones horizontales y verticales, ajustando sus tamaños según el espacio disponible.

2. **Interfaz escalable y desplazable:**  
   El uso de `uix.ScrollingPanel` habilita el desplazamiento de contenido en paneles con múltiples grupos o botones (como la configuración de parámetros o el listado de resultados por pieza), manteniendo la ergonomía visual.

3. **Modularidad y reutilización:**  
   Cada pestaña (`TabPiece`, `TabParams`) se construye de forma independiente con una estructura flexible, lo que favorece la incorporación de nuevos controles o secciones sin necesidad de rediseñar la interfaz general.

---

## 📁 Estructura del Proyecto

```
src/
├── viewWrapper/
│   ├── TabParams.m
│   ├── PreviewFile.m
│   ├── FeedbackManager.m
│   ├── Canvas.m
│   │
│   └── results/
│       ├── TabPiece.m
│       └── Console.m
│
├── models/
│   ├── SVG.m
│   ├── StageViewer.m
│   ├── Stage.m
│   ├── Image.m
│   ├── BBox.m
│   └── AppState.m
│
├── filterPipeline/
│   ├── piece/
│   │   ├── filters/
│   │   ├── boundingbox/
│   │   └── analyze/
│   │
│   ├── imageProcessing/
│   └── analyze/
│
├── errorPipeline/
│   ├── svg/
│   ├── laceError/
│   └── lace/
│       ├── visualization/
│       └── calculate/
│
└── controllers/
    ├── ToolsController.m
    ├── SVGController.m
    ├── ImageController.m
    ├── FilterPipeController.m
    ├── ErrorPipeController
    └── DownloadFilesController.m

```

## 🚀 Vistas de la APP

**Vista inicial**

<img width="1918" height="1030" alt="image" src="https://github.com/user-attachments/assets/00ba297c-fd6b-43c0-a092-04c1557ed25f" />

**Imagen Cargada**

<img width="1919" height="1029" alt="image" src="https://github.com/user-attachments/assets/1fdcaaec-e8b4-4ec5-8c5a-42ade07b2f68" />

**Carga de plano SVG**

<img width="1914" height="1030" alt="image" src="https://github.com/user-attachments/assets/9f5303e9-6b59-4d2f-a256-8921992a0881" />

**Dibujado de regiones de interés**

<img width="1918" height="1028" alt="image" src="https://github.com/user-attachments/assets/2f8a9b34-a300-4c84-9084-d9eee49b9202" />

**Configuración de parámetros**

<img width="1918" height="1028" alt="image" src="https://github.com/user-attachments/assets/3b09cb4a-0f12-46fa-afaa-5aedf7347469" />

**Imagen recortada**

<img width="1918" height="1028" alt="image" src="https://github.com/user-attachments/assets/12f939ed-dd71-4e14-934f-ff31c22458f2" />

**Bordes detectados**

<img width="1918" height="1029" alt="image" src="https://github.com/user-attachments/assets/70e0c00f-8917-4752-8290-7a2cefb2febf" />

**Bordes filtrados**

<img width="1918" height="1030" alt="image" src="https://github.com/user-attachments/assets/d4a24853-96cc-486f-a465-ad2c3f936c95" />

**Visor de las etapas del FilterPipeline**

<img width="1918" height="1030" alt="image" src="https://github.com/user-attachments/assets/6ce4c45d-9217-4d64-80e4-d1e8601bf85e" />

**Eliminar bordes no deseados**

<img width="1920" height="1030" alt="image" src="https://github.com/user-attachments/assets/cba6b436-aa27-4ae7-b608-c6d124a404be" />

**Visualización del error calculado**

<img width="1919" height="1029" alt="image" src="https://github.com/user-attachments/assets/de6f51f1-1ebc-4dfe-b784-14bfb1a525e5" />

**Visor de las etapas del ErrorPipeline**

<img width="1920" height="1029" alt="image" src="https://github.com/user-attachments/assets/7b97bc5d-08cd-40e9-8b47-b37b46f53923" />

**Descarga de ficheros de puntos con su respectivo error**

<img width="1919" height="1028" alt="image" src="https://github.com/user-attachments/assets/4be2d68c-fa72-4919-9cb7-3827ae950cb0" />

