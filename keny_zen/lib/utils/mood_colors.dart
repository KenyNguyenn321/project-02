import 'package:flutter/material.dart';

// returns a calm color for each mood
Color getMoodColor(String mood) {
  switch (mood) {
    case 'Calm':
      return Colors.blue.shade300;
    case 'Happy':
      return Colors.green.shade400;
    case 'Stressed':
      return Colors.orange.shade400;
    case 'Sad':
      return Colors.purple.shade300;
    case 'Overwhelmed':
      return Colors.red.shade300;
    default:
      return Colors.grey;
  }
}