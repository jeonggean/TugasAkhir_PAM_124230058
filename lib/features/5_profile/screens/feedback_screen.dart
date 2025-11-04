import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        elevation: 0,
        title: Text(
          "Saran & Kesan",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_rounded,
                size: 80, color: AppColors.kPrimaryColor.withOpacity(0.85)),
            const SizedBox(height: 12),
            Text(
              "Terima kasih telah mengikuti perjalanan ini! 💜",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: AppColors.kTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            _buildSection(
              title: "Kesan",
              content:
                  "Mata kuliah ini sangat  mengajarkan kepada saya bahwa betapa pentingnya untuk selalu mengingat bahwa Allah SWT bersama dengan mahsiswa semester 5. "
                  "Proses pembelajarannya sangat challenging, walaupun saya gen Z saya gasuka yang challenging.",
            ),

            const SizedBox(height: 28),
            _buildSection(
              title: "Pesan",
              content:
                  "Untuk ke depannya, semoga selamat selimit "
                  "Terima kasih atas bimbingan dan ilmunya selama satu semester ini.",
            ),

            const SizedBox(height: 40),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 16),
            Text(
              "— Disusun dengan rasa terima kasih 🙏",
              style: GoogleFonts.nunito(
                color: AppColors.kSecondaryTextColor,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.kPrimaryColor,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            content,
            style: GoogleFonts.nunito(
              fontSize: 17,
              color: AppColors.kTextColor,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
