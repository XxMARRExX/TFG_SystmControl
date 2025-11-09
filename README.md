# 🧩 Análisis de imagen para control de calidad industrial en la fabricación de planchas de acero

Este repositorio contiene el desarrollo del Trabajo de Fin de Grado centrado en la detección, análisis y encaje geométrico de piezas mediante visión por computador. Dicho desarrollo se llevo a cabo con el lenguaje de programación de `Matlab`. Para la parte de la GUI se uso la utilidad de `appdesigner` un paquete que permite tener unas herramientas básicas que permiten desarrollar una aplicación gráfica.

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

