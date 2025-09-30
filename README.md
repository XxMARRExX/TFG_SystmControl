# 🧩 Análisis de imagen para control de calidad industrial en la fabricación de planchas de acero

Este repositorio contiene el desarrollo del Trabajo de Fin de Grado centrado en la detección, análisis y encaje geométrico de piezas mediante visión por computador. 

## 📁 Estructura del Proyecto

```
src/
├── viewWrapper/
│   ├── PreviewFile.m
│   ├── Canvas.m
│   │
│   └── results/
│       ├── TabPiece.m
│       └── Console.m
│
├── models/
│   ├── SVG.m
│   ├── Image.m
│   ├── BBox.m
│   └── AppState.m
│
└── controllers/
    ├── ToolsController.m
    ├── SVGController.m
    ├── PipeController.m
    └── ImageController.m
```

## 🚀 Vistas de la APP

**Vista inicial**

<img width="1063" height="770" alt="image" src="https://github.com/user-attachments/assets/a18337ac-35b1-4391-8c1c-e87b5888bab2" />

**Imagen Cargada**

<img width="1063" height="772" alt="image" src="https://github.com/user-attachments/assets/cbeaa44f-390b-41ca-9642-6d5366b16c5f" />

**Carga de plano SVG**

<img width="1063" height="775" alt="image" src="https://github.com/user-attachments/assets/e640cb85-a3dd-430d-acf1-014f7ae2e8b8" />

**Dibujado de regiones de interés**

<img width="1066" height="775" alt="image" src="https://github.com/user-attachments/assets/ab087b35-13ad-439e-abc3-b065af8258f7" />

**Imagen recortada**

<img width="1062" height="772" alt="ImplementedGUI-v3_PiezaRecortada" src="https://github.com/user-attachments/assets/e40581ef-d6b1-42d1-9c09-e5df072bb5ad" />

**Bordes detectados**

<img width="1065" height="776" alt="ImplementedGUI-v3_EdgesDetectados" src="https://github.com/user-attachments/assets/c2b54b42-a4e8-4781-950a-17980359c064" />
