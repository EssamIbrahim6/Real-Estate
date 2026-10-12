import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile_entity.dart';

class AccountSetupData extends Equatable {
  final LocationData? location;
  final List<RealEstateType> preferredTypes;
  final PaymentPreference? paymentMethod;
  final String name;
  final String phone;
  final String email;
  final String? localImagePath;
  final String? uploadedImageUrl;

  const AccountSetupData({
    this.location,
    this.preferredTypes = const [],
    this.paymentMethod,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.localImagePath,
    this.uploadedImageUrl,
  });

  AccountSetupData copyWith({
    LocationData? location,
    List<RealEstateType>? preferredTypes,
    PaymentPreference? paymentMethod,
    String? name,
    String? phone,
    String? email,
    String? localImagePath,
    String? uploadedImageUrl,
  }) {
    return AccountSetupData(
      location: location ?? this.location,
      preferredTypes: preferredTypes ?? this.preferredTypes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      localImagePath: localImagePath ?? this.localImagePath,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }

  @override
  List<Object?> get props => [
    location,
    preferredTypes,
    paymentMethod,
    name,
    phone,
    email,
    localImagePath,
    uploadedImageUrl,
  ];
}

abstract class AccountSetupState extends Equatable {
  final AccountSetupData data;
  const AccountSetupState(this.data);

  @override
  List<Object?> get props => [data];
}

class AccountSetupInitial extends AccountSetupState {
  const AccountSetupInitial(super.data);
}

class AccountSetupInProgress extends AccountSetupState {
  const AccountSetupInProgress(super.data);
}

class AccountSetupLocating extends AccountSetupState {
  const AccountSetupLocating(super.data);
}

class AccountSetupLoading extends AccountSetupState {
  final String message;
  const AccountSetupLoading(
    super.data, {
    this.message = 'Saving account setup...',
  });

  @override
  List<Object?> get props => [data, message];
}

class AccountSetupSuccess extends AccountSetupState {
  const AccountSetupSuccess(super.data);
}

class AccountSetupFailure extends AccountSetupState {
  final String message;
  const AccountSetupFailure(super.data, this.message);

  @override
  List<Object?> get props => [data, message];
}
