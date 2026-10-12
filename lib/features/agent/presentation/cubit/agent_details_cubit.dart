import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../estate/domain/repositories/estate_repository.dart';
import '../../domain/repositories/agent_repository.dart';
import 'agent_details_state.dart';

class AgentDetailsCubit extends Cubit<AgentDetailsState> {
  final AgentRepository _agentRepository;
  final EstateRepository _estateRepository;

  AgentDetailsCubit({
    required AgentRepository agentRepository,
    required EstateRepository estateRepository,
  }) : _agentRepository = agentRepository,
       _estateRepository = estateRepository,
       super(const AgentDetailsState());

  Future<void> loadAgentDetails(String agentId) async {
    final normalizedId = agentId.trim();
    if (normalizedId.isEmpty) {
      emit(
        state.copyWith(
          status: AgentDetailsStatus.error,
          error: 'Agent details could not be loaded.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AgentDetailsStatus.loading,
        error: null,
        estatesError: null,
      ),
    );

    final agentResult = await _agentRepository.getAgentById(normalizedId);
    if (agentResult.failure != null || agentResult.data == null) {
      emit(
        state.copyWith(
          status: AgentDetailsStatus.error,
          error: 'Agent details not found.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AgentDetailsStatus.success,
        agent: agentResult.data,
      ),
    );
    await _loadAgentEstates(normalizedId);
  }

  Future<void> _loadAgentEstates(String agentId) async {
    emit(state.copyWith(isEstatesLoading: true, estatesError: null));

    final estatesResult = await _estateRepository.getEstatesByAgentId(agentId);
    if (estatesResult.failure != null) {
      emit(
        state.copyWith(
          isEstatesLoading: false,
          estatesError: estatesResult.failure!.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isEstatesLoading: false,
        estates: estatesResult.data ?? const [],
      ),
    );
  }
}
