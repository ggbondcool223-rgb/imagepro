import 'dart:typed_data';
import 'dart:convert';

class ImageComposeEntity {
  final int? id;
  final Uint8List imageData;
  final String createdAt;

  const ImageComposeEntity({
    this.id,
    required this.imageData,
    required this.createdAt,
  });

  factory ImageComposeEntity.fromMap(Map<String, dynamic> map) {
    return ImageComposeEntity(
      id: map['id'] as int?,
      imageData: base64Decode(map['image_data'] as String),
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'image_data': base64Encode(imageData),
      'created_at': createdAt,
    };
  }
}

