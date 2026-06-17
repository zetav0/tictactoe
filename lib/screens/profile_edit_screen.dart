import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/user_avatar.dart';

const _kAvatarSeeds = [
  'Cosmos', 'Luna', 'Nova', 'Zephyr',
  'Atlas', 'Orion', 'Pixel', 'Storm',
  'Blaze', 'Echo', 'Frost', 'Neon',
  'Spark', 'Drift', 'Haze', 'Vex',
];

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _usernameCtrl = TextEditingController();
  String _selectedSeed = 'Cosmos';
  String? _customImagePath;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      _usernameCtrl.text = profile.username;
      _selectedSeed = profile.avatarSeed;
      _customImagePath = profile.customImagePath;
    }
    _usernameCtrl.addListener(() => setState(() => _dirty = true));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _usernameCtrl.text.trim().isNotEmpty && _dirty;

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    var imageUrl = _customImagePath;

    // If still a local base64 (just picked, not yet uploaded), upload now
    if (_customImagePath != null && _customImagePath!.startsWith('data:')) {
      try {
        final base64Str = _customImagePath!.substring(_customImagePath!.indexOf(',') + 1);
        imageUrl = await StorageService.uploadAvatar(base64Decode(base64Str));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not upload avatar: $e')),
          );
          setState(() => _saving = false);
        }
        return;
      }
    }

    await ref.read(profileProvider.notifier).save(
          UserProfile(
            username: _usernameCtrl.text.trim(),
            avatarSeed: _selectedSeed,
            customImagePath: imageUrl,
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    // Store as base64 data URL so it works on all platforms (web + native)
    final bytes = await picked.readAsBytes();
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    setState(() {
      _customImagePath = dataUrl;
      _dirty = true;
    });
  }

  void _selectSeed(String seed) {
    setState(() {
      _selectedSeed = seed;
      _customImagePath = null; // preset replaces custom image
      _dirty = true;
    });
  }

  void _showAvatarOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AvatarPickerSheet(
        selectedSeed: _selectedSeed,
        customImagePath: _customImagePath,
        onPickGallery: () => _pickImage(ImageSource.gallery),
        onPickCamera: () => _pickImage(ImageSource.camera),
        onSelectSeed: (seed) {
          Navigator.pop(context);
          _selectSeed(seed);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryFixedDim),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EDIT PROFILE',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.primaryFixedDim,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // ── Avatar ──────────────────────────────────────────────────────
            GestureDetector(
              onTap: _showAvatarOptions,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  UserAvatar(
                    seed: _selectedSeed,
                    imagePath: _customImagePath,
                    size: 100,
                  ),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.85, curve: Curves.easeOutBack),

            const SizedBox(height: 10),
            Text(
              'Tap to change avatar',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 36),

            // ── Username ─────────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'USERNAME',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white38,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameCtrl,
              maxLength: 20,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Enter your username',
                hintStyle: GoogleFonts.inter(color: Colors.white24),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.primaryFixedDim.withAlpha(120),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: const Icon(Icons.edit_rounded,
                    color: Colors.white38, size: 18),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 40),

            // ── Save button ──────────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _canSave ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: _canSave
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(80),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: _saving
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Avatar picker bottom sheet ─────────────────────────────────────────────────

class _AvatarPickerSheet extends StatefulWidget {
  final String selectedSeed;
  final String? customImagePath;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final ValueChanged<String> onSelectSeed;

  const _AvatarPickerSheet({
    required this.selectedSeed,
    required this.customImagePath,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onSelectSeed,
  });

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  bool _showPresets = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Change Avatar',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Upload options
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.primary,
                  onTap: widget.onPickGallery,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.tertiary,
                  onTap: widget.onPickCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionButton(
                  icon: Icons.face_rounded,
                  label: 'Preset',
                  color: AppColors.surfaceContainerHigh,
                  onTap: () => setState(() => _showPresets = !_showPresets),
                  active: _showPresets,
                ),
              ),
            ],
          ),

          // Preset avatar grid (toggled)
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _showPresets
                ? Column(
                    children: [
                      const SizedBox(height: 20),
                      Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _kAvatarSeeds.length,
                        itemBuilder: (context, i) {
                          final seed = _kAvatarSeeds[i];
                          final isSelected = widget.customImagePath == null &&
                              seed == widget.selectedSeed;
                          return GestureDetector(
                            onTap: () => widget.onSelectSeed(seed),
                            child: UserAvatar(
                              seed: seed,
                              size: double.infinity,
                              selected: isSelected,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool active;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : color,
          borderRadius: BorderRadius.circular(14),
          border: active
              ? Border.all(color: AppColors.primaryFixedDim.withAlpha(120))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
