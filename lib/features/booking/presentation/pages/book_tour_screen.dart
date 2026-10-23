import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../cubit/booking_cubit.dart';

/// Arguments passed to [BookTourScreen] via GoRouter `extra`.
class BookTourArgs {
  final EstateEntity estate;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  const BookTourArgs({
    required this.estate,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
  });
}

class BookTourScreen extends StatefulWidget {
  final BookTourArgs args;

  const BookTourScreen({super.key, required this.args});

  @override
  State<BookTourScreen> createState() => _BookTourScreenState();
}

class _BookTourScreenState extends State<BookTourScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final TextEditingController _notesCtrl = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedSlot;
  BookingSubmitStatus _lastStatus = BookingSubmitStatus.initial;

  static const List<String> _timeSlots = [
    '09:00 AM – 10:00 AM',
    '10:00 AM – 11:00 AM',
    '11:00 AM – 12:00 PM',
    '01:00 PM – 02:00 PM',
    '02:00 PM – 03:00 PM',
    '03:00 PM – 04:00 PM',
    '04:00 PM – 05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.args;
    _nameCtrl = TextEditingController(text: a.customerName);
    _emailCtrl = TextEditingController(text: a.customerEmail);
    _phoneCtrl = TextEditingController(text: a.customerPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      AppFeedback.error(context, 'Please select a visit date.');
      return;
    }
    if (_selectedSlot == null) {
      AppFeedback.error(context, 'Please select a time slot.');
      return;
    }

    final estate = widget.args.estate;
    final langCode = Localizations.localeOf(context).languageCode;

    context.read<BookingCubit>().submitBooking(
      estateId: estate.id,
      estateTitle: estate.localizedTitle(langCode),
      estateTitleEn: estate.titleEn,
      estateTitleAr: estate.titleAr,
      estateCoverImage: estate.coverImage,
      estateAddress: estate.location.localizedAddress(langCode),
      estatePrice: estate.price,
      estatePricePeriod: estate.pricePeriod,
      listingType: estate.listingType,
      customerId: widget.args.customerId,
      customerName: _nameCtrl.text.trim(),
      customerEmail: _emailCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      agentId: estate.agentId,
      agentUserId: estate.agentUserId,
      bookingDate: _selectedDate!,
      timeSlot: _selectedSlot!,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final estate = widget.args.estate;
    final langCode = Localizations.localeOf(context).languageCode;

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (_lastStatus == state.submitStatus) return;
        _lastStatus = state.submitStatus;

        switch (state.submitStatus) {
          case BookingSubmitStatus.success:
            AppFeedback.success(
              context,
              l10n?.bookingSuccess ?? 'Visit booked successfully!',
            );
            if (context.canPop()) context.pop(true);
            break;
          case BookingSubmitStatus.duplicate:
            AppFeedback.error(
              context,
              l10n?.bookingDuplicateError ??
                  'You already have a booking for this date and time slot.',
            );
            break;
          case BookingSubmitStatus.failure:
            AppFeedback.error(
              context,
              state.submitError ?? l10n?.bookingError ?? 'Booking failed.',
            );
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.bookingTitle ?? 'Book a Visit'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              // Estate snapshot
              _EstateSnapshotCard(estate: estate, langCode: langCode),
              const SizedBox(height: 24),

              // Section: Your Details
              _sectionTitle(context, l10n?.bookingCustomerSection ?? 'Your Details'),
              const SizedBox(height: 12),
              _field(
                controller: _nameCtrl,
                label: l10n?.bookingCustomerName ?? 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? (l10n?.bookingFieldRequired ?? 'Required')
                        : null,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _emailCtrl,
                label: l10n?.bookingCustomerEmail ?? 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n?.bookingFieldRequired ?? 'Required';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                    return l10n?.bookingEmailInvalid ?? 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _field(
                controller: _phoneCtrl,
                label: l10n?.bookingCustomerPhone ?? 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    (v == null || v.trim().length < 7)
                        ? (l10n?.bookingPhoneInvalid ?? 'Enter a valid phone number')
                        : null,
              ),
              const SizedBox(height: 24),

              // Section: Visit Schedule
              _sectionTitle(context, l10n?.bookingScheduleSection ?? 'Visit Schedule'),
              const SizedBox(height: 12),

              // Date picker
              _DatePickerField(
                selectedDate: _selectedDate,
                onTap: _pickDate,
                label: l10n?.bookingDateLabel ?? 'Visit Date',
              ),
              const SizedBox(height: 16),

              // Time slots
              Text(
                l10n?.bookingTimeSlotLabel ?? 'Time Slot',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                    selectedColor: colors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Notes
              _sectionTitle(context, l10n?.bookingNotesLabel ?? 'Additional Notes (optional)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: l10n?.bookingNotesHint ??
                      'Any special requests or questions for the agent...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(onSubmit: _submit),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
      ),
    );
  }
}

class _EstateSnapshotCard extends StatelessWidget {
  final EstateEntity estate;
  final String langCode;

  const _EstateSnapshotCard({required this.estate, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 68,
              height: 68,
              child: estate.coverImage.isNotEmpty
                  ? Image.network(
                      estate.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: colors.surface,
                        child: Icon(Icons.home_outlined, color: colors.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: colors.surface,
                      child: Icon(Icons.home_outlined, color: colors.onSurfaceVariant),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estate.localizedTitle(langCode),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${estate.location.localizedAddress(langCode)}, ${estate.location.localizedCity(langCode)}',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${estate.price.toInt()}${estate.pricePeriod != null ? ' / ${estate.pricePeriod}' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String label;

  const _DatePickerField({
    required this.selectedDate,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateStr = selectedDate != null
        ? DateFormat('EEE, MMMM d, yyyy').format(selectedDate!)
        : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(14),
          color: colors.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: colors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateStr ?? label,
                style: TextStyle(
                  fontSize: 15,
                  color: dateStr != null ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onSubmit;

  const _BottomBar({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isLoading = state.submitStatus == BookingSubmitStatus.loading;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: AppButton(
            text: l10n?.bookingSubmit ?? 'Confirm Booking',
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        );
      },
    );
  }
}

