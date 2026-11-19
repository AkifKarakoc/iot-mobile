import '../../domain/entities/compost_advice.dart';

class CompostAdviceModel {
  final String wasteType;
  final bool isCompostable;
  final List<String> tips;
  final List<String> suitableAnimals;
  final String? additionalInfo;

  CompostAdviceModel({
    required this.wasteType,
    required this.isCompostable,
    required this.tips,
    required this.suitableAnimals,
    this.additionalInfo,
  });

  /// Creates model from JSON
  factory CompostAdviceModel.fromJson(Map<String, dynamic> json) {
    return CompostAdviceModel(
      wasteType: json['wasteType'] as String? ?? '',
      isCompostable: json['compostable'] as bool? ?? false,
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suitableAnimals: (json['animals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      additionalInfo: json['additionalInfo'] as String?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'wasteType': wasteType,
      'compostable': isCompostable,
      'tips': tips,
      'animals': suitableAnimals,
      'additionalInfo': additionalInfo,
    };
  }

  /// Converts to domain entity
  CompostAdvice toEntity({required bool isFromApi}) {
    return CompostAdvice(
      wasteType: wasteType,
      isCompostable: isCompostable,
      tips: tips,
      suitableAnimals: suitableAnimals,
      additionalInfo: additionalInfo,
      isFromApi: isFromApi,
    );
  }
}
