import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            colors.surfaceContainerLow,
            colors.surfaceContainerHighest,
            _controller.value,
          ),
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

class EstateCardSkeleton extends StatelessWidget {
  final double width;

  const EstateCardSkeleton({super.key, this.width = 240});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(
          width: width,
          height: 140,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        const SizedBox(height: 12),
        const AppSkeleton(width: 165, height: 16),
        const SizedBox(height: 8),
        const AppSkeleton(width: 120, height: 13),
        const SizedBox(height: 12),
        const AppSkeleton(width: 96, height: 16),
      ],
    ),
  );
}

class AgentCardSkeleton extends StatelessWidget {
  const AgentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSkeleton(
          width: 52,
          height: 52,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        SizedBox(height: 10),
        AppSkeleton(width: 94, height: 14),
        SizedBox(height: 7),
        AppSkeleton(width: 70, height: 12),
      ],
    ),
  );
}

class EstateListSkeleton extends StatelessWidget {
  final int itemCount;

  const EstateListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(20),
    itemCount: itemCount,
    separatorBuilder: (_, _) => const SizedBox(height: 16),
    itemBuilder: (context, index) =>
        const EstateCardSkeleton(width: double.infinity),
  );
}

class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: const Row(
      children: [
        AppSkeleton(
          width: 68,
          height: 68,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 150, height: 18),
              SizedBox(height: 10),
              AppSkeleton(width: 185, height: 14),
            ],
          ),
        ),
      ],
    ),
  );
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileHeaderSkeleton(),
        const SizedBox(height: 20),
        const AppSkeleton(height: 52),
        const SizedBox(height: 28),
        const AppSkeleton(width: 150, height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => const AppSkeleton(
              width: 110,
              height: 92,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const AppSkeleton(width: 180, height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) => const EstateCardSkeleton(),
          ),
        ),
        const SizedBox(height: 28),
        const AppSkeleton(width: 130, height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => const AppSkeleton(
              width: 150,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const AppSkeleton(width: 130, height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => const AgentCardSkeleton(),
          ),
        ),
      ],
    ),
  );
}

class ChatListSkeleton extends StatelessWidget {
  final int itemCount;

  const ChatListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    itemCount: itemCount,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (context, index) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          AppSkeleton(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 110, height: 15),
                SizedBox(height: 8),
                AppSkeleton(height: 13),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class AgentDetailsSkeleton extends StatelessWidget {
  const AgentDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileHeaderSkeleton(),
        const SizedBox(height: 20),
        const AppSkeleton(height: 120),
        const SizedBox(height: 24),
        const AppSkeleton(width: 170, height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => const EstateCardSkeleton(),
          ),
        ),
      ],
    ),
  );
}

class EstateDetailsSkeleton extends StatelessWidget {
  const EstateDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 24),
    children: const [
      AppSkeleton(height: 290, borderRadius: BorderRadius.zero),
      Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(width: 220, height: 24),
            SizedBox(height: 12),
            AppSkeleton(width: 140, height: 18),
            SizedBox(height: 24),
            AppSkeleton(height: 120),
            SizedBox(height: 24),
            AppSkeleton(width: 170, height: 20),
            SizedBox(height: 12),
            ProfileHeaderSkeleton(),
          ],
        ),
      ),
    ],
  );
}
