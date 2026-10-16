import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../../domain/entities/search_filter.dart';
import '../widgets/search_filter_sheet.dart';
import '../../../map/domain/models/map_screen_args.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();

  /// Debounce timer for live search — fires ~350 ms after the user stops typing.
  Timer? _debounceTimer;

  /// How long to wait after the last keystroke before issuing a search.
  static const _debounceDuration = Duration(milliseconds: 350);
  bool _suppressQuerySearch = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SearchCubit>();
    cubit.loadCategories();
    // Load initial results with the current (empty) filter.
    cubit.search(cubit.state.filter);
    // Wire live search: every keystroke resets the debounce timer.
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _queryController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    // Rebuild to show/hide the clear button immediately.
    setState(() {});
    if (_suppressQuerySearch) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _runSearch);
  }

  Future<void> _runSearch() async {
    _debounceTimer?.cancel();
    if (!mounted) return;
    final current = context.read<SearchCubit>().state.filter;
    final rawQuery = _queryController.text.trim();
    await context.read<SearchCubit>().search(
      SearchFilter(
        query: rawQuery.isEmpty ? null : rawQuery,
        categoryId: current.categoryId,
        city: current.city,
        minPrice: current.minPrice,
        maxPrice: current.maxPrice,
        bedrooms: current.bedrooms,
        bathrooms: current.bathrooms,
        isFurnished: current.isFurnished,
        listingType: current.listingType,
        isAvailable: current.isAvailable,
      ),
    );
  }

  Future<void> _openFilters(SearchState state) async {
    final currentFilter = state.filter;
    final filter = await showModalBottomSheet<SearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => SearchFilterSheet(
        initialFilter: SearchFilter(
          query: _queryController.text.trim().isEmpty
              ? null
              : _queryController.text.trim(),
          categoryId: currentFilter.categoryId,
          city: currentFilter.city,
          minPrice: currentFilter.minPrice,
          maxPrice: currentFilter.maxPrice,
          bedrooms: currentFilter.bedrooms,
          bathrooms: currentFilter.bathrooms,
          isFurnished: currentFilter.isFurnished,
          listingType: currentFilter.listingType,
          isAvailable: currentFilter.isAvailable,
        ),
        categories: state.categories,
      ),
    );
    if (!mounted || filter == null) return;
    // Cancel any pending debounce — the filter sheet already sets a full filter.
    _debounceTimer?.cancel();
    _suppressQuerySearch = true;
    _queryController.text = filter.query ?? '';
    _suppressQuerySearch = false;
    await context.read<SearchCubit>().search(filter);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.searchTitle ?? 'Search properties'),
        actions: [
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) => IconButton(
              tooltip: l10n?.searchViewOnMap ?? 'View on map',
              icon: const Icon(Icons.map_outlined),
              onPressed: () {
                context.push(
                  AppRoutes.map,
                  extra: MapScreenArgs(
                    estates: state.estates,
                    title: l10n?.mapSearchTitle ?? 'Search Map',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.p20,
              12,
              AppDimensions.p20,
              8,
            ),
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      // onChanged is handled by the listener added in initState.
                      // onSubmitted fires an immediate search (bypassing debounce).
                      onSubmitted: (_) {
                        _debounceTimer?.cancel();
                        _runSearch();
                      },
                      decoration: InputDecoration(
                        hintText: l10n?.searchHint ?? 'Search estates…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_queryController.text.isNotEmpty)
                              IconButton(
                                tooltip: l10n?.commonClear ?? 'Clear search',
                                onPressed: () {
                                  _debounceTimer?.cancel();
                                  _queryController.clear();
                                  // Clear runs the search immediately.
                                  _runSearch();
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            IconButton(
                              tooltip: l10n?.commonSearch ?? 'Search',
                              onPressed: () {
                                _debounceTimer?.cancel();
                                _runSearch();
                              },
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                          ],
                        ),
                        filled: true,
                        fillColor: colors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: l10n?.searchFilters ?? 'Filters',
                    onPressed: () => _openFilters(state),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                switch (state.status) {
                  case SearchStatus.initial:
                  case SearchStatus.loading:
                    if (state.estates.isEmpty) {
                      return const EstateListSkeleton(itemCount: 4);
                    }
                    return Stack(
                      children: [
                        _SearchResults(estates: state.estates),
                        const Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(),
                        ),
                      ],
                    );
                  case SearchStatus.failure:
                    return AppErrorView(
                      message:
                          state.failure?.message ??
                          l10n?.homeLoadError ??
                          'Search could not be completed.',
                      onRetry: () => context.read<SearchCubit>().retry(),
                    );
                  case SearchStatus.empty:
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.p20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n?.searchNoResults ?? 'No estates found',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n?.searchNoResultsHint ??
                                  'Try changing your search or filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    );
                  case SearchStatus.success:
                    return _SearchResults(estates: state.estates);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<EstateEntity> estates;

  const _SearchResults({required this.estates});

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
        onTap: () => context.push(
          '${AppRoutes.propertyDetails}/${estate.id}',
          extra: estate,
        ),
      );
    },
  );
}
