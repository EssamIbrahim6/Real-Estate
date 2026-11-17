import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/profile_edit_cubit.dart';
import '../cubit/profile_edit_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileEditCubit>().state;
    _nameController = TextEditingController(text: state.displayName);
    _phoneController = TextEditingController(text: state.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileEditCubit>().saveProfile(
        displayName: _nameController.text,
        phone: _phoneController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ProfileEditCubit, ProfileEditState>(
      listener: (context, state) {
        if (state.status == ProfileEditStatus.ready) {
          _nameController.text = state.displayName;
          _phoneController.text = state.phone;
        } else if (state.status == ProfileEditStatus.saved) {
          if (state.warning != null) {
            AppFeedback.info(context, state.warning!);
          }
          context.pop(true);
        } else if (state.status == ProfileEditStatus.error &&
            state.message != null) {
          AppFeedback.error(context, state.message!);
        }
      },
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        final isSaving = state.status == ProfileEditStatus.saving;
        if (state.status == ProfileEditStatus.loadError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n?.editProfileTitle ?? 'Edit profile'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message ??
                          l10n?.editProfileLoadError ??
                          'Profile details could not be loaded.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: context.read<ProfileEditCubit>().loadProfile,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n?.editProfileTryAgain ?? 'Try again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final avatar = state.localImagePath == null
            ? PersonAvatar(
                photoUrl: state.photoUrl,
                radius: 48,
                iconSize: 40,
                backgroundColor: colors.primary.withValues(alpha: 0.08),
                iconColor: colors.primary,
              )
            : CircleAvatar(
                radius: 48,
                backgroundImage: FileImage(File(state.localImagePath!)),
              );

        return Scaffold(
          appBar: AppBar(title: Text(l10n?.editProfileTitle ?? 'Edit profile')),
          bottomNavigationBar:
              state.status == ProfileEditStatus.initial ||
                  state.status == ProfileEditStatus.loading
              ? null
              : SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border(
                        top: BorderSide(color: colors.outlineVariant),
                      ),
                    ),
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isSaving ? null : _saveProfile,
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n?.editProfileSaveChanges ?? 'Save changes',
                              ),
                      ),
                    ),
                  ),
                ),
          body:
              state.status == ProfileEditStatus.initial ||
                  state.status == ProfileEditStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Semantics(
                                button: true,
                                label:
                                    l10n?.editProfileChangePhoto ??
                                    'Change profile photo',
                                child: InkWell(
                                  onTap: isSaving
                                      ? null
                                      : context
                                            .read<ProfileEditCubit>()
                                            .pickProfileImage,
                                  customBorder: const CircleBorder(),
                                  child: Stack(
                                    children: [
                                      avatar,
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: colors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colors.surface,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            size: 16,
                                            color: colors.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.displayName.trim().isEmpty
                                          ? (l10n?.editProfileTitle ??
                                                'Edit profile')
                                          : state.displayName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      l10n?.editProfileIntro ??
                                          'Keep your details up to date.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n?.editProfileSection ?? 'Personal information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _nameController,
                                labelText:
                                    l10n?.editProfileFullName ?? 'Full name',
                                hintText:
                                    l10n?.editProfileFullName ?? 'Full name',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? (l10n?.editProfileNameRequired ??
                                          'Enter your name')
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: state.email,
                                readOnly: true,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText:
                                      l10n?.editProfileEmail ?? 'Email address',
                                  helperText: l10n?.editProfileEmailHelper ?? 'Email changes require account verification and are not available here.',
                                  prefixIcon: const Icon(
                                    Icons.mail_outline_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _phoneController,
                                labelText:
                                    l10n?.editProfilePhone ?? 'Phone number',
                                hintText:
                                    l10n?.editProfilePhone ?? 'Phone number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                        if (state.warning != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            state.warning!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.tertiary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
