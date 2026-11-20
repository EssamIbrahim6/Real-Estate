import 'package:equatable/equatable.dart';

import '../../domain/entities/estate_entity.dart';

enum MyPropertiesStatus { initial, loading, success, error }

class MyPropertiesState extends Equatable {
  final MyPropertiesStatus status;
  final List<EstateEntity> properties;
  final String? error;
  final bool isDeleting;
  final String? deletingPropertyId;
  final String? actionFeedback;

  const MyPropertiesState({
    this.status = MyPropertiesStatus.initial,
    this.properties = const [],
    this.error,
    this.isDeleting = false,
    this.deletingPropertyId,
    this.actionFeedback,
  });

  MyPropertiesState copyWith({
    MyPropertiesStatus? status,
    List<EstateEntity>? properties,
    String? error,
    bool clearError = false,
    bool? isDeleting,
    String? deletingPropertyId,
    bool clearDeletingId = false,
    String? actionFeedback,
    bool clearActionFeedback = false,
  }) {
    return MyPropertiesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      error: clearError ? null : (error ?? this.error),
      isDeleting: isDeleting ?? this.isDeleting,
      deletingPropertyId: clearDeletingId
          ? null
          : (deletingPropertyId ?? this.deletingPropertyId),
      actionFeedback: clearActionFeedback
          ? null
          : (actionFeedback ?? this.actionFeedback),
    );
  }

  @override
  List<Object?> get props => [
    status,
    properties,
    error,
    isDeleting,
    deletingPropertyId,
    actionFeedback,
  ];
}
