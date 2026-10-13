import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/person_avatar.dart';
import '../../../../core/widgets/app_feedback.dart';
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

  @override
  Widget build(BuildContext context) {
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
            appBar: AppBar(title: const Text('Edit profile')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message ?? 'Profile details could not be loaded.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: context.read<ProfileEditCubit>().loadProfile,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
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
          appBar: AppBar(title: const Text('Edit profile')),
          body:
              state.status == ProfileEditStatus.initial ||
                  state.status == ProfileEditStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        Center(
                          child: Semantics(
                            button: true,
                            label: 'Change profile photo',
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
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: state.email,
                          readOnly: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            helperText: 'Email changes require account verification and are not available here.',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            prefixIcon: Icon(Icons.phone_outlined),
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
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: isSaving
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      context
                                          .read<ProfileEditCubit>()
                                          .saveProfile(
                                            displayName: _nameController.text,
                                            phone: _phoneController.text,
                                          );
                                    }
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
