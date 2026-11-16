import 'package:flutter/material.dart';

class OutfitRating extends StatelessWidget {
  final int? currentRating;
  final ValueChanged<int> onRate;

  const OutfitRating({super.key, this.currentRating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '⭐',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu kombini puanla',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentRating != null
                      ? '$currentRating/5 puan verdin'
                      : 'Nasıl buldun?',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final filled = currentRating != null && i < currentRating!;
              return GestureDetector(
                onTap: () => onRate(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: filled ? Colors.amber : (isDark ? Colors.white24 : Colors.grey[300]),
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
