# BioCycle AI - Hızlı Başlangıç

## ✅ Tamamlanan İşler

BioCycle AI uygulaması tamamen oluşturuldu! İşte yapılanlar:

### 📁 Proje Yapısı
```
IOT Uygulama/
├── lib/
│   ├── core/               # Temel altyapı
│   ├── data/               # Veri katmanı
│   ├── domain/             # İş mantığı
│   └── presentation/       # UI katmanı
├── assets/
│   ├── data/               # waste_guide.json
│   ├── models/             # YOLOv11 model (eklenmeli)
│   └── images/             # Görseller
├── pubspec.yaml            # Bağımlılıklar
├── README.md               # Genel dokümantasyon
└── SETUP_GUIDE.md          # Kurulum kılavuzu
```

### 🎯 Temel Özellikler
- ✅ ESP32-CAM entegrasyonu
- ✅ On-device YOLOv11 AI
- ✅ Hibrit zeka (API + Local JSON)
- ✅ Modern dark-theme UI
- ✅ Gerçek zamanlı durum izleme
- ✅ BioBot chat (online mode)

### 🏗️ Mimari
- ✅ Clean Architecture (3 katman)
- ✅ Riverpod state management
- ✅ Dependency injection
- ✅ Comprehensive error handling

## 🚀 Şimdi Ne Yapmalısınız?

### 1. Flutter Kurulumu (Eğer yoksa)
```bash
# Windows için Flutter SDK indirin:
# https://docs.flutter.dev/get-started/install/windows
```

### 2. Bağımlılıkları Yükleyin
```bash
cd "c:\Users\akifk\OneDrive - Dokuz Eylül Üniversitesi\Masaüstü\IOT Uygulama"
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. YOLOv11 Modelini Ekleyin
Eğitilmiş modelinizi buraya koyun:
```
assets/models/yolov11.tflite
```

### 4. ESP32-CAM'i Hazırlayın
ESP32-CAM'e şu endpoint'leri ekleyin:
- `GET /capture` → JPEG fotoğraf döndür
- `GET /stream` → MJPEG stream

### 5. Uygulamayı Çalıştırın
```bash
flutter run
```

## 📖 Detaylı Dokümantasyon

- **README.md** - Genel bakış ve özellikler
- **SETUP_GUIDE.md** - Adım adım kurulum
- **walkthrough.md** - Teknik detaylar ve mimari

## 🔧 Yapılandırma

### ESP32-CAM IP Adresi
Uygulama içinden ayarlanabilir (varsayılan: 192.168.1.100)

### Backend API (Opsiyonel)
`lib/core/constants/app_constants.dart` dosyasında:
```dart
static const String baseApiUrl = 'https://your-api.com/api';
```

### Atık Sınıfları
Şu anda desteklenen 10 atık türü:
- apple, banana, orange
- carrot, potato, tomato
- bread, eggshell
- coffee_grounds, tea_bag

## 🎨 UI Önizleme

### Ana Ekran
- **Üst Bar**: Logo + Bağlantı durumları
- **Orta Alan**: ESP32 canlı stream
- **Alt Bar**: Geçmiş | ANALİZ ET | Galeri

### Renk Paleti
- Primary: #00D4AA (Turkuaz)
- Background: #0A0E21 (Koyu Mavi)
- Card: #1D1E33 (Gri-Mavi)

## ⚡ Hızlı Test

### Offline Mode Test
1. Internet'i kapat
2. "ANALİZ ET" butonuna bas
3. Yerel JSON'dan veri gösterilmeli

### ESP32 Bağlantı Test
1. ESP32-CAM IP'sini ayarla
2. Üst bardaki ESP32 göstergesi yeşil olmalı
3. Canlı stream görünmeli

## 🆘 Sorun mu Yaşıyorsunuz?

**Flutter kurulu değil:**
- https://docs.flutter.dev/get-started/install

**Model yüklenemiyor:**
- `assets/models/yolov11.tflite` dosyasını kontrol edin

**ESP32 bağlanamıyor:**
- IP adresini kontrol edin
- Aynı WiFi ağında olduğundan emin olun

**Build hatası:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📞 İletişim

Detaylı dokümantasyon için:
- README.md
- SETUP_GUIDE.md
- walkthrough.md (artifacts klasöründe)

---

**Başarılar! 🚀 BioCycle AI ile atık yönetiminde yapay zeka devri başlıyor!**
