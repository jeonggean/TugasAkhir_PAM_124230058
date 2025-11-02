import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventfinder/core/utils/app_colors.dart';
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

  final int _minCodeLength = 8;
  bool _showConfetti = false;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _pointsFuture = _authService.getCurrentUserPoints();
    _badgeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final String code = _codeController.text.trim();

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
        _errorMessage =
            "Format kode tidak valid (minimal $_minCodeLength karakter).";
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

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Kode berhasil! Poin Anda bertambah.'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        title: Text(
          "Tukar Kode & Badge",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<int>(
        future: _pointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final int currentPoints = snapshot.data ?? 0;

          return Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAnimatedBadge(currentPoints),
                    const SizedBox(height: 32),
                    _buildRedeemForm(),
                    const SizedBox(height: 32),
                    _buildBadgeInfo(currentPoints),
                  ],
                ),
              ),
              if (_showConfetti) _buildConfettiAnimation(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBadge(int points) {
    final badge = BadgeService.getBadgeForPoints(points);

    return AnimatedBuilder(
      animation: _badgeController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.kPrimaryColor.withOpacity(0.95),
                AppColors.kPrimaryColor.withOpacity(0.75)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.kPrimaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Transform.scale(
                scale: 1 + 0.05 * sin(_badgeController.value * 2 * pi),
                child: Icon(badge.icon, size: 80, color: badge.color),
              ),
              const SizedBox(height: 16),
              Text(
                "Badge Anda Saat Ini",
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70),
              ),
              Text(
                badge.name,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$points Poin",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildBadgeInfo(int currentPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Informasi Badge",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: BadgeService.allBadges.map((badge) {
              final bool achieved = currentPoints >= badge.minPoints;
              final int pointsNeeded = badge.minPoints - currentPoints;
              return ListTile(
                leading: Icon(badge.icon, color: badge.color, size: 32),
                title: Text(
                  badge.name,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextColor,
                  ),
                ),
                subtitle: Text(
                  achieved ? "Tercapai" : "Kurang $pointsNeeded Poin lagi",
                  style: GoogleFonts.nunito(
                    color: achieved ? Colors.green : AppColors.kSecondaryTextColor,
                    fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  "${badge.minPoints} Poin",
                  style: GoogleFonts.nunito(
                    color: AppColors.kSecondaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfettiAnimation() {
    return IgnorePointer(
      child: Stack(
        children: List.generate(
          25,
          (index) {
            final random = Random();
            final left = random.nextDouble() * MediaQuery.of(context).size.width;
            final top = random.nextDouble() * 200;
            final size = random.nextDouble() * 10 + 6;
            final color = [
              Colors.yellow,
              Colors.purple,
              Colors.pink,
              Colors.blue,
              Colors.green
            ][random.nextInt(5)];
            return AnimatedPositioned(
              duration: Duration(milliseconds: 800 + random.nextInt(800)),
              curve: Curves.easeInOut,
              left: left,
              top: top,
              child: Opacity(
                opacity: 0.9,
                child: Icon(
                  Icons.circle,
                  size: size,
                  color: color.withOpacity(0.9),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}