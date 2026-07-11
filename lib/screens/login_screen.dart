import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_colors.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  
  bool isLoginMode = true;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // Fungsi autentikasi utama
  Future<void> handleAuthentication() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (isLoginMode) {
        // Alur untuk Masuk (Login)
        await supabaseClient.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      } else {
        // Alur untuk Daftar (Register)
        final AuthResponse authResponse = await supabaseClient.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        final User? registeredUser = authResponse.user;
        if (registeredUser != null) {
          await supabaseClient.from('profiles').insert({
            'id': registeredUser.id,
            'full_name': nameController.text.trim(),
            'email': emailController.text.trim(),
          });

          if (mounted) {
            // Tampilkan pesan instruksi cek surel
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendaftaran berhasil! Silakan cek kotak masuk surel Anda untuk klik tautan verifikasi.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
            
            // Bersihkan kolom teks dan kembalikan ke mode Masuk
            passwordController.clear();
            toggleViewMode();
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void toggleViewMode() {
    setState(() {
      isLoginMode = !isLoginMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.memory,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  isLoginMode ? 'Selamat Datang Kembali' : 'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.mainTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                if (!isLoginMode) ...[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
                      filled: true,
                      fillColor: AppColors.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: AppColors.mainTextColor),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Surel (Email)',
                    labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.mainTextColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.mainTextColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : handleAuthentication,
                    child: isLoading
                        ? const CircularProgressIndicator(color: AppColors.backgroundColor)
                        : Text(
                            isLoginMode ? 'Masuk' : 'Daftar',
                            style: const TextStyle(
                              color: AppColors.backgroundColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: toggleViewMode,
                  child: Text(
                    isLoginMode
                        ? 'Belum punya akun? Daftar di sini'
                        : 'Sudah punya akun? Masuk di sini',
                    style: const TextStyle(color: AppColors.secondaryTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}