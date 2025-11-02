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

class _RedeemCodeScreenState extends State<RedeemCodeScreen> {
  final AuthService _authService = AuthService();
  final RedeemService _redeemService = RedeemService();
  final TextEditingController _codeController = TextEditingController();

  late Future<int> _pointsFuture;
  bool _isLoading = false;
  String? _errorMessage;

  final int _minCodeLength = 8;

  @override
  void initState() {
    super.initState();
    _pointsFuture = _authService.getCurrentUserPoints();
  }

  Future<void> _redeem() async {
    final String code = _codeController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil! Poin Anda bertambah.'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
      appBar: AppBar(
        title: Text("Tukar Kode & Badge"),
      ),
      body: FutureBuilder<int>(
        future: _pointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final int currentPoints = snapshot.data ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCurrentBadge(currentPoints),
                const SizedBox(height: 32),
                _buildRedeemForm(),
                const SizedBox(height: 32),
                _buildBadgeInfo(currentPoints),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentBadge(int points) {
    final badge = BadgeService.getBadgeForPoints(points);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Icon(badge.icon, size: 80, color: badge.color),
          const SizedBox(height: 16),
          Text(
            "Badge Anda Saat Ini",
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            badge.name,
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
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
  }

  Widget _buildRedeemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Tukar Kode Voucher",
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
          style: TextStyle(color: AppColors.kTextColor),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          decoration: InputDecoration(
            hintText: 'Masukkan kode unik...',
            hintStyle: TextStyle(color: AppColors.kSecondaryTextColor),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(color: Colors.redAccent, fontSize: 15),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _redeem,
          child: _isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child:
                      CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text("Tukar"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: BadgeService.allBadges.map((badge) {
              String subtitleText;
              Color subtitleColor = AppColors.kSecondaryTextColor;
              FontWeight subtitleWeight = FontWeight.normal;

              if (currentPoints >= badge.minPoints) {
                subtitleText = "Tercapai";
                subtitleColor = Colors.green;
                subtitleWeight = FontWeight.bold;
              } else {
                final int pointsNeeded = badge.minPoints - currentPoints;
                subtitleText = "Kurang $pointsNeeded Poin lagi";
              }

              return ListTile(
                leading: Icon(badge.icon, color: badge.color, size: 30),
                title: Text(
                  badge.name,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextColor,
                  ),
                ),
                subtitle: Text(
                  subtitleText,
                  style: GoogleFonts.nunito(
                    color: subtitleColor,
                    fontWeight: subtitleWeight,
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
        )
      ],
    );
  }
}