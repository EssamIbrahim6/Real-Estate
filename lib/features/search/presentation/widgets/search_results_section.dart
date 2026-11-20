import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/search_state.dart';

class SearchResultsSection extends StatelessWidget {
  const SearchResultsSection({
    required this.status,
    required this.estates,
    required this.initialTitle,
    required this.initialHint,
    required this.emptyTitle,
    required this.emptyHint,
    required this.errorMessage,
    required this.onRetry,
    required this.onEstateTap,
    super.key,
  });

  final SearchStatus status;
  final List<EstateEntity> estates;
  final String initialTitle;
  final String initialHint;
  final String emptyTitle;
  final String emptyHint;
  final String errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<EstateEntity> onEstateTap;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SearchStatus.initial:
        return AppEmptyState(
          icon: Icons.search_rounded,
          title: initialTitle,
          description: initialHint,
        );
      case SearchStatus.loading:
        if (estates.isEmpty) {
          return const EstateListSkeleton(itemCount: 4);
        }
        return Stack(
          children: [
            SearchResultsList(estates: estates, onEstateTap: onEstateTap),
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(),
            ),
          ],
        );
      case SearchStatus.failure:
        return AppErrorView(message: errorMessage, onRetry: onRetry);
      case SearchStatus.empty:
        return AppEmptyState(
          icon: Icons.search_off_rounded,
          title: emptyTitle,
          description: emptyHint,
        );
      case SearchStatus.success:
        return SearchResultsList(estates: estates, onEstateTap: onEstateTap);
    }
  }
}

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    required this.estates,
    required this.onEstateTap,
    super.key,
  });

  final List<EstateEntity> estates;
  final ValueChanged<EstateEntity> onEstateTap;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(AppDimensions.p20),
    itemCount: estates.length,
    separatorBuilder: (_, _) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final estate = estates[index];
      return EstateCard(
        estate: estate,
        width: double.infinity,
        onTap: () => onEstateTap(estate),
      );
    },
  );
}
