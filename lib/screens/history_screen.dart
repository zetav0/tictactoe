import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/game_model.dart';
import '../models/match_record.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    HistoryService.instance.ensureLoaded();
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
        title: Text(
          l10n.navHistory.toUpperCase(),
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
        child: ListenableBuilder(
          listenable: HistoryService.instance,
          builder: (context, _) {
            final records = HistoryService.instance.records;
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.historyEmpty,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _HistoryTile(record: records[i]),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MatchRecord record;

  const _HistoryTile({required this.record});

  static const _lossColor = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLocalPvp = !record.online && record.difficulty == null;

    final (String resultText, Color resultColor) = switch (record.result) {
      MatchResult.draw => (l10n.resultDraw, Colors.white70),
      MatchResult.win =>
        isLocalPvp
            ? (l10n.wonBy(l10n.labelPlayer1), AppColors.xColor)
            : (l10n.resultWin, AppColors.tertiary),
      MatchResult.loss =>
        isLocalPvp
            ? (l10n.wonBy(l10n.labelPlayer2), AppColors.oColor)
            : (l10n.resultLoss, _lossColor),
    };

    final game = record.gameType == GameType.connectFour
        ? l10n.gameConnectFour
        : l10n.gameTicTacToe;
    final opponent = record.online
        ? (record.opponentName ?? l10n.labelOpponent)
        : (record.difficulty != null ? l10n.labelAi : l10n.labelPlayer2);
    final details = [
      game,
      if (!isLocalPvp) l10n.vsOpponent(opponent),
      if (record.difficulty != null)
        switch (record.difficulty!) {
          AIDifficulty.easy => l10n.difficultyEasy,
          AIDifficulty.medium => l10n.difficultyMedium,
          AIDifficulty.hard => l10n.difficultyHard,
        },
      if (record.online) l10n.onlineLabel,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: resultColor.withValues(alpha: 0.5)),
            ),
            child: Icon(
              record.gameType == GameType.connectFour
                  ? Icons.circle_outlined
                  : Icons.grid_view_rounded,
              color: resultColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(context, record.playedAt),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    return sameDay
        ? DateFormat.Hm(locale).format(dt)
        : DateFormat('d MMM', locale).format(dt);
  }
}
