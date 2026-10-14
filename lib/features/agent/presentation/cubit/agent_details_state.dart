import 'package:equatable/equatable.dart';

import '../../../estate/domain/entities/estate_entity.dart';
import '../../domain/entities/agent_entity.dart';

enum AgentDetailsStatus { initial, loading, success, error }

class AgentDetailsState extends Equatable {
  final AgentDetailsStatus status;
  final AgentEntity? agent;
  final List<EstateEntity> estates;
  final bool isEstatesLoading;
  final String? error;
  final String? estatesError;

  const AgentDetailsState({
    this.status = AgentDetailsStatus.initial,
    this.agent,
    this.estates = const [],
    this.isEstatesLoading = false,
    this.error,
    this.estatesError,
  });

  AgentDetailsState copyWith({
    AgentDetailsStatus? status,
    AgentEntity? agent,
    List<EstateEntity>? estates,
    bool? isEstatesLoading,
    String? error,
    String? estatesError,
  }) {
    return AgentDetailsState(
      status: status ?? this.status,
      agent: agent ?? this.agent,
      estates: estates ?? this.estates,
      isEstatesLoading: isEstatesLoading ?? this.isEstatesLoading,
      error: error,
      estatesError: estatesError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    agent,
    estates,
    isEstatesLoading,
    error,
    estatesError,
  ];
}
