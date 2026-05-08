import 'package:flutter/material.dart';

class KidRoundBackButton extends StatelessWidget {
  const KidRoundBackButton({
    required this.iconColor,
    required this.onTap,
    this.borderColor = const Color(0xFF90CAF9),
    this.icon = Icons.chevron_left_rounded,
    super.key,
  });

  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
