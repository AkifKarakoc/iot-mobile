# YOLOv11 Model Placeholder

Bu klasöre eğitilmiş YOLOv11 modelinizi (.tflite formatında) yerleştirin.

## Model Gereksinimleri:

- **Format**: TensorFlow Lite (.tflite)
- **Model**: YOLOv11 (veya uyumlu YOLO versiyonu)
- **Input Shape**: 640x640x3 (RGB)
- **Output**: Object detection (bounding boxes + class probabilities)

## Model Dosyası:

Dosya adı: `yolov11.tflite`

## Model Eğitimi:

Model, atık sınıflandırması için eğitilmiş olmalıdır. Desteklenen sınıflar:
- apple
- banana
- orange
- carrot
- potato
- tomato
- bread
- eggshell
- coffee_grounds
- tea_bag

Daha fazla sınıf eklemek için `lib/core/constants/app_constants.dart` dosyasındaki `wasteClassNames` haritasını güncelleyin.
