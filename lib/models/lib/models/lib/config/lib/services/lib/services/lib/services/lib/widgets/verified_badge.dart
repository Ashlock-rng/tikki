import 'package:flutter/material.dart';
import '../models/user_model.dart';

class VerifiedBadge extends StatelessWidget {
  final CheckmarkType type;
  final double size;

  const VerifiedBadge({
    super.key,
    required this.type,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (type == CheckmarkType.none) return const SizedBox.shrink();

    return Tooltip(
      message: type.label,
      child: Icon(
        Icons.verified,
        color: type.color,
        size: size,
      ),
    );
  }
}

class NameWithBadge extends StatelessWidget {
  final String name;
  final CheckmarkType checkmark;
  final TextStyle? style;
  final double badgeSize;

  const NameWithBadge({
    super.key,
    required this.name,
    required this.checkmark,
    this.style,
    this.badgeSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            name,
            style: style ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (checkmark != CheckmarkType.none) ...[
          const SizedBox(width: 4),
          VerifiedBadge(type: checkmark, size: badgeSize),
        ],
      ],
    );
  }
}
