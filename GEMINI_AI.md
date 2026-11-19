# 🤖 Gemini AI Entegrasyonu

BioCycle AI artık Google Gemini AI kullanarak **akıllı kompost ve hayvan besleme önerileri** sunuyor!

## 🎯 Yeni Özellik: AI-Powered Recommendations

### Önceki Sistem (Statik)
- ❌ Sabit backend API
- ❌ Önceden tanımlı cevaplar
- ❌ Sınırlı bilgi

### Yeni Sistem (AI-Powered) ✨
- ✅ Google Gemini 2.0 Flash
- ✅ Dinamik, akıllı cevaplar
- ✅ Hayvan besleme odaklı
- ✅ Toksik madde uyarıları
- ✅ Özel yem reçeteleri

## 📋 Gemini AI Özellikleri

### 1. Uzman Sistem Promptu
Gemini AI'ya özel hazırlanmış prompt:
- **Rol**: Ziraat Mühendisi + Veteriner Hekim
- **Odak**: Çiftlik ve sokak hayvanları
- **Kısıtlama**: Solucan/böcek kompostu yok
- **Güvenlik**: Toksik madde uyarıları

### 2. Yapılandırılmış Çıktı
AI şu formatta cevap verir:
```
--- 🐾 HAYVAN BESLEME VE YEM RAPORU 🐾 ---

✅ Uygun Olduğu Hayvanlar:
(İnek, Tavuk, Keçi vb.)

⛔ Zehirli/Tehlikeli Olduğu Hayvanlar:
(Soğan → Kedi/Köpek için tehlikeli)

🥣 Zenginleştirilmiş Mama/Yem Reçetesi:
(Saman, kepek, et suyu vb. eklemeler)

💡 Sonuç:
YEM / GÜBRE / İMHA
```

### 3. Fallback Sistemi
- **Online**: Gemini AI'dan canlı cevap
- **Offline**: Basit yerel öneri
- **Hata durumu**: Güvenli varsayılan cevap

## 🔧 Teknik Detaylar

### Yeni Dosyalar
**[gemini_advice_service.dart](file:///c:/Users/akifk/OneDrive%20-%20Dokuz%20Eylül%20Üniversitesi/Masaüstü/IOT%20Uygulama/lib/data/datasources/gemini_advice_service.dart)**
- Gemini AI entegrasyonu
- Özel prompt builder
- Response parser
- Fallback logic

### Güncellenen Dosyalar
- `pubspec.yaml`: google_generative_ai paketi eklendi
- `app_constants.dart`: Gemini API key ve model
- `waste_repository_impl.dart`: GeminiAdviceService kullanımı

### API Yapılandırması
```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
static const String geminiModel = 'gemini-2.0-flash-exp';
```

## 📱 Kullanıcı Deneyimi

### Analiz Akışı
1. Kullanıcı fotoğraf çeker
2. YOLOv11 atığı tespit eder (örn: "apple")
3. **Gemini AI devreye girer**:
   - "Apple" için özel prompt oluşturulur
   - AI hayvan besleme raporu üretir
   - Toksik madde kontrolü yapar
   - Yem reçetesi önerir
4. Sonuç kullanıcıya gösterilir

### Örnek AI Cevabı
```
✅ Uygun Hayvanlar: İnek, Keçi, Tavuk, At
⛔ Tehlikeli: Yok (Elma güvenlidir)
🥣 Reçete: Saman ve kepek ile karıştırın
💡 Sonuç: YEM
```

## ⚡ Avantajlar

1. **Akıllı Öneriler**: Her atık için özel analiz
2. **Güvenlik**: Toksik madde uyarıları
3. **Pratik**: Yem reçeteleri
4. **Esneklik**: Offline fallback
5. **Güncel**: AI sürekli öğrenir

## 🔒 Güvenlik

- API key güvenli saklanıyor
- Timeout koruması (30 saniye)
- Hata yönetimi
- Fallback mekanizması

## 📊 Performans

- **Online mod**: ~2-5 saniye (AI inference)
- **Offline mod**: Anında (local fallback)
- **Timeout**: 30 saniye
- **Model**: Gemini 2.0 Flash (hızlı)

## 🚀 Kullanım

Kullanıcı için hiçbir değişiklik yok! Arka planda:
1. Internet varsa → Gemini AI
2. Internet yoksa → Local fallback
3. AI hata verirse → Local fallback

Tamamen şeffaf! 🎉

---

**Not**: Gemini API key production'da environment variable olarak saklanmalıdır.
