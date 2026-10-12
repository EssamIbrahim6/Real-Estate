import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../models/user_profile_model.dart';

abstract class AccountSetupRemoteDataSource {
  Future<UserProfileModel> saveProfile(
    UserProfileModel model, {
    String? localImagePath,
  });
  Future<UserProfileModel> getProfile(String userId);
}

class AccountSetupRemoteDataSourceImpl implements AccountSetupRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  const AccountSetupRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CloudinaryService cloudinaryService,
  }) : _firestore = firestore,
       _cloudinaryService = cloudinaryService;

  @override
  Future<UserProfileModel> saveProfile(
    UserProfileModel model, {
    String? localImagePath,
  }) async {
    try {
      String? imageUrl = model.profileImageUrl;

      // Upload profile image to Cloudinary if a local file was picked
      if (localImagePath != null && localImagePath.isNotEmpty) {
        try {
          imageUrl = await _cloudinaryService.uploadImage(File(localImagePath));
        } catch (_) {
          // If Cloudinary is not configured yet, continue saving the rest of the profile
          imageUrl = null;
        }
      }
      // Upload profile image to Cloudinary if a local file was picked

      final updatedModel = UserProfileModel(
        userId: model.userId,
        name: model.name,
        email: model.email,
        phone: model.phone,
        profileImageUrl: imageUrl,
        location: model.location,
        preferredRealEstateTypes: model.preferredRealEstateTypes,
        paymentMethod: model.paymentMethod,
        accountSetupCompleted: true,
      );

      // Merge into Firestore users collection without overwriting unrelated fields
      await _firestore
          .collection('users')
          .doc(model.userId)
          .set(updatedModel.toFirestore(), SetOptions(merge: true));

      return updatedModel;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error occurred');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw const ServerException(
          message: 'User profile not found in Firestore',
        );
      }
      return UserProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore query failed');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
