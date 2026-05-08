import 'package:flutter/material.dart';

class KidStarCounterBadge extends StatelessWidget {
  const KidStarCounterBadge({
    required this.count,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.iconSize = 22,
    this.textSize = 20,
    super.key,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD93D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF4B400), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4B400).withValues(alpha: 0.26),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize + 4,
            height: iconSize + 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: iconSize + 3,
                  color: const Color(0xFFF4A200),
                ),
                Icon(
                  Icons.star_rounded,
                  size: iconSize,
                  color: const Color(0xFFFFD54F),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF854D0E),
            ),
          ),
        ],
      ),
    );
  }
}
