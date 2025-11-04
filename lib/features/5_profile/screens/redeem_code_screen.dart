import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:eventfinder/core/utils/snackbar_helper.dart';
import 'package:eventfinder/features/2_auth/services/auth_service.dart';
import 'package:eventfinder/features/5_profile/models/badge_model.dart';
import 'package:eventfinder/features/5_profile/services/redeem_service.dart';

class RedeemCodeScreen extends StatefulWidget {
  const RedeemCodeScreen({super.key});

  @override
  State<RedeemCodeScreen> createState() => _RedeemCodeScreenState();
}

class _RedeemCodeScreenState extends State<RedeemCodeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final RedeemService _redeemService = RedeemService();
  final TextEditingController _codeController = TextEditingController();
  late Future<int> _pointsFuture;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showConfetti = false;
  final int _minCodeLength = 8;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _pointsFuture = _authService.getCurrentUserPoints();
    _badgeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _codeController.text.trim();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showConfetti = false;
    });

    if (code.isEmpty) {
      setState(() {
        _errorMessage = "Kode tidak boleh kosong.";
        _isLoading = false;
      });
      return;
    }

    if (code.length < _minCodeLength) {
      setState(() {
        _errorMessage = "Format kode tidak valid (minimal $_minCodeLength karakter).";
        _isLoading = false;
      });
      return;
    }

    try {
      final newPoints = await _redeemService.redeemCode(code);
      _codeController.clear();
      setState(() {
        _pointsFuture = Future.value(newPoints);
        _showConfetti = true;
      });
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        SnackBarHelper.show(context, "🎉 Kode berhasil! Poin Anda bertambah.",
            type: SnackBarType.success);
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    } catch (e) {
      final err = e.toString().replaceAll("Exception: ", "");
      setState(() => _errorMessage = err);
      SnackBarHelper.show(context, err, type: SnackBarType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        title: Text("Tukar Kode & Badge",
            style:
                GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<int>(
        future: _pointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final points = snapshot.data ?? 0;
          return Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBadgeCard(points),
                    const SizedBox(height: 32),
                    _buildRedeemForm(),
                    const SizedBox(height: 32),
                    _buildBadgeInfo(points),
                  ],
                ),
              ),
              if (_showConfetti) _buildConfetti(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard(int points) {
    final badge = BadgeService.getBadgeForPoints(points);
    final nextBadge = BadgeService.allBadges
        .firstWhere((b) => b.minPoints > badge.minPoints, orElse: () => badge);
    final progress = badge == nextBadge
        ? 1.0
        : (points / nextBadge.minPoints).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kPrimaryColor.withOpacity(0.95),
            AppColors.kPrimaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimaryColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _badgeController,
            builder: (context, child) => Transform.scale(
              scale: 1 + 0.05 * sin(_badgeController.value * 2 * pi),
              child: Icon(badge.icon, size: 80, color: badge.color),
            ),
          ),
          const SizedBox(height: 16),
          Text("Badge Saat Ini",
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16)),
          Text(badge.name,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28)),
          const SizedBox(height: 8),
          Text("$points Poin",
              style: GoogleFonts.nunito(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Text(
            badge == nextBadge
                ? "Kamu telah mencapai badge tertinggi!"
                : "Menuju ${nextBadge.name} (${(progress * 100).toStringAsFixed(0)}%)",
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

   Widget _buildRedeemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Masukkan Kode Voucher",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextColor,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(color: AppColors.kTextColor, letterSpacing: 2),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.qr_code_2_rounded, color: AppColors.kPrimaryColor),
            hintText: 'Ketik atau tempel kode unik...',
            hintStyle: TextStyle(color: AppColors.kSecondaryTextColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _redeem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  "Tukar Sekarang",
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildBadgeInfo(int points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Informasi Badge",
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.kTextColor)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: BadgeService.allBadges.map((badge) {
              final achieved = points >= badge.minPoints;
              return ListTile(
                leading: Icon(badge.icon,
                    color: achieved
                        ? badge.color
                        : AppColors.kSecondaryTextColor,
                    size: 32),
                title: Text(badge.name,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        color: AppColors.kTextColor)),
                subtitle: Text(
                  achieved ? "Tercapai" : "Belum tercapai",
                  style: GoogleFonts.nunito(
                      color:
                          achieved ? Colors.green : AppColors.kSecondaryTextColor,
                      fontWeight: achieved ? FontWeight.bold : FontWeight.normal),
                ),
                trailing: Text("${badge.minPoints} pts",
                    style: GoogleFonts.nunito(
                        color: AppColors.kSecondaryTextColor,
                        fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfetti() {
    return IgnorePointer(
      child: Stack(
        children: List.generate(25, (i) {
          final random = Random();
          final left = random.nextDouble() * MediaQuery.of(context).size.width;
          final top = random.nextDouble() * 200;
          final color = [
            Colors.purple,
            Colors.pinkAccent,
            Colors.yellow,
            Colors.blueAccent,
            Colors.green
          ][random.nextInt(5)];
          return AnimatedPositioned(
            duration: Duration(milliseconds: 800 + random.nextInt(800)),
            curve: Curves.easeInOut,
            left: left,
            top: top,
            child: Opacity(
              opacity: 0.9,
              child: Icon(Icons.circle,
                  size: random.nextDouble() * 10 + 6, color: color),
            ),
          );
        }),
      ),
    );
  }
}
