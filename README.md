# 🧩 Análisis de imagen para control de calidad industrial en la fabricación de planchas de acero

Este repositorio contiene el desarrollo del Trabajo de Fin de Grado centrado en la detección, análisis y encaje geométrico de piezas mediante visión por computador. 

## 📁 Estructura del Proyecto

```
src/
├── Piece/
│   ├── analyze/
│   │   ├── findPieceClusters.m
│   │   ├── findInnerContours.m
│   │   ├── filterClustersInsideMask.m
│   │   ├── createPieceMask.m
│   │   └── associateInnerContoursToPieces.m
│   │
│   ├── boundingBox/
│   │   ├── minBoundingBox.m
│   │   ├── expandBoundingBox.m
│   │   ├── drawBoundingBoxOnImage.m
│   │   └── calculateExpandedBoundingBox.m
│   │
│   └── filters/
│       ├── filterEdgesByBoundingBox.m
│       └── filterClustersInsideMask.m
│
│
├── svg/
│   ├── importSVG.m
│   ├── getSVGViewBox.m
│   ├── computeBoundingBoxSVG.m
│   └── plotSVGModel.m
│
│
├── lace/
│	├── analyze/
│   │	├── pickBestEdgeOrientation.m
│   │	├── rotateDetectedEdges180.m
│   │	├── formatCorners.m
│   │	└── fitrect2D.m
│   │
│ 	└── visualization/
│   	├── drawSVGBoundingBox.m
│   	├── drawBoundingBoxesAlignment.m
│   	├── drawPieceOnSVG.m
│   	└── drawPieceBoundingBox.m
│
│
├── imageProcessing/
│   ├── convertToGrayScale.m
│   ├── analyzeSubstructuresWithDBSCAN.m
│   ├── visClusters.m
│   └── visualizeImageWithEdges.m
│
│
├── analyzeData/
│   ├── showImageWithEdges.m
│   └── showFilteredPoints.m
│
```

## 🚀 Flujo General

1. **Preprocesamiento de la imagen**
2. **Detección de bordes y agrupamiento**
3. **Filtrado y extracción de pieza**
4. **Cálculo del bounding box**
5. **Carga del modelo SVG**
6. **Encaje geométrico (Procrustes + mejor orientación [0 || 180])**
7. **Visualización y evaluación**

[Hacer el diagrama de flujo]

## 🧰 Requisitos

- MATLAB R2022a o superior
- Toolboxes necesarios: *Image Processing Toolbox*, *Statistics and Machine Learning Toolbox*