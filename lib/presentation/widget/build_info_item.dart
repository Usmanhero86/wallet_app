import 'package:flutter/material.dart';

class InfoItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String value;

  const InfoItemCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
