import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../../domain/entities/agent_entity.dart';
import '../widgets/agent_avatar.dart';
import '../cubit/agent_details_cubit.dart';
import '../cubit/agent_details_state.dart';

class AgentDetailsScreen extends StatelessWidget {
  final String agentId;

  const AgentDetailsScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brandNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Agent Details',
          style: TextStyle(
            color: AppColors.brandNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<AgentDetailsCubit, AgentDetailsState>(
        builder: (context, state) {
          if (state.status == AgentDetailsStatus.loading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state.status == AgentDetailsStatus.error || state.agent == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error ?? 'Agent details could not be loaded.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          final agent = state.agent!;
          final publishedEstatesCount = state.isEstatesLoading
              ? 'Loading...'
              : state.estatesError != null
              ? 'Unavailable'
              : state.estates.length.toString();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AgentHeader(agent: agent),
                verticalSpace(20),
                _InfoCard(
                  agent: agent,
                  publishedEstatesCount: publishedEstatesCount,
                ),
                verticalSpace(24),
                const Text(
                  "Agent's Properties",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandNavy,
                  ),
                ),
                verticalSpace(12),
                if (state.isEstatesLoading)
                  const Center(child: AppLoadingIndicator())
                else if (state.estatesError != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Properties could not be loaded.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<AgentDetailsCubit>()
                              .loadAgentDetails(agentId),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                else if (state.estates.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: const Text(
                      'This agent has no published properties yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.estates.length,
                      separatorBuilder: (_, _) => horizontalSpace(12),
                      itemBuilder: (context, index) {
                        final estate = state.estates[index];
                        return SizedBox(
                          width: 240,
                          child: EstateCard(
                            estate: estate,
                            width: 240,
                            onTap: () => context.pushNamed(
                              AppRoutes.propertyDetailsName,
                              pathParameters: {'estateId': estate.id},
                              extra: estate,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AgentHeader extends StatelessWidget {
  final AgentEntity agent;

  const _AgentHeader({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          AgentAvatar(
            photoUrl: agent.primaryPhotoUrl,
            radius: 42,
            iconSize: 40,
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        agent.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandNavy,
                        ),
                      ),
                    ),
                    if (agent.isVerified) ...[
                      horizontalSpace(6),
                      const Icon(
                        Icons.verified,
                        color: AppColors.brandGreen,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                verticalSpace(6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    horizontalSpace(4),
                    Text(
                      agent.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      '${agent.reviewCount} reviews',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AgentEntity agent;
  final String publishedEstatesCount;

  const _InfoCard({required this.agent, required this.publishedEstatesCount});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoRowData>[
      if (agent.phone.trim().isNotEmpty)
        _InfoRowData(Icons.phone_outlined, 'Phone', agent.phone),
      if (agent.email.trim().isNotEmpty)
        _InfoRowData(Icons.email_outlined, 'Email', agent.email),
      if (agent.bio.trim().isNotEmpty)
        _InfoRowData(Icons.info_outline, 'Bio', agent.bio),
      _InfoRowData(
        Icons.home_work_outlined,
        'Published estates',
        publishedEstatesCount,
      ),
    ];

    if (items.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 18, color: AppColors.brandGreen),
                horizontalSpace(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      verticalSpace(4),
                      Text(
                        item.value,
                        key: item.label == 'Published estates'
                            ? const Key('published-estates-count')
                            : null,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.brandNavy,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRowData(this.icon, this.label, this.value);
}
