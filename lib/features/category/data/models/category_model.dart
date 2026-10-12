import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawName = data['name'] ?? data['title'];
    return CategoryModel(
      id: document.id,
      name: rawName is String ? rawName.trim() : '',
    );
  }
}
