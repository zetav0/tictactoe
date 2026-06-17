import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/remote_connect_four_controller.dart';
import '../models/game_model.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../utils/connect_four_logic.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/connect_four_board.dart';
import '../widgets/score_card.dart';
import '../widgets/turn_indicator.dart';
import 'connect_four_screen.dart' show C4GameOverOverlay;

class RemoteConnectFourScreen extends ConsumerStatefulWidget {
  final String roomCode;
  final CellValue myRole;

  const RemoteConnectFourScreen({
    super.key,
    required this.roomCode,
    required this.myRole,
  });

  @override
  ConsumerState<RemoteConnectFourScreen> createState() => _RemoteConnectFourScreenState();
}

class _RemoteConnectFourScreenState extends ConsumerState<RemoteConnectFourScreen> {
  late final RemoteConnectFourController _controller;
  Timer? _overlayTimer;
  bool _overlayVisible = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    _controller = RemoteConnectFourController(
      roomCode: widget.roomCode,
      myRole: widget.myRole,
      myProfile: profile,
      onOpponentLeft: _onOpponentLeft,
    );
    _controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    final status = _controller.state.status;
    if (status != GameStatus.playing) {
      _overlayTimer?.cancel();
      _overlayTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _overlayVisible = true);
      });
    } else {
      _overlayTimer?.cancel();
      if (_overlayVisible) setState(() => _overlayVisible = false);
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _controller.removeListener(_onStateChange);
    _controller.dispose();
    super.dispose();
  }

  void _onOpponentLeft() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Opponent left', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your opponent disconnected.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Leave game?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'The room will be deleted for both players.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _controller.leaveRoom();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final nav = Navigator.of(context);
          final should = await _confirmLeave();
          if (should && mounted) nav.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                ScoreCards(controller: _controller),
                TurnIndicator(controller: _controller),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: AspectRatio(
                          aspectRatio: c4Cols / c4Rows,
                          child: ConnectFourBoard(controller: _controller),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            if (_overlayVisible && _controller.state.status != GameStatus.playing)
              C4GameOverOverlay(
                controller: _controller,
                onRestart: () {
                  setState(() => _overlayVisible = false);
                  _controller.reset();
                },
                onHome: () async {
                  final nav = Navigator.of(context);
                  await _controller.leaveRoom();
                  if (mounted) nav.pop();
                },
              ),
          ],
        ),
        bottomNavigationBar: const AppBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryFixedDim),
        onPressed: () async {
          final nav = Navigator.of(context);
          final should = await _confirmLeave();
          if (should && mounted) nav.pop();
        },
      ),
      title: Text(
        '4 EN RAYA — ONLINE',
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppColors.primaryFixedDim,
        ),
      ),
      centerTitle: true,
    );
  }
}
