import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../category/presentation/utils/category_icon_helper.dart';
import '../../domain/entities/estate_entity.dart';
import '../../domain/entities/property_location_selection.dart';
import '../../domain/repositories/estate_repository.dart';
import 'property_location_picker_screen.dart';

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
  final _customImageUrlController = TextEditingController();

  String _listingType = 'rent';
  String _categoryId = 'apartment';
  bool _isFurnished = true;
  bool _isLoading = false;
  PropertyLocationSelection? _selectedLocation;

  final List<String> _categories = [
    'apartment',
    'villa',
    'house',
    'office',
    'studio',
    'commercial',
    'townhouse',
    'penthouse',
    'chalet',
  ];

  final Set<String> _selectedAmenities = {
    'WiFi',
    'Parking',
    'Air Conditioning',
    'Elevator',
  };

  final List<String> _availableAmenities = [
    'WiFi',
    'Parking',
    'Air Conditioning',
    'Elevator',
    'Swimming Pool',
    'Garden',
    'Gym',
    'Security',
    'Balcony',
  ];

  /// List of image URLs or local file paths
  final List<String> _images = [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
  ];
  int _coverImageIndex = 0;

  final ImagePicker _picker = ImagePicker();

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
    _customImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final file in pickedFiles) {
            if (!_images.contains(file.path)) {
              _images.add(file.path);
            }
          }
        });
      }
    } catch (_) {
      // Safely ignore pick cancellation
    }
  }

  void _addCustomImageUrl() {
    final url = _customImageUrlController.text.trim();
    if (url.isNotEmpty && !_images.contains(url)) {
      setState(() {
        _images.add(url);
        _customImageUrlController.clear();
      });
    }
  }

  void _removeImage(int index) {
    if (_images.length <= 1) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context)?.myPropertiesMinImagesError ??
            'At least one image is required.',
      );
      return;
    }
    setState(() {
      _images.removeAt(index);
      if (_coverImageIndex >= _images.length) {
        _coverImageIndex = 0;
      }
    });
  }

  Future<void> _selectPropertyLocation() async {
    final selection = await Navigator.of(context)
        .push<PropertyLocationSelection>(
          MaterialPageRoute(
            builder: (_) => PropertyLocationPickerScreen(
              initialSelection: _selectedLocation,
            ),
          ),
        );
    if (!mounted || selection == null) return;
    if (!selection.isValid) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context)?.myPropertiesLocationRequired ??
            'Select a valid property location.',
      );
      return;
    }

    setState(() {
      _selectedLocation = selection;
      final city = selection.city;
      final address = selection.address;
      if (city != null && city.isNotEmpty) {
        if (Localizations.localeOf(context).languageCode == 'ar') {
          _cityArController.text = city;
        } else {
          _cityEnController.text = city;
        }
      }
      if (address != null && address.isNotEmpty) {
        if (Localizations.localeOf(context).languageCode == 'ar') {
          _addressArController.text = address;
        } else {
          _addressEnController.text = address;
        }
      }
    });
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedLocation = _selectedLocation;
    if (selectedLocation == null || !selectedLocation.isValid) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context)?.myPropertiesLocationRequired ??
            'Select a valid property location.',
      );
      return;
    }

    if (_images.isEmpty) {
      AppFeedback.error(
        context,
        AppLocalizations.of(context)?.myPropertiesMinImagesError ??
            'Please select at least one property image.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );

      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      // Handle any local image uploads if necessary
      final uploadedUrls = <String>[];
      for (int i = 0; i < _images.length; i++) {
        final pathOrUrl = _images[i];
        if (pathOrUrl.startsWith('http://') ||
            pathOrUrl.startsWith('https://')) {
          uploadedUrls.add(pathOrUrl);
        } else if (!kIsWeb && File(pathOrUrl).existsSync()) {
          try {
            final fileName =
                'estates/${currentUid ?? "user"}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
            final ref = FirebaseStorage.instance.ref().child(fileName);
            final uploadTask = await ref.putFile(File(pathOrUrl));
            final downloadUrl = await uploadTask.ref.getDownloadURL();
            uploadedUrls.add(downloadUrl);
          } catch (_) {
            // Fallback placeholder if storage is unavailable on spark
            uploadedUrls.add(
              'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
            );
          }
        } else {
          uploadedUrls.add(pathOrUrl);
        }
      }

      final coverUrl = uploadedUrls.isNotEmpty
          ? (_coverImageIndex < uploadedUrls.length
                ? uploadedUrls[_coverImageIndex]
                : uploadedUrls.first)
          : '';

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
        coverImage: coverUrl,
        images: uploadedUrls,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        area: area,
        isFurnished: _isFurnished,
        amenities: _selectedAmenities.toList(),
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
        AppFeedback.error(
          context,
          result.failure?.message ??
              l10n?.addPropertyError ??
              'Failed to add property',
        );
      } else {
        if (currentUid != null) {
          sl<NotificationService>().notifyListingPublished(
            estateId: result.data ?? '',
            ownerId: currentUid,
            estateTitle: primaryTitle,
          );
        }
        AppFeedback.success(
          context,
          l10n?.addPropertySuccess ?? 'Property published successfully!',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppFeedback.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.addPropertyTitle ?? 'Add New Property'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.addPropertySubtitle ??
                      'Enter property details in English and Arabic',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                verticalSpace(20),

                // 1. Image Management
                _buildSectionHeader(
                  title:
                      '1. ${l10n?.myPropertiesPickImages ?? "Property Images"}',
                  theme: theme,
                ),
                _buildImageManager(colors),
                verticalSpace(24),

                // 2. Title Section
                _buildSectionHeader(
                  title: '2. ${l10n?.detailsTitle ?? "Title"}',
                  theme: theme,
                ),
                TextFormField(
                  controller: _titleEnController,
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyTitleEn ?? 'Title (English)',
                    hintText: 'e.g. Modern Apartment in Zamalek',
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
                verticalSpace(12),
                TextFormField(
                  controller: _titleArController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyTitleAr ?? 'Title (Arabic)',
                    hintText: 'مثال: شقة حديثة في الزمالك',
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
                verticalSpace(24),

                // 3. Description Section
                _buildSectionHeader(
                  title: '3. ${l10n?.detailsDescription ?? "Description"}',
                  theme: theme,
                ),
                TextFormField(
                  controller: _descEnController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.addPropertyDescEn ?? 'Description (English)',
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
                verticalSpace(12),
                TextFormField(
                  controller: _descArController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.addPropertyDescAr ?? 'Description (Arabic)',
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
                verticalSpace(24),

                // 4. Category & Type
                _buildSectionHeader(
                  title:
                      '4. ${l10n?.homeCategories ?? "Category & Listing Type"}',
                  theme: theme,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: InputDecoration(
                    labelText: l10n?.addPropertyCategory ?? 'Category',
                  ),
                  items: _categories.map((cat) {
                    final icon = CategoryIconHelper.getIcon(cat);
                    final name = CategoryIconHelper.getLocalizedName(
                      context,
                      cat,
                    );
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: colors.primary),
                          horizontalSpace(10),
                          Text(name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _categoryId = val);
                  },
                ),
                verticalSpace(12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(l10n?.searchForRent ?? 'For Rent'),
                        ),
                        selected: _listingType == 'rent',
                        onSelected: (val) {
                          if (val) setState(() => _listingType = 'rent');
                        },
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(l10n?.searchForSale ?? 'For Sale'),
                        ),
                        selected: _listingType == 'sale',
                        onSelected: (val) {
                          if (val) setState(() => _listingType = 'sale');
                        },
                      ),
                    ),
                  ],
                ),
                verticalSpace(24),

                // 5. Price & Specs
                _buildSectionHeader(
                  title:
                      '5. ${l10n?.searchPriceRange ?? "Price & Specifications"}',
                  theme: theme,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: _textInputKeypadType,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyPrice ?? 'Price (EGP)',
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
                    horizontalSpace(12),
                    Expanded(
                      child: TextFormField(
                        controller: _pricePeriodController,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyPricePeriod ??
                              'Period (e.g. monthly)',
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyBedrooms ?? 'Bedrooms',
                        ),
                      ),
                    ),
                    horizontalSpace(8),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyBathrooms ?? 'Bathrooms',
                        ),
                      ),
                    ),
                    horizontalSpace(8),
                    Expanded(
                      child: TextFormField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyArea ?? 'Area (sqm)',
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n?.addPropertyFurnished ?? 'Furnished'),
                  value: _isFurnished,
                  onChanged: (val) => setState(() => _isFurnished = val),
                ),
                verticalSpace(16),

                // Amenities
                Text(
                  'Amenities',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                verticalSpace(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableAmenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                verticalSpace(24),

                // 6. Location Section
                _buildSectionHeader(
                  title: '6. ${l10n?.detailsLocation ?? "Location"}',
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
                        ),
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: TextFormField(
                        controller: _cityArController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: l10n?.addPropertyCityAr ?? 'City (Arabic)',
                          hintText: 'القاهرة',
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressEnController,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyAddressEn ?? 'Address (English)',
                          hintText: 'Zamalek, Cairo',
                        ),
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: TextFormField(
                        controller: _addressArController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.addPropertyAddressAr ?? 'Address (Arabic)',
                          hintText: 'الزمالك، القاهرة',
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(12),
                OutlinedButton.icon(
                  key: const ValueKey('select-property-location'),
                  onPressed: _isLoading ? null : _selectPropertyLocation,
                  icon: Icon(
                    _selectedLocation == null
                        ? Icons.map_outlined
                        : Icons.location_on,
                  ),
                  label: Text(
                    _selectedLocation == null
                        ? l10n?.myPropertiesSelectLocation ??
                              'Pick location on map'
                        : l10n?.myPropertiesLocationPicked ??
                              'Location selected',
                  ),
                ),
                if (_selectedLocation case final selection?)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      selection.address ??
                          (selection.addressLookupUnavailable
                              ? l10n?.propertyLocationAddressUnavailable ?? 'Address unavailable; selected map location will still be saved.'
                              : '${selection.latitude.toStringAsFixed(5)}, '
                                    '${selection.longitude.toStringAsFixed(5)}'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                verticalSpace(32),

                // Submit Button
                AppButton(
                  text: l10n?.addPropertySubmit ?? 'Publish Listing',
                  isLoading: _isLoading,
                  height: AppDimensions.buttonHeightLg,
                  onPressed: _submitProperty,
                ),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageManager(ColorScheme colors) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length + 1,
            separatorBuilder: (_, _) => horizontalSpace(12),
            itemBuilder: (context, index) {
              if (index == _images.length) {
                // Add Image Button
                return InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: colors.primary,
                          size: 32,
                        ),
                        verticalSpace(4),
                        Text(
                          l10n?.myPropertiesPickImages ?? 'Add Photo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final img = _images[index];
              final isCover = index == _coverImageIndex;
              final isUrl = img.startsWith('http');

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _coverImageIndex = index);
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCover
                              ? colors.primary
                              : colors.outlineVariant,
                          width: isCover ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: isUrl
                            ? Image.network(
                                img,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: colors.surfaceContainerLow,
                                  child: const Icon(Icons.broken_image),
                                ),
                              )
                            : Image.file(
                                File(img),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: colors.surfaceContainerLow,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (isCover)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n?.myPropertiesCoverImageTag ?? 'Cover',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        verticalSpace(12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customImageUrlController,
                decoration: InputDecoration(
                  hintText: 'Or enter photo URL...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_link_rounded),
                    onPressed: _addCustomImageUrl,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
