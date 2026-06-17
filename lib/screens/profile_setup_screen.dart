import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/user_avatar.dart';

const _kAvatarSeeds = [
  'Cosmos', 'Luna', 'Nova', 'Zephyr',
  'Atlas', 'Orion', 'Pixel', 'Storm',
  'Blaze', 'Echo', 'Frost', 'Neon',
];

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _controller = TextEditingController();
  String? _selectedSeed;
  bool _saving = false;

  bool get _canSave =>
      _controller.text.trim().isNotEmpty && _selectedSeed != null;

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);
    await ref.read(profileProvider.notifier).save(
          UserProfile(
            username: _controller.text.trim(),
            avatarSeed: _selectedSeed!,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome!',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              const SizedBox(height: 6),
              Text(
                'Set up your profile to get started.',
                style: GoogleFonts.inter(fontSize: 15, color: Colors.white38),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 32),
              Text(
                'YOUR NAME',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white38,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
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
                ),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 28),
              Text(
                'CHOOSE YOUR AVATAR',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white38,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _kAvatarSeeds.length,
                  itemBuilder: (context, i) {
                    final seed = _kAvatarSeeds[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSeed = seed),
                      child: UserAvatar(
                        seed: seed,
                        size: double.infinity,
                        selected: _selectedSeed == seed,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (300 + i * 40).ms)
                        .scaleXY(begin: 0.8, curve: Curves.easeOutBack);
                  },
                ),
              ),
              const SizedBox(height: 16),
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
                            'Get Started',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
