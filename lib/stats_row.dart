import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({
    required this.statIcon,
    required this.statIconColor,
    required this.statLabel,
    required this.statValue,
  });

  final IconData statIcon;
  final Color statIconColor;
  final String statLabel;
  final String statValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: statIconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statIcon, color: statIconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statLabel,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                statValue,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
