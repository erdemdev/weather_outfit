import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  final List<String> alerts;

  const AlertBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Bugün Dikkat Et',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7B5800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  alert,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A4200),
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}