import 'package:flutter/material.dart';
import '../../domain/entities/waste_analysis.dart';
import 'biobot_chat_widget.dart';

class ResultDialog extends StatelessWidget {
  final WasteAnalysis analysis;

  const ResultDialog({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final advice = analysis.advice;
    final primaryDetection = analysis.primaryDetection;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Analiz Tamamlandı',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detection Info
                    if (primaryDetection != null) ...[
                      _buildSectionTitle('Tespit Edilen Atık'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111328),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4AA)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.eco,
                                color: Color(0xFF00D4AA),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    primaryDetection.className.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Güven: ${(primaryDetection.confidence * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Color(0xFF8D8E98),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Composting Advice
                    if (advice != null) ...[
                      _buildSectionTitle('Kompost Önerisi'),
                      const SizedBox(height: 12),
                      _buildAdviceCard(advice),
                      const SizedBox(height: 24),

                      // BioBot Chat (only if online)
                      if (advice.isFromApi) ...[
                        _buildSectionTitle('BioBot Asistan'),
                        const SizedBox(height: 12),
                        const BioBotChatWidget(),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFEB1555).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFEB1555),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                color: Color(0xFFEB1555),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Çevrimdışı mod - ${advice.sourceLabel}',
                                  style: const TextStyle(
                                    color: Color(0xFFEB1555),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      const Center(
                        child: Text(
                          'Atık tespit edilemedi',
                          style: TextStyle(
                            color: Color(0xFF8D8E98),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF00D4AA),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAdviceCard(advice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111328),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compostable Status
          Row(
            children: [
              Icon(
                advice.isCompostable ? Icons.check_circle : Icons.cancel,
                color: advice.isCompostable
                    ? const Color(0xFF00D4AA)
                    : const Color(0xFFEB1555),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                advice.isCompostable
                    ? 'Kompost Edilebilir'
                    : 'Kompost Edilemez',
                style: TextStyle(
                  color: advice.isCompostable
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFFEB1555),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tips
          if (advice.tips.isNotEmpty) ...[
            const Text(
              'İpuçları:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...advice.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: Color(0xFF00D4AA),
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            color: Color(0xFF8D8E98),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Suitable Animals
          if (advice.suitableAnimals.isNotEmpty) ...[
            const Text(
              'Uygun Hayvanlar:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: advice.suitableAnimals
                  .map((animal) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00D4AA),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          animal,
                          style: const TextStyle(
                            color: Color(0xFF00D4AA),
                            fontSize: 12,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
