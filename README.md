# Filosofía v18042025

![image](https://github.com/user-attachments/assets/d7b25395-14fc-4e96-b7fe-f56d01864bbb)

## Flujo de las funciones:

## 📁 Estructura del proyecto

El proyecto sigue una organización modular basada en componentes funcionales (pieza, modelo SVG, encaje, etc.) y separa claramente las funciones por su propósito.

/src
│
├── Piece/ ← Análisis y procesamiento de la pieza detectada
│ ├── analyzePieceGeometry.m
│ ├── analyzePiece.m
│ ├── computeLinearRegression.m
│ ├── computeRotatedBoundingBox.m
│ ├── createPieceMask.m
│ ├── classifyPixelRegions.m
│ ├── findInnerContours.m
│ └── associateInnerContours.m
│
├── Piece/BboxPiece/ ← Operaciones con cajas delimitadoras de la pieza
│ ├── minBoundingBox.m
│ ├── expandBoundingBox.m
│ ├── drawBoundingBoxOnly.m
│ └── calculateExpandedBox.m
│
├── svg/ ← Gestión del modelo SVG y su conversión a binario
│ ├── importSVG.m
│ ├── getSVGViewBox.m
│ ├── svgBinaryMask.m
│ ├── plotSVGModel.m
│ ├── fitSVGPathsBoundingBox.m
│ └── visualizeBinaryMask.m
│
├── lace/ ← Cálculo del encaje geométrico entre pieza y SVG
│ ├── calculateLace.m
│ ├── rotateDetectedEdges.m
│ ├── reorderCorners.m
│ ├── pickBestEdgeOrientation.m
│ ├── fitrect2D.m
│ ├── fitDetectedPieceBoundingBox.m
│ └── computeBoundingBoxCorners.m
│
├── lace/laceVisualization/ ← Visualización personalizada para encaje
│ ├── drawSVGBoundingBox.m
│ ├── drawPieceOnSVG.m
│ ├── drawPieceBoundingBox.m
│ ├── drawBoundingBoxesAll.m
│ └── drawBoundingBox.m
│
├── imageProcessing/ ← Preprocesamiento de imagen (intensidad, bordes)
│ ├── convertToGrayScale.m
│ └── filterByNormalThreshold.m
│
├── analyzeCluster/ ← Agrupamiento y filtrado de clústeres
│ ├── findPieceClusters.m
│ ├── filterClustersInsideMask.m
│ ├── analyzeSubstructuresWithDBSCAN.m
│ └── visClusters.m
│
├── analyzeData/ ← Visualización y análisis de datos auxiliares
│ ├── estimateDominantOrientation.m
│ ├── showPixelIntensities.m
│ ├── showImageWithEdges.m
│ └── showFilteredPoints.m
│
├── DocFunctions/ ← Funciones de documentación y generación de figuras
│ ├── createDocPicturesLace.m
│ ├── createDocPicturesDetected.m
│ ├── bestSubpixelParams.m
│ ├── saveImage.m
│ └── plotPercentiles.m


> 🧭 Cada carpeta agrupa funciones que operan sobre el mismo contexto, y mantiene la trazabilidad del flujo: desde la lectura del modelo hasta la visualización del encaje.




