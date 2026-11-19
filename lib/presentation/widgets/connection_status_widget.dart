import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final String label;
  final bool isConnected;
  final IconData icon;

  const ConnectionStatusWidget({
    super.key,
    required this.label,
    required this.isConnected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? const Color(0xFF00D4AA).withValues(alpha: 0.2)
            : const Color(0xFFEB1555).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isConnected ? const Color(0xFF00D4AA) : const Color(0xFFEB1555),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                isConnected ? const Color(0xFF00D4AA) : const Color(0xFFEB1555),
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFF00D4AA)
                  : const Color(0xFFEB1555),
              shape: BoxShape.circle,
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00D4AA).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
