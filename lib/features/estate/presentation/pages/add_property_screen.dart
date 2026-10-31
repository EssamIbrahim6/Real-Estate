import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/estate_entity.dart';
import '../../domain/repositories/estate_repository.dart';
import '../../../../core/services/notification_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _addressEnController = TextEditingController();
  final _addressArController = TextEditingController();
  final _cityEnController = TextEditingController();
  final _cityArController = TextEditingController();
  final _priceController = TextEditingController();
  final _pricePeriodController = TextEditingController(text: 'monthly');
  final _bedroomsController = TextEditingController(text: '2');
  final _bathroomsController = TextEditingController(text: '1');
  final _areaController = TextEditingController(text: '120');
  final _coverImageController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
  );

  String _listingType = 'rent';
  String _categoryId = 'apartment';
  bool _isFurnished = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'apartment',
    'villa',
    'house',
    'office',
    'studio',
  ];

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    _addressEnController.dispose();
    _addressArController.dispose();
    _cityEnController.dispose();
    _cityArController.dispose();
    _priceController.dispose();
    _pricePeriodController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final titleEn = _titleEnController.text.trim();
    final titleAr = _titleArController.text.trim();
    final descEn = _descEnController.text.trim();
    final descAr = _descArController.text.trim();
    final addressEn = _addressEnController.text.trim();
    final addressAr = _addressArController.text.trim();
    final cityEn = _cityEnController.text.trim();
    final cityAr = _cityArController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final bedrooms = int.tryParse(_bedroomsController.text.trim()) ?? 1;
    final bathrooms = int.tryParse(_bathroomsController.text.trim()) ?? 1;
    final area = double.tryParse(_areaController.text.trim()) ?? 100.0;
    final coverImage = _coverImageController.text.trim();

    final primaryTitle = titleEn.isNotEmpty ? titleEn : titleAr;
    final primaryDesc = descEn.isNotEmpty ? descEn : descAr;
    final primaryAddress = addressEn.isNotEmpty ? addressEn : addressAr;
    final primaryCity = cityEn.isNotEmpty ? cityEn : cityAr;

    final location = EstateLocationEntity(
      address: primaryAddress,
      city: primaryCity,
      addressEn: addressEn.isNotEmpty ? addressEn : null,
      addressAr: addressAr.isNotEmpty ? addressAr : null,
      cityEn: cityEn.isNotEmpty ? cityEn : null,
      cityAr: cityAr.isNotEmpty ? cityAr : null,
      latitude: 30.0444,
      longitude: 31.2357,
    );

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final newEstate = EstateEntity(
      id: '',
      title: primaryTitle,
      description: primaryDesc,
      titleEn: titleEn.isNotEmpty ? titleEn : null,
      titleAr: titleAr.isNotEmpty ? titleAr : null,
      descriptionEn: descEn.isNotEmpty ? descEn : null,
      descriptionAr: descAr.isNotEmpty ? descAr : null,
      price: price,
      pricePeriod: _pricePeriodController.text.trim().isNotEmpty
          ? _pricePeriodController.text.trim()
          : null,
      listingType: _listingType,
      categoryId: _categoryId,
      agentId: currentUid ?? 'agent_admin',
      ownerId: currentUid,
      location: location,
      coverImage: coverImage,
      images: [coverImage],
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      area: area,
      isFurnished: _isFurnished,
      amenities: const ['WiFi', 'Parking', 'Air Conditioning', 'Elevator'],
      rating: 5.0,
      reviewCount: 0,
      isFeatured: true,
      isAvailable: true,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await sl<EstateRepository>().createEstate(newEstate);

    if (!mounted) return;
    setState(() => _isLoading = false);

    final l10n = AppLocalizations.of(context);
    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failure?.message ??
                l10n?.addPropertyError ??
                'Failed to add property',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      if (currentUid != null) {
        sl<NotificationService>().notifyListingPublished(
          estateId: result.data ?? '',
          ownerId: currentUid,
          estateTitle: primaryTitle,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.addPropertySuccess ?? 'Property added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.addPropertyTitle ?? 'Add New Property'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.addPropertySubtitle ??
                      'Enter property details in English and Arabic',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Title Section
                _buildSectionHeader(
                  title: '1. ${l10n?.detailsTitle ?? "Title"}',
                  theme: theme,
                ),
                TextFormField(
                  controller: _titleEnController,
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyTitleEn ?? 'Title (English)',
                    hintText: 'e.g. Modern Apartment in Zamalek',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _titleArController.text.trim().isEmpty) {
                      return l10n?.addPropertyValidationRequired ??
                          'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleArController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyTitleAr ?? 'Title (Arabic)',
                    hintText: 'مثال: شقة حديثة في الزمالك',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _titleEnController.text.trim().isEmpty) {
                      return l10n?.addPropertyValidationRequired ??
                          'هذا الحقل مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description Section
                _buildSectionHeader(
                  title: '2. ${l10n?.detailsDescription ?? "Description"}',
                  theme: theme,
                ),
                TextFormField(
                  controller: _descEnController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.addPropertyDescEn ?? 'Description (English)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _descArController.text.trim().isEmpty) {
                      return l10n?.addPropertyValidationRequired ??
                          'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descArController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.addPropertyDescAr ?? 'Description (Arabic)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _descEnController.text.trim().isEmpty) {
                      return l10n?.addPropertyValidationRequired ??
                          'هذا الحقل مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location Section
                _buildSectionHeader(
                  title: '3. ${l10n?.detailsLocation ?? "Location"}',
                  theme: theme,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityEnController,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyCityEn ?? 'City (English)',
                          hintText: 'Cairo',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cityArController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyCityAr ?? 'City (Arabic)',
                          hintText: 'القاهرة',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressEnController,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyAddressEn ?? 'Address (English)',
                          hintText: 'Zamalek, Cairo',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _addressArController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyAddressAr ?? 'Address (Arabic)',
                          hintText: 'الزمالك، القاهرة',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Financials & Type
                _buildSectionHeader(
                  title: '4. ${l10n?.searchPriceRange ?? "Price & Category"}',
                  theme: theme,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: _textInputKeypadType,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyPrice ?? 'Price (EGP)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n?.addPropertyValidationRequired ??
                                'Required';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return l10n?.addPropertyValidationNumber ??
                                'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pricePeriodController,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyPricePeriod ??
                              'Period (e.g. monthly)',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyCategory ?? 'Category',
                          border: const OutlineInputBorder(),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat[0].toUpperCase() + cat.substring(1)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _categoryId = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _listingType,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyListingType ?? 'Listing Type',
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'rent',
                            child: Text(l10n?.searchForRent ?? 'Rent'),
                          ),
                          DropdownMenuItem(
                            value: 'sale',
                            child: Text(l10n?.searchForSale ?? 'Sale'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _listingType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Details (Bedrooms, Bathrooms, Area)
                _buildSectionHeader(
                  title: '5. ${l10n?.searchPropertyType ?? "Property Specs"}',
                  theme: theme,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyBedrooms ?? 'Bedrooms',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyBathrooms ?? 'Bathrooms',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyArea ?? 'Area (sqm)',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n?.addPropertyFurnished ?? 'Furnished'),
                  value: _isFurnished,
                  onChanged: (val) => setState(() => _isFurnished = val),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coverImageController,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.addPropertyCoverImage ?? 'Cover Image URL',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton(
                  onPressed: _isLoading ? null : _submitProperty,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n?.addPropertySubmit ?? 'Publish Listing',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const TextInputType _textInputKeypadType =
      TextInputType.numberWithOptions(decimal: true);

  Widget _buildSectionHeader({
    required String title,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

