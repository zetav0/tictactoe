import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/game_model.dart';
import '../services/room_service.dart';
import '../theme/app_colors.dart';
import 'remote_connect_four_screen.dart';
import 'remote_game_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomCode;
  final GameType gameType;

  const WaitingRoomScreen({
    super.key,
    required this.roomCode,
    this.gameType = GameType.ticTacToe,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  StreamSubscription<DatabaseEvent>? _sub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _sub = RoomService.watchRoom(widget.roomCode).listen((event) {
      if (!event.snapshot.exists || _navigated) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (data['status'] == 'playing') {
        _navigated = true;
        _goToGame();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _goToGame() {
    if (!mounted) return;
    final screen = widget.gameType == GameType.connectFour
        ? RemoteConnectFourScreen(
            roomCode: widget.roomCode,
            myRole: CellValue.x,
          )
        : RemoteGameScreen(roomCode: widget.roomCode, myRole: CellValue.x);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _cancelRoom() async {
    await _sub?.cancel();
    await RoomService.deleteRoom(widget.roomCode);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasGradientTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _cancelRoom,
        ),
        title: Text(
          AppLocalizations.of(context).onlineGame,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated waiting indicator
                SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .rotate(duration: 1200.ms, curve: Curves.linear),
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context).shareCode,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),
                // Room code display
                GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.roomCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context).codeCopied,
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.roomCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 8,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.copy_rounded,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scaleXY(begin: 0.8, curve: Curves.easeOutBack),
                const SizedBox(height: 32),
                Text(
                      AppLocalizations.of(context).waitingForOpponent,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 800.ms)
                    .then()
                    .fadeOut(duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
