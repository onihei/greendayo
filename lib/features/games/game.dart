import 'package:flutter/material.dart';

class Game {
  const Game({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.url,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String url;
  final IconData icon;
  final Color color;
}
