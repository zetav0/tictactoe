import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String seed;
  final String? imagePath; // if set, renders a local file instead of the SVG
  final double size;
  final bool selected;

  const UserAvatar({
    super.key,
    required this.seed,
    this.imagePath,
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
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (imagePath != null) {
      if (imagePath!.startsWith('https://')) {
        return Image.network(imagePath!, fit: BoxFit.cover,
            errorBuilder: (_, e, st) => _svgFallback());
      }
      if (imagePath!.startsWith('data:')) {
        try {
          final base64Str = imagePath!.substring(imagePath!.indexOf(',') + 1);
          final bytes = base64Decode(base64Str);
          return Image.memory(bytes, fit: BoxFit.cover,
              errorBuilder: (_, e, st) => _svgFallback());
        } catch (_) {
          return _svgFallback();
        }
      }
    }
    return _svgFallback();
  }

  Widget _svgFallback() =>
      SvgPicture.string(multiavatar(seed), fit: BoxFit.cover);
}
