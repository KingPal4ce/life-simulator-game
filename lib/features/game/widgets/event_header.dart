import 'package:flutter/material.dart';

class EventHeader extends StatelessWidget {
  final String title;
  final String description;

  const EventHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Event Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            // Using a pixel font family here is highly recommended!
          ),
        ),
        const SizedBox(height: 8),
        // Event Description
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
