import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String seed;
  final double size;
  final bool selected;

  const UserAvatar({
    super.key,
    required this.seed,
    this.size = 56,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryFixedDim : Colors.transparent,
          width: 3,
        ),
        boxShadow: selected
            ? [BoxShadow(color: AppColors.primary.withAlpha(100), blurRadius: 12)]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.string(multiavatar(seed), fit: BoxFit.cover),
    );
  }
}
