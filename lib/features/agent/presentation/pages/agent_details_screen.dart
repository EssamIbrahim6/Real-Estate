import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../../domain/entities/agent_entity.dart';
import '../cubit/agent_details_cubit.dart';
import '../cubit/agent_details_state.dart';

class AgentDetailsScreen extends StatelessWidget {
  final String agentId;

  const AgentDetailsScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n?.agentDetailsTitle ?? 'Agent Details'),
      ),
      body: BlocBuilder<AgentDetailsCubit, AgentDetailsState>(
        builder: (context, state) {
          if (state.status == AgentDetailsStatus.loading) {
            return const AgentDetailsSkeleton();
          }

          if (state.status == AgentDetailsStatus.error || state.agent == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error ??
                      l10n?.commonError ??
                      'Agent details could not be loaded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            );
          }

          final agent = state.agent!;
          final publishedEstatesCount = state.isEstatesLoading
              ? (l10n?.commonLoading ?? 'Loading...')
              : state.estatesError != null
              ? (l10n?.commonError ?? 'Unavailable')
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
                Text(
                  l10n?.agentDetailsPropertiesTitle ?? "Agent's Properties",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                verticalSpace(12),
                if (state.isEstatesLoading)
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, _) => horizontalSpace(12),
                      itemBuilder: (context, index) =>
                          const EstateCardSkeleton(),
                    ),
                  )
                else if (state.estatesError != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.agentDetailsPropertiesError ??
                              'Properties could not be loaded.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<AgentDetailsCubit>()
                              .loadAgentDetails(agentId),
                          child: Text(
                            l10n?.agentDetailsTryAgain ?? 'Try again',
                          ),
                        ),
                      ],
                    ),
                  )
                else if (state.estates.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Text(
                      l10n?.agentDetailsNoProperties ??
                          'This agent has no published properties yet.',
                      style: TextStyle(color: colors.onSurfaceVariant),
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          PersonAvatar(
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (agent.isVerified) ...[
                      horizontalSpace(6),
                      Icon(Icons.verified, color: colors.tertiary, size: 18),
                    ],
                  ],
                ),
                verticalSpace(6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                    horizontalSpace(4),
                    Text(
                      agent.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      '${agent.reviewCount} reviews',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final items = <_InfoRowData>[
      if (agent.phone.trim().isNotEmpty)
        _InfoRowData(
          Icons.phone_outlined,
          l10n?.agentDetailsPhone ?? 'Phone',
          agent.phone,
        ),
      if (agent.email.trim().isNotEmpty)
        _InfoRowData(
          Icons.email_outlined,
          l10n?.agentDetailsEmail ?? 'Email',
          agent.email,
        ),
      if (agent.bio.trim().isNotEmpty)
        _InfoRowData(
          Icons.info_outline,
          l10n?.agentDetailsBio ?? 'Bio',
          agent.bio,
        ),
      _InfoRowData(
        Icons.home_work_outlined,
        l10n?.agentDetailsPublishedEstates ?? 'Published estates',
        publishedEstatesCount,
        isPublishedEstates: true,
      ),
    ];

    if (items.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 18, color: colors.tertiary),
                horizontalSpace(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      verticalSpace(4),
                      Text(
                        item.value,
                        key: item.isPublishedEstates
                            ? const Key('published-estates-count')
                            : null,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface,
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
  final bool isPublishedEstates;

  const _InfoRowData(
    this.icon,
    this.label,
    this.value, {
    this.isPublishedEstates = false,
  });
}
