import 'package:flutter/material.dart';

class SearchInputControls extends StatelessWidget {
  const SearchInputControls({
    required this.controller,
    required this.hintText,
    required this.voiceTooltip,
    required this.clearTooltip,
    required this.searchTooltip,
    required this.filterTooltip,
    required this.speechAvailable,
    required this.isListening,
    required this.onSubmitted,
    required this.onVoicePressed,
    required this.onClearPressed,
    required this.onSearchPressed,
    required this.onFiltersPressed,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String voiceTooltip;
  final String clearTooltip;
  final String searchTooltip;
  final String filterTooltip;
  final bool speechAvailable;
  final bool isListening;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onVoicePressed;
  final VoidCallback onClearPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onFiltersPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (speechAvailable)
                    IconButton(
                      tooltip: voiceTooltip,
                      onPressed: onVoicePressed,
                      icon: Icon(
                        isListening
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                        color: isListening
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  if (controller.text.isNotEmpty)
                    IconButton(
                      tooltip: clearTooltip,
                      onPressed: onClearPressed,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  IconButton(
                    tooltip: searchTooltip,
                    onPressed: onSearchPressed,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: colors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: colors.outlineVariant),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        IconButton.filledTonal(
          tooltip: filterTooltip,
          onPressed: onFiltersPressed,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class SearchAiPromptCard extends StatelessWidget {
  const SearchAiPromptCard({
    required this.title,
    required this.hint,
    required this.hasQuery,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String hint;
  final bool hasQuery;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hint,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: title,
            onPressed: hasQuery ? onPressed : null,
            icon: Icon(
              Icons.auto_awesome_rounded,
              color: hasQuery ? colors.primary : colors.onSurfaceVariant,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
