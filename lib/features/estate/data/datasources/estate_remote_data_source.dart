import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/estate_model.dart';

abstract class EstateRemoteDataSource {
  Future<List<EstateModel>> getFeaturedEstates();
  Future<EstateModel> getEstateById(String id);
  Future<List<EstateModel>> getEstates({
    String? categoryId,
    String? city,
    int? limit,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    bool? isFurnished,
    String? listingType,
    bool? isAvailable,
  });
}

class EstateRemoteDataSourceImpl implements EstateRemoteDataSource {
  final FirebaseFirestore _firestore;

  const EstateRemoteDataSourceImpl(this._firestore);

  // In abstract class EstateRemoteDataSource:

  // In EstateRemoteDataSourceImpl:
  @override
  Future<EstateModel> getEstateById(String id) async {
    try {
      final doc = await _firestore.collection('estates').doc(id).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Estate not found');
      }
      return EstateModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load estate');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EstateModel>> getFeaturedEstates() async {
    try {
      final snapshot = await _firestore
          .collection('estates')
          .where('isFeatured', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => EstateModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load featured estates',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EstateModel>> getEstates({
    String? categoryId,
    String? city,
    int? limit,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    bool? isFurnished,
    String? listingType,
    bool? isAvailable,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('estates');

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      if (city != null && city.isNotEmpty) {
        query = query.where('location.city', isEqualTo: city);
      }

      if (listingType != null && listingType.isNotEmpty) {
        query = query.where('listingType', isEqualTo: listingType);
      }

      if (isFurnished != null) {
        query = query.where('isFurnished', isEqualTo: isFurnished);
      }

      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (bedrooms != null) {
        query = query.where('bedrooms', isEqualTo: bedrooms);
      }

      if (bathrooms != null) {
        query = query.where('bathrooms', isEqualTo: bathrooms);
      }

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => EstateModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load estates');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
