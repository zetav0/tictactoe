import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/playful_theme.dart';
import '../widgets/user_avatar.dart';

const _kAvatarSeeds = [
  'Cosmos',
  'Luna',
  'Nova',
  'Zephyr',
  'Atlas',
  'Orion',
  'Pixel',
  'Storm',
  'Blaze',
  'Echo',
  'Frost',
  'Neon',
  'Spark',
  'Drift',
  'Haze',
  'Vex',
];

class ProfileEditScreen extends ConsumerStatefulWidget {
  /// When true the screen lives inside the bottom-nav shell: no back button,
  /// and saving confirms with a snackbar instead of popping the route.
  final bool embedded;

  const ProfileEditScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _usernameCtrl = TextEditingController();
  String _selectedSeed = 'Cosmos';
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      _usernameCtrl.text = profile.username;
      _selectedSeed = profile.avatarSeed;
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
    await ref
        .read(profileProvider.notifier)
        .save(
          UserProfile(
            username: _usernameCtrl.text.trim(),
            avatarSeed: _selectedSeed,
          ),
        );
    if (!mounted) return;
    if (widget.embedded) {
      setState(() {
        _saving = false;
        _dirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileSaved)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _selectSeed(String seed) {
    setState(() {
      _selectedSeed = seed;
      _dirty = true;
    });
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AvatarPickerSheet(
        selectedSeed: _selectedSeed,
        onSelectSeed: (seed) {
          Navigator.pop(context);
          _selectSeed(seed);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.canvasGradientTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          l10n.editProfile,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Avatar ──────────────────────────────────────────────────────
              GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        UserAvatar(seed: _selectedSeed, size: 100),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.onSecondary,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scaleXY(begin: 0.85, curve: Curves.easeOutBack),

              const SizedBox(height: 10),
              Text(
                l10n.tapToChangeAvatar,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 36),

              // ── Username ─────────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.username,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white60,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameCtrl,
                maxLength: 20,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: l10n.enterUsername,
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
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
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: _canSave
                          ? PlayfulTheme.secondaryLip(depth: 5)
                          : null,
                    ),
                    child: _saving
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onSecondary,
                              ),
                            ),
                          )
                        : Text(
                            l10n.saveChanges,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSecondary,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar picker bottom sheet ─────────────────────────────────────────────────

class _AvatarPickerSheet extends StatelessWidget {
  final String selectedSeed;
  final ValueChanged<String> onSelectSeed;

  const _AvatarPickerSheet({
    required this.selectedSeed,
    required this.onSelectSeed,
  });

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
            AppLocalizations.of(context).chooseAvatar,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _kAvatarSeeds.length,
            itemBuilder: (context, i) {
              final seed = _kAvatarSeeds[i];
              return GestureDetector(
                onTap: () => onSelectSeed(seed),
                child: UserAvatar(
                  seed: seed,
                  size: double.infinity,
                  selected: seed == selectedSeed,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
