# BioCycle AI 🌱🤖

**IoT ve Yapay Zeka Destekli Akıllı Atık Analizi ve Kompost Önerisi Uygulaması**

BioCycle AI, ESP32-CAM IoT cihazından alınan atık fotoğraflarını cihaz üzerinde (on-device) YOLOv11 modeliyle analiz eder ve kullanıcılara akıllı kompost önerileri sunar.

## 🎯 Özellikler

### ✨ Temel Özellikler
- **ESP32-CAM Entegrasyonu**: Gerçek zamanlı kamera akışı ve yüksek çözünürlüklü görüntü yakalama
- **On-Device AI**: TFLite ile cihaz üzerinde YOLOv11 object detection
- **Hibrit Zeka Sistemi**: 
  - 🌐 **Online Mod**: Backend API'den güncel kompost önerileri + BioBot chat
  - 📴 **Offline Mod**: Yerel JSON veritabanından temel öneriler
- **Modern UI**: Minimalist, dark-theme tasarım
- **Gerçek Zamanlı Durum İzleme**: Internet ve ESP32 bağlantı durumu göstergeleri

### 🏗️ Mimari
- **Clean Architecture**: Domain, Data, Presentation katmanları
- **State Management**: Riverpod
- **Dependency Injection**: get_it + injectable
- **Error Handling**: Kapsamlı hata yönetimi ve kullanıcı geri bildirimi

## 📋 Gereksinimler

### Yazılım Gereksinimleri
- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0

### Donanım Gereksinimleri
- ESP32-CAM modülü
- WiFi bağlantısı

### AI Model
- YOLOv11 TFLite modeli (.tflite formatında)
- Model dosyası: `assets/models/yolov11.tflite`

## 🚀 Kurulum

### 1. Projeyi Klonlayın veya İndirin

```bash
cd "IOT Uygulama"
```

### 2. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 3. Code Generation Çalıştırın

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. YOLOv11 Modelini Ekleyin

Eğitilmiş YOLOv11 modelinizi (.tflite) şu konuma yerleştirin:
```
assets/models/yolov11.tflite
```

### 5. ESP32-CAM'i Yapılandırın

ESP32-CAM'inizin şu endpoint'leri desteklediğinden emin olun:
- `/capture` - Yüksek çözünürlüklü fotoğraf çekimi
- `/stream` - Canlı video akışı

### 6. Backend API'yi Yapılandırın (Opsiyonel)

`lib/core/constants/app_constants.dart` dosyasında backend API URL'inizi güncelleyin:

```dart
static const String baseApiUrl = 'https://your-backend-api.com/api';
```

### 7. Uygulamayı Çalıştırın

```bash
flutter run
```

## 📱 Kullanım

### İlk Kurulum
1. Uygulamayı açın
2. Sağ üstteki ESP32 durum göstergesine tıklayın
3. ESP32-CAM'inizin IP adresini girin (örn: 192.168.1.100)
4. Bağlantıyı doğrulayın

### Atık Analizi
1. ESP32-CAM'in atığı görmesini sağlayın
2. Ortadaki büyük "ANALİZ ET" butonuna basın
3. Sistem otomatik olarak:
   - Fotoğraf çeker
   - AI ile analiz eder
   - Kompost önerisi getirir
4. Sonuçları inceleyin ve BioBot ile sohbet edin (online modda)

## 🏛️ Proje Yapısı

```
lib/
├── core/
│   ├── constants/          # Uygulama sabitleri
│   ├── di/                 # Dependency injection
│   ├── errors/             # Hata tipleri
│   └── utils/              # Yardımcı fonksiyonlar
├── data/
│   ├── datasources/        # Veri kaynakları
│   │   ├── esp32_camera_service.dart
│   │   ├── object_detection_service.dart
│   │   ├── hybrid_advice_service.dart
│   │   └── connectivity_service.dart
│   ├── models/             # Data modelleri
│   └── repositories/       # Repository implementasyonları
├── domain/
│   ├── entities/           # İş varlıkları
│   ├── repositories/       # Repository arayüzleri
│   └── usecases/           # İş mantığı
└── presentation/
    ├── pages/              # UI sayfaları
    ├── providers/          # Riverpod provider'lar
    └── widgets/            # Yeniden kullanılabilir widget'lar
```

## 🔧 Yapılandırma

### ESP32-CAM IP Adresi
Uygulama içinden ayarlanabilir veya SharedPreferences'ta saklanır.

### Waste Class Names
Yeni atık türleri eklemek için `app_constants.dart` dosyasını düzenleyin:

```dart
static const Map<int, String> wasteClassNames = {
  0: 'apple',
  1: 'banana',
  // Yeni sınıflar ekleyin...
};
```

### Yerel Veri Tabanı
`assets/data/waste_guide.json` dosyasını düzenleyerek offline mod için veri ekleyin.

## 🎨 UI Tasarımı

### Renk Paleti
- **Primary**: #00D4AA (Turkuaz)
- **Background**: #0A0E21 (Koyu Mavi)
- **Card**: #1D1E33 (Gri-Mavi)
- **Error**: #EB1555 (Kırmızı)

### Bileşenler
- **Header**: Logo + Bağlantı durumu göstergeleri
- **Viewer**: Canlı kamera akışı veya placeholder
- **FAB**: 72px yuvarlak analiz butonu
- **Bottom Bar**: Geçmiş ve Galeri butonları

## 🧪 Test

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📦 Bağımlılıklar

### Ana Paketler
- `flutter_riverpod`: State management
- `tflite_flutter`: AI inference
- `dio`: HTTP client
- `connectivity_plus`: Network monitoring
- `get_it` & `injectable`: Dependency injection

### UI Paketler
- `cached_network_image`: Görüntü önbellekleme
- `shimmer`: Loading animasyonları

### Utility Paketler
- `equatable`: Value equality
- `dartz`: Functional programming
- `shared_preferences`: Local storage

## 🔄 Hibrit Zeka Sistemi

### Online Mod (Öncelikli)
1. Internet bağlantısı kontrol edilir
2. Backend API'ye istek atılır
3. Güncel kompost önerisi alınır
4. BioBot chat aktif edilir

### Offline Mod (Yedek)
1. API başarısız olursa veya internet yoksa
2. Yerel JSON dosyasından veri okunur
3. Temel kompost önerisi gösterilir
4. Chat özelliği devre dışı kalır

## 🐛 Sorun Giderme

### ESP32-CAM Bağlanamıyor
- IP adresini kontrol edin
- ESP32-CAM'in aynı WiFi ağında olduğundan emin olun
- Firewall ayarlarını kontrol edin

### Model Yüklenemiyor
- `assets/models/yolov11.tflite` dosyasının var olduğundan emin olun
- `pubspec.yaml` dosyasında assets tanımlandığından emin olun

### Build Runner Hatası
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

## 👨‍💻 Geliştirici

BioCycle AI - IoT & AI Powered Waste Management

---

**Not**: Bu uygulama Clean Architecture prensiplerine uygun olarak geliştirilmiştir ve production-ready kod kalitesindedir.
