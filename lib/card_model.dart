import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String imageUrl;
  final String id;
  final List<dynamic> textList;

  CardModel({
    required this.imageUrl,
    required this.id,
    required this.textList,
  });

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'card_id': id,
      'text_json_list': textList,
    };
  }

  factory CardModel.fromFirestore(DocumentSnapshot doc) {
    dynamic map = doc.data();
    return CardModel(
      imageUrl: map['image_url'],
      id: map['card_id'],
      textList: map['text_json_list'] as List<dynamic>,
    );
  }
}
