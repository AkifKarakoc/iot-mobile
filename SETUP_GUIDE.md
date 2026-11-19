# BioCycle AI - Kurulum ve Çalıştırma Kılavuzu

## 📋 Ön Hazırlık

### 1. Flutter Kurulumu Kontrolü

Terminalden Flutter'ın kurulu olduğunu kontrol edin:

```bash
flutter --version
flutter doctor
```

Eğer Flutter kurulu değilse: https://docs.flutter.dev/get-started/install

## 🚀 Adım Adım Kurulum

### Adım 1: Bağımlılıkları Yükleyin

```bash
cd "c:\Users\akifk\OneDrive - Dokuz Eylül Üniversitesi\Masaüstü\IOT Uygulama"
flutter pub get
```

### Adım 2: Code Generation Çalıştırın

Dependency injection için gerekli kodları oluşturun:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Bu komut `injection.config.dart` dosyasını otomatik olarak oluşturacaktır.

### Adım 3: YOLOv11 Modelini Ekleyin

**ÖNEMLİ**: Uygulamanın çalışması için YOLOv11 modelini eklemeniz gerekiyor.

1. Eğitilmiş YOLOv11 modelinizi (.tflite formatında) hazırlayın
2. Model dosyasını şu konuma kopyalayın:
   ```
   assets/models/yolov11.tflite
   ```

**Model Gereksinimleri:**
- Format: TensorFlow Lite (.tflite)
- Input: 640x640x3 (RGB)
- Output: YOLO detection format

### Adım 4: ESP32-CAM Yapılandırması

ESP32-CAM'inizin şu endpoint'leri desteklediğinden emin olun:

- **Capture Endpoint**: `http://<IP>/capture` - JPEG formatında fotoğraf döndürmeli
- **Stream Endpoint**: `http://<IP>/stream` - MJPEG stream sağlamalı

**Örnek ESP32-CAM Arduino Kodu** (temel yapı):

```cpp
#include "esp_camera.h"
#include <WiFi.h>
#include <WebServer.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

WebServer server(80);

void handleCapture() {
  camera_fb_t * fb = esp_camera_fb_get();
  if (!fb) {
    server.send(500, "text/plain", "Camera capture failed");
    return;
  }
  server.send_P(200, "image/jpeg", (const char *)fb->buf, fb->len);
  esp_camera_fb_return(fb);
}

void setup() {
  // Camera configuration
  // WiFi connection
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
  
  server.on("/capture", handleCapture);
  server.begin();
}

void loop() {
  server.handleClient();
}
```

### Adım 5: Backend API Yapılandırması (Opsiyonel)

Eğer backend API'niz varsa:

1. `lib/core/constants/app_constants.dart` dosyasını açın
2. `baseApiUrl` değerini güncelleyin:

```dart
static const String baseApiUrl = 'https://your-api-url.com/api';
```

**API Endpoint Formatı:**
```
GET /compost-advice?wasteType=apple

Response:
{
  "wasteType": "Meyve Kabuğu",
  "compostable": true,
  "tips": ["İpucu 1", "İpucu 2"],
  "animals": ["Tavuk", "Keçi"],
  "additionalInfo": "Ek bilgi"
}
```

## ▶️ Uygulamayı Çalıştırma

### Geliştirme Modu

```bash
flutter run
```

Veya cihaz seçerek:

```bash
flutter devices
flutter run -d <device-id>
```

### Release Build (Android)

```bash
flutter build apk --release
```

APK dosyası: `build/app/outputs/flutter-apk/app-release.apk`

### Release Build (iOS)

```bash
flutter build ios --release
```

## 🧪 İlk Test

### 1. ESP32-CAM Bağlantısı Test

1. Uygulamayı açın
2. Sağ üstteki ESP32 durum göstergesine tıklayın
3. ESP32-CAM IP adresini girin (örn: `192.168.1.100`)
4. Ana ekrana dönün
5. ESP32 göstergesinin yeşil olduğunu kontrol edin

### 2. Offline Mod Test

1. Cihazın internet bağlantısını kapatın
2. "ANALİZ ET" butonuna basın
3. Sistem yerel JSON'dan veri göstermeli
4. Sonuç dialogunda "Yerel Veri" etiketi görünmeli

### 3. Online Mod Test (Backend varsa)

1. Internet bağlantısını açın
2. "ANALİZ ET" butonuna basın
3. Sistem API'den veri almalı
4. BioBot chat aktif olmalı

## ⚠️ Sık Karşılaşılan Sorunlar

### Sorun 1: "Model yüklenemedi" Hatası

**Çözüm:**
- `assets/models/yolov11.tflite` dosyasının var olduğunu kontrol edin
- `pubspec.yaml` dosyasında assets tanımlı mı kontrol edin
- `flutter clean` ve `flutter pub get` komutlarını çalıştırın

### Sorun 2: ESP32-CAM Bağlanamıyor

**Çözüm:**
- ESP32-CAM ve telefon aynı WiFi ağında mı?
- IP adresi doğru mu?
- ESP32-CAM çalışıyor mu? (Serial monitor kontrol edin)
- Firewall ayarlarını kontrol edin

### Sorun 3: Build Runner Hatası

**Çözüm:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Sorun 4: Dependency Conflict

**Çözüm:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## 📱 Uygulama İçi Ayarlar

### ESP32-CAM IP Değiştirme

1. Ana ekranda ESP32 bağlı değilse placeholder gösterilir
2. "IP Ayarları" butonuna tıklayın
3. Yeni IP adresini girin
4. "Kaydet" butonuna basın

### Atık Sınıfları Ekleme

`lib/core/constants/app_constants.dart` dosyasını düzenleyin:

```dart
static const Map<int, String> wasteClassNames = {
  0: 'apple',
  1: 'banana',
  // Yeni sınıflar ekleyin
  11: 'new_waste_type',
};
```

Aynı zamanda `assets/data/waste_guide.json` dosyasına da ekleyin:

```json
{
  "new_waste_type": {
    "wasteType": "Yeni Atık Türü",
    "compostable": true,
    "tips": ["İpucu 1"],
    "animals": ["Hayvan 1"]
  }
}
```

## 🎨 UI Özelleştirme

### Renkleri Değiştirme

`lib/presentation/pages/dashboard_page.dart` dosyasındaki renk kodlarını düzenleyin:

```dart
// Primary color
Color(0xFF00D4AA)  // Turkuaz

// Background
Color(0xFF0A0E21)  // Koyu mavi

// Card background
Color(0xFF1D1E33)  // Gri-mavi
```

## 📊 Performans İpuçları

1. **Model Optimizasyonu**: YOLOv11 modelinizi quantize edin (INT8)
2. **Görüntü Boyutu**: ESP32-CAM'den gelen görüntü boyutunu optimize edin
3. **Cache**: Riverpod provider'ları cache kullanır, gereksiz yere reset etmeyin

## 🔐 Güvenlik Notları

1. API anahtarlarını environment variable'larda saklayın
2. HTTPS kullanın (production için)
3. ESP32-CAM için authentication ekleyin

## 📞 Destek

Sorun yaşarsanız:
1. README.md dosyasını okuyun
2. Console log'larını kontrol edin
3. `flutter doctor` çalıştırın

---

**Başarılar! 🚀**
