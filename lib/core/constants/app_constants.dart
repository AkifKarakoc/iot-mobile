class AppConstants {
  // Gemini AI Configuration
  // Set your own key here locally; do NOT commit a real key.
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String geminiModel = 'gemini-2.5-flash';

  // API Configuration (Legacy - now using Gemini)
  static const String baseApiUrl = 'https://your-backend-api.com/api';
  static const String adviceEndpoint = '/compost-advice';
  static const int apiTimeout = 30000; // 30 seconds for AI

  // ESP32-CAM Configuration
  static const String defaultEsp32Ip = '192.168.1.100';
  static const String captureEndpoint = '/capture';
  static const String streamEndpoint = '/stream';
  static const int cameraTimeout = 5000; // 5 seconds

  // AI Model Configuration
  static const String modelPath = 'assets/models/yolov11.tflite';
  static const int inputImageSize = 640; // YOLOv11 default input size
  static const double confidenceThreshold = 0.5;
  static const double iouThreshold = 0.45;

  // Local Data
  static const String wasteGuideJsonPath = 'assets/data/waste_guide.json';

  // UI Constants
  static const String appName = 'BioCycle AI';
  static const double fabSize = 72.0;
  static const double iconSize = 24.0;

  // Waste Class Names (YOLOv11 output mapping)
  static const Map<int, String> wasteClassNames = {
    0: 'apple',
    1: 'banana',
    2: 'bread',
    3: 'carrot',
    4: 'citrus',
    5: 'cucumber',
    6: 'egg',
    7: 'leafy_greens',
    8: 'onion',
    9: 'pepper',
    10: 'potato',
    11: 'tomato',
  };

  // Storage Keys
  static const String esp32IpKey = 'esp32_ip_address';
  static const String lastAnalysisKey = 'last_analysis';
}
