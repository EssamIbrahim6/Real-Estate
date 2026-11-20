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
  Future<List<EstateModel>> getEstatesByAgentId(String agentId);
  Future<String> createEstate(EstateModel estate);
  Future<List<EstateModel>> getEstatesByOwnerId(String ownerId);
  Future<void> deleteEstate({
    required String estateId,
    required String currentUid,
  });
}

class EstateRemoteDataSourceImpl implements EstateRemoteDataSource {
  final FirebaseFirestore _firestore;

  const EstateRemoteDataSourceImpl(this._firestore);

  @override
  Future<String> createEstate(EstateModel estate) async {
    try {
      final data = estate.toFirestore();
      if (estate.id.isNotEmpty) {
        await _firestore.collection('estates').doc(estate.id).set(data);
        return estate.id;
      } else {
        final docRef = await _firestore.collection('estates').add(data);
        return docRef.id;
      }
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create estate');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

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
  Future<List<EstateModel>> getEstatesByAgentId(String agentId) async {
    final trimmedAgentId = agentId.trim();
    if (trimmedAgentId.isEmpty) return const [];

    try {
      final snapshot = await _firestore
          .collection('estates')
          .where('agentId', isEqualTo: trimmedAgentId)
          .get();

      return snapshot.docs
          .map((doc) => EstateModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to load agent estates',
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

  @override
  Future<List<EstateModel>> getEstatesByOwnerId(String ownerId) async {
    final trimmed = ownerId.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final resultsMap = <String, EstateModel>{};

      // Query by ownerId
      final qOwner = await _firestore
          .collection('estates')
          .where('ownerId', isEqualTo: trimmed)
          .get();
      for (final doc in qOwner.docs) {
        resultsMap[doc.id] = EstateModel.fromFirestore(doc);
      }

      // Query by createdBy
      final qCreated = await _firestore
          .collection('estates')
          .where('createdBy', isEqualTo: trimmed)
          .get();
      for (final doc in qCreated.docs) {
        resultsMap[doc.id] = EstateModel.fromFirestore(doc);
      }

      // Query by userId
      final qUser = await _firestore
          .collection('estates')
          .where('userId', isEqualTo: trimmed)
          .get();
      for (final doc in qUser.docs) {
        resultsMap[doc.id] = EstateModel.fromFirestore(doc);
      }

      // Query by agentId
      final qAgent = await _firestore
          .collection('estates')
          .where('agentId', isEqualTo: trimmed)
          .get();
      for (final doc in qAgent.docs) {
        resultsMap[doc.id] = EstateModel.fromFirestore(doc);
      }

      final list = resultsMap.values.toList();
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return list;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load your properties');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteEstate({
    required String estateId,
    required String currentUid,
  }) async {
    final trimmedId = estateId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Estate ID is required.');
    }
    final trimmedUid = currentUid.trim();
    if (trimmedUid.isEmpty) {
      throw ArgumentError('User ID is required.');
    }

    try {
      final docRef = _firestore.collection('estates').doc(trimmedId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final estate = EstateModel.fromFirestore(doc);
      final owner = estate.primaryOwnerUid;
      if (owner != null && owner != trimmedUid && estate.agentId != trimmedUid) {
        throw const ServerException(
          message: 'You are not authorized to delete this property listing.',
        );
      }

      await docRef.delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete property');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
