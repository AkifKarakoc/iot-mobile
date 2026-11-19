import 'package:equatable/equatable.dart';

class CompostAdvice extends Equatable {
  final String wasteType;
  final bool isCompostable;
  final List<String> tips;
  final List<String> suitableAnimals;
  final String? additionalInfo;
  final bool isFromApi; // true = API, false = Local JSON

  const CompostAdvice({
    required this.wasteType,
    required this.isCompostable,
    required this.tips,
    required this.suitableAnimals,
    this.additionalInfo,
    required this.isFromApi,
  });

  @override
  List<Object?> get props => [
        wasteType,
        isCompostable,
        tips,
        suitableAnimals,
        additionalInfo,
        isFromApi,
      ];

  String get sourceLabel => isFromApi ? 'Güncel Veri (API)' : 'Yerel Veri';
}
