import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/search_filter.dart';

class SearchFilterSheet extends StatefulWidget {
  final SearchFilter initialFilter;
  final List<CategoryEntity> categories;

  const SearchFilterSheet({
    super.key,
    required this.initialFilter,
    required this.categories,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cityController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late String? _categoryId;
  late String? _listingType;
  late bool? _isFurnished;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(
      text: widget.initialFilter.city ?? '',
    );
    _minPriceController = TextEditingController(
      text: widget.initialFilter.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialFilter.maxPrice?.toString() ?? '',
    );
    _bedroomsController = TextEditingController(
      text: widget.initialFilter.bedrooms?.toString() ?? '',
    );
    _bathroomsController = TextEditingController(
      text: widget.initialFilter.bathrooms?.toString() ?? '',
    );
    _categoryId = widget.initialFilter.categoryId;
    _listingType = widget.initialFilter.listingType;
    _isFurnished = widget.initialFilter.isFurnished;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;

    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      AppFeedback.error(
        context,
        'Minimum price must not exceed maximum price.',
      );
      return;
    }

    Navigator.of(context).pop(
      SearchFilter(
        query: widget.initialFilter.query,
        categoryId: _categoryId,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: int.tryParse(_bedroomsController.text.trim()),
        bathrooms: int.tryParse(_bathroomsController.text.trim()),
        isFurnished: _isFurnished,
        listingType: _listingType,
        isAvailable: widget.initialFilter.isAvailable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.inputBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.searchFilters ?? 'Search filters',
                        style: const TextStyle(
                          color: AppColors.brandNavy,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .pop(widget.initialFilter.clearFilters()),
                      child: Text(l10n?.searchClearFilters ?? 'Clear Filters'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId ?? '',
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyCategory ?? 'Category',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(l10n?.searchAny ?? 'All categories'),
                    ),
                    if (_categoryId != null &&
                        !widget.categories.any(
                          (category) => category.id == _categoryId,
                        ))
                      DropdownMenuItem<String>(
                        value: _categoryId,
                        child: Text(l10n?.searchAny ?? 'Selected category'),
                      ),
                    ...widget.categories.map(
                      (category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _categoryId = value == null || value.isEmpty
                        ? null
                        : value,
                  ),
                ),
                if (widget.categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n?.homeNoFeatured ?? 'Categories are currently unavailable.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyCityEn ?? 'City',
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _minPriceController,
                        label: l10n?.searchMinPrice ?? 'Minimum price',
                        decimal: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _maxPriceController,
                        label: l10n?.searchMaxPrice ?? 'Maximum price',
                        decimal: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _bedroomsController,
                        label: l10n?.searchBedrooms ?? 'Bedrooms',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: _bathroomsController,
                        label: l10n?.searchBathrooms ?? 'Bathrooms',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _listingType ?? '',
                  decoration: InputDecoration(
                    labelText: l10n?.searchListingType ?? 'Listing type',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(l10n?.searchAny ?? 'Sale or rent'),
                    ),
                    DropdownMenuItem(
                      value: 'sale',
                      child: Text(l10n?.searchForSale ?? 'For sale'),
                    ),
                    DropdownMenuItem(
                      value: 'rent',
                      child: Text(l10n?.searchForRent ?? 'For rent'),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _listingType = value == null || value.isEmpty
                        ? null
                        : value,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _isFurnished == null
                      ? 'any'
                      : _isFurnished!
                      ? 'furnished'
                      : 'unfurnished',
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyFurnished ?? 'Furnished',
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'any',
                      child: Text(l10n?.searchAny ?? 'Any'),
                    ),
                    DropdownMenuItem(
                      value: 'furnished',
                      child: Text(l10n?.detailsFurnished ?? 'Furnished'),
                    ),
                    DropdownMenuItem(
                      value: 'unfurnished',
                      child: Text(l10n?.detailsUnfurnished ?? 'Unfurnished'),
                    ),
                  ],
                  onChanged: (value) => setState(
                    () => _isFurnished = switch (value) {
                      'furnished' => true,
                      'unfurnished' => false,
                      _ => null,
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(l10n?.searchApplyFilters ?? 'Apply filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    bool decimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return null;
        final parsed = decimal ? double.tryParse(text) : int.tryParse(text);
        if (parsed == null || parsed < 0) {
          return decimal ? 'Enter a valid price' : 'Enter a whole number';
        }
        return null;
      },
    );
  }
}
