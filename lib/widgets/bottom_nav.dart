import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_provider.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withAlpha(200),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withAlpha(60)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Play',
                active: currentIndex == 0,
                onTap: () => ref.read(navIndexProvider.notifier).state = 0,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                active: currentIndex == 1,
                onTap: () => ref.read(navIndexProvider.notifier).state = 1,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: currentIndex == 2,
                onTap: () => ref.read(navIndexProvider.notifier).state = 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: active
            ? BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(32),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.onPrimary : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.onPrimary : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
