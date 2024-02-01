import 'package:flutter/material.dart';

class TextProperties {
  final String text;
  final double fontSize;
  final String color;
  final String fontfamily;
  Offset position;
  bool isSelected;

  TextProperties({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontfamily,
    required this.position,
    required this.isSelected,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'fontSize': fontSize,
      'color': color,
      'fontfamily': fontfamily,
      'position': {
        'dx': position.dx,
        'dy': position.dy,
      },
      'isSelected': isSelected,
    };
  }

  void resetSelection() {
    isSelected = false;
  }

  factory TextProperties.fromJson(Map<String, dynamic> json) {
    return TextProperties(
      text: json['text'] ?? "hello",
      fontSize: json['fontSize'] ?? 8,
      color: json['color'] ?? "FFFFFF",
      fontfamily: json['fontfamily'] ?? "Roboto",
      isSelected: json['isSelected'] ?? false,
      position: Offset(
        json['position']['dx'] ?? 0.0,
        json['position']['dy'] ?? 0.0,
      ),
    );
  }
}
