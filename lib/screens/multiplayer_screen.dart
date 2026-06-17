import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_model.dart';
import '../providers/profile_provider.dart';
import '../services/room_service.dart';
import '../theme/app_colors.dart';
import '../widgets/tappable.dart';
import 'remote_connect_four_screen.dart';
import 'remote_game_screen.dart';
import 'waiting_room_screen.dart';

class MultiplayerScreen extends ConsumerStatefulWidget {
  final GameType gameType;

  const MultiplayerScreen({super.key, this.gameType = GameType.ticTacToe});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() => _loading = true);
    final profile = ref.read(profileProvider).valueOrNull;
    try {
      final code = await RoomService.createRoom(
        gameType: widget.gameType,
        profile: profile,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        _slideRoute(WaitingRoomScreen(roomCode: code, gameType: widget.gameType)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      _showError('Please enter a valid 6-character code.');
      return;
    }

    setState(() => _loading = true);
    final profile = ref.read(profileProvider).valueOrNull;
    try {
      final (result, roomGameType) = await RoomService.joinRoom(code);
      if (!mounted) return;
      switch (result) {
        case JoinResult.ok:
          if (roomGameType != widget.gameType) {
            final roomName = roomGameType == GameType.connectFour ? '4 en Raya' : 'Tic Tac Toe';
            _showGameTypeMismatch(code, roomName);
            // Firebase is NOT updated — host stays in the waiting room.
          } else {
            await RoomService.confirmJoin(code, profile: profile);
            if (!mounted) return;
            final screen = roomGameType == GameType.connectFour
                ? RemoteConnectFourScreen(roomCode: code, myRole: CellValue.o)
                : RemoteGameScreen(roomCode: code, myRole: CellValue.o);
            Navigator.pushReplacement(context, _slideRoute(screen));
          }
        case JoinResult.notFound:
          _showError('Room "$code" not found. Check the code and try again.');
        case JoinResult.roomFull:
          _showError('Room "$code" is already full.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showGameTypeMismatch(String code, String roomName) {
    final selected = widget.gameType == GameType.connectFour ? '4 en Raya' : 'Tic Tac Toe';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 10),
            const Text('Wrong game mode', style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: Text(
          'Room "$code" is a $roomName game, but you have $selected selected.\n\nGo back to the home screen and select $roomName to join this room.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
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
          'ONLINE MULTIPLAYER',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.primaryFixedDim,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryFixedDim),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Create Room Section
                  _Section(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Create a Room',
                    subtitle: 'Start a new game and share the code with a friend.',
                    child: _ActionButton(
                      label: 'Create Room',
                      icon: Icons.grid_view_rounded,
                      onTap: _createRoom,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white24,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white12)),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  // Join Room Section
                  _Section(
                    icon: Icons.login_rounded,
                    title: 'Join a Room',
                    subtitle: 'Enter the 6-character code your opponent shared.',
                    child: Column(
                      children: [
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 8,
                            color: AppColors.primaryFixedDim,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '· · · · · ·',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 28,
                              letterSpacing: 8,
                              color: Colors.white24,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerHigh,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.primaryFixedDim.withAlpha(120),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          label: 'Join Room',
                          icon: Icons.play_arrow_rounded,
                          onTap: _joinRoom,
                          color: AppColors.tertiary,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryFixedDim, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return TappableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withAlpha(80), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

PageRouteBuilder<T> _slideRoute<T>(Widget page) => PageRouteBuilder(
  pageBuilder: (context, animation, secondary) => page,
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder: (context, animation, secondary, child) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  ),
);
