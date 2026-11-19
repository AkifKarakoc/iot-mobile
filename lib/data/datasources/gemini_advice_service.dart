import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/compost_advice.dart';
import 'connectivity_service.dart';

@injectable
class GeminiAdviceService {
  final ConnectivityService _connectivityService;
  late final GenerativeModel _model;

  GeminiAdviceService(this._connectivityService) {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// Gets composting and animal feeding advice using Gemini AI
  /// Falls back to local JSON if offline or API fails
  Future<CompostAdvice> getAdvice(String wasteType) async {
    // Check internet connectivity
    final isOnline = await _connectivityService.isConnected();

    if (isOnline) {
      try {
        print('🤖 Gemini AI: Fetching advice for: $wasteType');
        final advice = await _fetchFromGemini(wasteType);
        print('✅ Gemini AI response received');
        return advice;
      } catch (e) {
        print('⚠️ Gemini AI failed: $e. Using fallback...');
        return _getFallbackAdvice(wasteType);
      }
    } else {
      print('📴 Offline mode: Using fallback advice');
      return _getFallbackAdvice(wasteType);
    }
  }

  /// Fetches advice from Gemini AI
  Future<CompostAdvice> _fetchFromGemini(String wasteType) async {
    try {
      final prompt = _buildPrompt(wasteType);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
        ),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw const ServerFailure('Gemini AI boş yanıt döndü');
      }

      return _parseGeminiResponse(response.text!, wasteType);
    } catch (e) {
      throw ServerFailure('Gemini AI hatası: $e');
    }
  }

  /// Builds the prompt for Gemini AI
  String _buildPrompt(String wasteType) {
    return '''
Sen uzman bir Ziraat Mühendisi ve Veteriner Hekimsin.
Elimde görüntü işleme ile tespit edilmiş şu gıda atığı var: "$wasteType".

Lütfen aşağıdaki kurallara ve formata SIKI SIKIYA uyarak cevap ver:

**KURALLAR:**
1. ASLA solucan, böcek, larva veya sinek kompostu önerme.
2. Sadece **Çiftlik Hayvanları** (İnek, Koyun, Keçi, Tavuk, Kaz) ve **Sokak Hayvanları** (Kedi, Köpek, Kuş) üzerine odaklan.
3. Hayvanlar (kedi/köpek vs) için toksik olan gıdalarda (soğan, sarımsak, çikolata, üzüm vb.) ÇOK NET uyarı ver.

**CEVAP FORMATI:**

--- 🐾 HAYVAN BESLEME VE YEM RAPORU 🐾 ---

✅ **Uygun Olduğu Hayvanlar:**
(Bu karışımı hangi hayvanlar güvenle yiyebilir? Örn: İnekler, Tavuklar veya Sokak Kedileri.)

⛔ **Zehirli/Tehlikeli Olduğu Hayvanlar:**
(Bu listedeki ürünlerden hangisi kime verilmez? Örn: "Soğan içerdiği için Kedilere ve Köpeklere VERİLMEMELİDİR.")

🥣 **Zenginleştirilmiş Mama/Yem Reçetesi:**
(Bu atıkları daha besleyici yapmak için içine dışarıdan ne katalım?
 - Çiftlik hayvanı ise: "Saman, mısır silajı, kepek veya kireç taşı ekleyin."
 - Sokak hayvanı ise: "Haşlanmış makarna, pirinç veya et suyu ile karıştırın." gibi somut öneri ver.)

💡 **Sonuç:**
(Tek kelime ile: YEM veya GÜBRE veya İMHA)

Lütfen sadece bu format ile cevap ver, başka bilgi ekleme.
''';
  }

  /// Parses Gemini AI response into CompostAdvice entity
  CompostAdvice _parseGeminiResponse(String response, String wasteType) {
    try {
      // Extract suitable animals
      final suitableAnimalsMatch = RegExp(
        r'✅\s*\*\*Uygun Olduğu Hayvanlar:\*\*\s*\n(.+?)(?=\n\n|⛔)',
        dotAll: true,
      ).firstMatch(response);

      final suitableAnimals = suitableAnimalsMatch != null
          ? _extractAnimals(suitableAnimalsMatch.group(1) ?? '')
          : <String>[];

      // Extract dangerous animals
      final dangerousMatch = RegExp(
        r'⛔\s*\*\*Zehirli/Tehlikeli Olduğu Hayvanlar:\*\*\s*\n(.+?)(?=\n\n|🥣)',
        dotAll: true,
      ).firstMatch(response);

      final dangerousInfo = dangerousMatch?.group(1)?.trim() ?? '';

      // Extract recipe/tips
      final recipeMatch = RegExp(
        r'🥣\s*\*\*Zenginleştirilmiş Mama/Yem Reçetesi:\*\*\s*\n(.+?)(?=\n\n|💡)',
        dotAll: true,
      ).firstMatch(response);

      final recipe = recipeMatch?.group(1)?.trim() ?? '';

      // Extract result
      final resultMatch = RegExp(
        r'💡\s*\*\*Sonuç:\*\*\s*\n(.+?)$',
        dotAll: true,
      ).firstMatch(response);

      final result = resultMatch?.group(1)?.trim().toUpperCase() ?? 'YEM';
      final isCompostable = result.contains('YEM') || result.contains('GÜBRE');

      // Build tips
      final tips = <String>[];
      if (recipe.isNotEmpty) {
        tips.add(recipe);
      }
      if (dangerousInfo.isNotEmpty) {
        tips.add('⚠️ UYARI: $dangerousInfo');
      }

      return CompostAdvice(
        wasteType: wasteType.toUpperCase(),
        isCompostable: isCompostable,
        tips: tips,
        suitableAnimals: suitableAnimals,
        additionalInfo: response, // Full AI response
        isFromApi: true,
      );
    } catch (e) {
      print('⚠️ Parse error: $e. Using fallback.');
      return _getFallbackAdvice(wasteType);
    }
  }

  /// Extracts animal names from text
  List<String> _extractAnimals(String text) {
    final animals = <String>[];
    final commonAnimals = [
      'İnek',
      'Koyun',
      'Keçi',
      'Tavuk',
      'Kaz',
      'Kedi',
      'Köpek',
      'Kuş'
    ];

    for (final animal in commonAnimals) {
      if (text.contains(animal)) {
        animals.add(animal);
      }
    }

    return animals.isNotEmpty ? animals : ['Tavuk', 'Keçi'];
  }

  /// Fallback advice when Gemini AI is unavailable
  CompostAdvice _getFallbackAdvice(String wasteType) {
    // Simple fallback based on common waste types
    final normalizedType = wasteType.toLowerCase();

    if (normalizedType.contains('apple') ||
        normalizedType.contains('elma') ||
        normalizedType.contains('banana') ||
        normalizedType.contains('muz') ||
        normalizedType.contains('orange') ||
        normalizedType.contains('portakal')) {
      return const CompostAdvice(
        wasteType: 'Meyve Atığı',
        isCompostable: true,
        tips: [
          'Küçük parçalara bölün',
          'Çiftlik hayvanları için güvenlidir',
          'Aşırı tüketimden kaçının'
        ],
        suitableAnimals: ['Tavuk', 'Keçi', 'Koyun', 'İnek'],
        additionalInfo: 'Yerel veri - Internet bağlantısı yok',
        isFromApi: false,
      );
    }

    // Default fallback
    return const CompostAdvice(
      wasteType: 'Genel Atık',
      isCompostable: true,
      tips: [
        'Veteriner veya ziraat uzmanına danışın',
        'Küçük miktarlarda test edin',
        'Hayvan sağlığını gözlemleyin'
      ],
      suitableAnimals: ['Tavuk', 'Keçi'],
      additionalInfo: 'Yerel veri - Detaylı bilgi için internet gerekli',
      isFromApi: false,
    );
  }
}
