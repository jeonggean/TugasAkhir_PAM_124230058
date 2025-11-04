import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:eventfinder/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthController _controller = AuthController();

  String? _localError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    _controller.errorMessage = "";
    setState(() {
      _localError = null;
    });

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _localError = "Semua field harus diisi.";
      });
      return;
    }

    if (username.length < 4) {
      setState(() {
        _localError = "Username minimal 4 karakter.";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _localError = "Password minimal 6 karakter.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _localError = "Konfirmasi password tidak cocok.";
      });
      return;
    }

    final bool success = await _controller.register(username, password);

    if (success && mounted) {
      SnackBarHelper.show(
        context,
        "Registrasi berhasil! Silakan login.",
        type: SnackBarType.success,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (!success && mounted && _controller.errorMessage.isNotEmpty) {
      SnackBarHelper.show(
        context,
        _controller.errorMessage,
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 80,
                  color: AppColors.kPrimaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Buat Akun',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai perjalanan event-mu!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: AppColors.kSecondaryTextColor,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureState: _obscurePassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureState: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (_localError != null)
                  Text(
                    _localError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: Colors.redAccent,
                      fontSize: 15,
                    ),
                  ),
                if (_controller.errorMessage.isNotEmpty)
                  Text(
                    _controller.errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: Colors.redAccent,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 16),
                _controller.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColors.kPrimaryColor))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Daftar',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?',
                      style: GoogleFonts.nunito(
                          fontSize: 16, color: AppColors.kSecondaryTextColor),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Login',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureState = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureState : false,
      style: TextStyle(color: AppColors.kTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.kSecondaryTextColor),
        prefixIcon: Icon(icon, color: AppColors.kSecondaryTextColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureState
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.kSecondaryTextColor,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.kCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.kPrimaryColor, width: 2.0),
        ),
      ),
    );
  }
}