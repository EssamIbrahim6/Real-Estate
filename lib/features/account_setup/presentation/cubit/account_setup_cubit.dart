import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/save_account_setup_usecase.dart';
import 'account_setup_state.dart';

class AccountSetupCubit extends Cubit<AccountSetupState> {
  final SaveAccountSetupUseCase _saveUseCase;
  final FirebaseAuth _firebaseAuth;
  final ImagePicker _imagePicker;

  AccountSetupCubit({
    required SaveAccountSetupUseCase saveUseCase,
    required FirebaseAuth firebaseAuth,
    ImagePicker? imagePicker,
  }) : _saveUseCase = saveUseCase,
       _firebaseAuth = firebaseAuth,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const AccountSetupInitial(AccountSetupData())) {
    _initPrefill();
  }

  void _initPrefill() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(
        AccountSetupInProgress(
          state.data.copyWith(
            email: user.email ?? '',
            name: user.displayName ?? '',
          ),
        ),
      );
    }
  }

  // ── Step 1: Location & GPS ────────────────────────────────────────────────

  Future<void> requestCurrentLocation() async {
    emit(AccountSetupLocating(state.data));

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          AccountSetupFailure(
            state.data,
            'Location services are disabled on your device.',
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(
            AccountSetupFailure(state.data, 'Location permission was denied.'),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          AccountSetupFailure(
            state.data,
            'Location permissions are permanently denied. Please enable them in system settings.',
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await updateCoordinates(position.latitude, position.longitude);
    } catch (e) {
      emit(AccountSetupFailure(state.data, 'Failed to acquire location: $e'));
    }
  }

  Future<void> updateCoordinates(double lat, double lng) async {
    String address = 'Selected Location';

    try {
      final geocoding = Geocoding();

      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts =
            <String?>[
                  p.street,
                  p.subLocality,
                  p.locality,
                  p.administrativeArea,
                  p.country,
                ]
                .whereType<String>()
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toSet()
                .toList();

        if (parts.isNotEmpty) {
          address = parts.join(', ');
        }
      }
    } catch (_) {
      address =
          'Lat: ${lat.toStringAsFixed(4)}, '
          'Lng: ${lng.toStringAsFixed(4)}';
    }

    final newLocation = LocationData(
      latitude: lat,
      longitude: lng,
      address: address,
    );

    emit(AccountSetupInProgress(state.data.copyWith(location: newLocation)));
  }
  // ── Step 2: Real Estate Preferences ──────────────────────────────────────

  void togglePropertyType(RealEstateType type) {
    final list = List<RealEstateType>.from(state.data.preferredTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    emit(AccountSetupInProgress(state.data.copyWith(preferredTypes: list)));
  }

  // ── Step 3: Payment Method ────────────────────────────────────────────────

  void selectPaymentMethod(PaymentPreference method) {
    emit(AccountSetupInProgress(state.data.copyWith(paymentMethod: method)));
  }

  // ── Step 4: Personal Info & Image ─────────────────────────────────────────

  Future<void> pickProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        emit(
          AccountSetupInProgress(
            state.data.copyWith(localImagePath: picked.path),
          ),
        );
      }
    } catch (e) {
      emit(AccountSetupFailure(state.data, 'Failed to pick image: $e'));
    }
  }

  void updateName(String name) =>
      emit(AccountSetupInProgress(state.data.copyWith(name: name)));
  void updatePhone(String phone) =>
      emit(AccountSetupInProgress(state.data.copyWith(phone: phone)));
  void updateEmail(String email) =>
      emit(AccountSetupInProgress(state.data.copyWith(email: email)));

  // ── Step 5: Save & Finish ─────────────────────────────────────────────────

  Future<void> finishSetup() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(
        AccountSetupFailure(state.data, 'No authenticated user session found.'),
      );
      return;
    }

    if (state.data.name.trim().isEmpty) {
      emit(AccountSetupFailure(state.data, 'Please enter your full name.'));
      return;
    }

    emit(AccountSetupLoading(state.data));

    final profile = UserProfileEntity(
      userId: user.uid,
      name: state.data.name.trim(),
      email: state.data.email.trim().isNotEmpty
          ? state.data.email.trim()
          : (user.email ?? ''),
      phone: state.data.phone.trim(),
      profileImageUrl: state.data.uploadedImageUrl,
      location: state.data.location,
      preferredRealEstateTypes: state.data.preferredTypes,
      paymentMethod: state.data.paymentMethod,
      accountSetupCompleted: true,
    );

    final result = await _saveUseCase(
      SaveAccountSetupParams(
        profile: profile,
        localImagePath: state.data.localImagePath,
      ),
    );

    if (result.failure != null) {
      emit(AccountSetupFailure(state.data, result.failure!.message));
    } else {
      emit(AccountSetupSuccess(state.data));
    }
  }
}
