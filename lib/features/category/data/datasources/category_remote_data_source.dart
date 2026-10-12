import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> getCategoryById(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  const CategoryRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs
          .map(CategoryModel.fromFirestore)
          .where((category) => category.name.isNotEmpty)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on FirebaseException catch (error) {
      throw ServerException(
        message: error.message ?? 'Failed to load categories',
      );
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    if (id.trim().isEmpty) {
      throw const ServerException(message: 'A category ID is required');
    }

    try {
      final document = await _firestore.collection('categories').doc(id).get();
      if (!document.exists) {
        throw const ServerException(message: 'Category not found');
      }

      final category = CategoryModel.fromFirestore(document);
      if (category.name.isEmpty) {
        throw const ServerException(message: 'Category has no name');
      }
      return category;
    } on FirebaseException catch (error) {
      throw ServerException(
        message: error.message ?? 'Failed to load category',
      );
    }
  }
}
