import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
        ? RemoteConnectFourScreen(roomCode: widget.roomCode, myRole: CellValue.x)
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryFixedDim),
          onPressed: _cancelRoom,
        ),
        title: Text(
          'ONLINE GAME',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.primaryFixedDim,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
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
                  color: AppColors.primaryFixedDim.withAlpha(200),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: 1200.ms, curve: Curves.linear),
              const SizedBox(height: 40),
              Text(
                'Share this code\nwith your opponent',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 28),
              // Room code display
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryFixedDim.withAlpha(80),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.roomCode,
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: AppColors.primaryFixedDim,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.copy_rounded,
                        color: AppColors.primaryFixedDim,
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
                'Waiting for opponent...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white38,
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
    );
  }
}
