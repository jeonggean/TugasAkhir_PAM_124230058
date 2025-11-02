import 'dart:math';
import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeveloperInfoScreen extends StatefulWidget {
  const DeveloperInfoScreen({super.key});

  @override
  State<DeveloperInfoScreen> createState() => _DeveloperInfoScreenState();
}

class _DeveloperInfoScreenState extends State<DeveloperInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        elevation: 0,
        title: Text(
          "Informasi Developer",
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
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glow = 6 + 4 * sin(_glowController.value * 2 * pi);
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kPrimaryColor.withOpacity(0.3),
                        blurRadius: glow,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/dev_profile.jpg'),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Text(
              "Najwa Egi Fitriyani",
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "UPN Veteran Yogyakarta",
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: AppColors.kSecondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

            // Card Info
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: "Nama Lengkap",
                    subtitle: "Najwa Egi Fitriyani",
                  ),
                  _divider(),
                  _buildInfoTile(
                    icon: Icons.school_outlined,
                    title: "NIM",
                    subtitle: "124230058",
                  ),
                  _divider(),
                  _buildInfoTile(
                    icon: Icons.class_outlined,
                    title: "Kelas",
                    subtitle: "SI-B",
                  ),
                  _divider(),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: "najwaegi@gmail.com",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Footer
            Text(
              "“Coding with passion and purpose.”",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppColors.kSecondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "© 2025 EventFinder Project",
              style: GoogleFonts.nunito(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade300,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.kPrimaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.kPrimaryColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 15,
          color: AppColors.kSecondaryTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.kTextColor,
        ),
      ),
    );
  }
}
