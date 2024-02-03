import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardModel {
  final String imageUrl;
  final String id;
  final List<dynamic> textList;
  final double aspectRatio;
  final String bgColor;
  final String userid;

  CardModel({
    required this.imageUrl,
    required this.id,
    required this.textList,
    required this.aspectRatio,
    required this.bgColor,
    required this.userid,
  });

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'card_id': id,
      'text_json_list': textList,
      'card_ratio': aspectRatio,
      'bg_color': bgColor,
      'userid': userid,
    };
  }

  factory CardModel.fromFirestore(DocumentSnapshot doc) {
    dynamic map = doc.data();
    return CardModel(
      imageUrl: map['image_url'],
      id: map['card_id'],
      textList: map['text_json_list'] as List<dynamic>,
      aspectRatio: map['card_ratio'] ?? 1.2.toDouble(),
      bgColor: map['bg_color'] ?? "FFFF00",
      userid: map['userid'] ?? "NA",
    );
  }
}
