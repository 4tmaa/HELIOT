import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'profile/edit_profil_screen.dart';
import 'profile/alamat_pengiriman_screen.dart';
import 'profile/hubungi_admin_screen.dart';
import 'profile/pusat_bantuan_screen.dart';
import '../widgets/custom_loading.dart';

class _AppColors {
  static const Color primaryColor = Color(0xFFE63946);
  static const Color surfaceColor = Colors.white;
  static const Color mainTextColor = Color(0xFF1D3557);
  static const Color secondaryTextColor = Color(0xFF457B9D);
  static const Color destructiveColor = Color(0xFFFF4B5C);
  static const Color profileCardDecorativeCircle = Color(0x1AFFFFFF);
}

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool isLoading = true;
  String userName = 'Memuat...';
  String userEmail = '';
  String userPhone = '';
  String userAddress = '';
  String? userAvatar;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final activeUser = Supabase.instance.client.auth.currentUser;

      if (activeUser != null) {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', activeUser.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            if (profileData != null) {
              userName = profileData['full_name'] ?? 'Pengguna IoT';
              userEmail = profileData['email'] ?? activeUser.email ?? '';
              userPhone = profileData['phone_number'] ?? 'Belum diatur';
              userAddress = profileData['address'] ?? 'Belum diatur';
              userAvatar = profileData['avatar_url'];
            } else {
              userName = 'Pengguna Baru';
              userEmail = activeUser.email ?? '';
              userPhone = 'Belum diatur';
              userAddress = 'Belum diatur';
              userAvatar = null;
            }
            isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          userName = 'Gagal Memuat';
          userEmail = 'Periksa Koneksi';
          isLoading = false;
        });
      }
    }
  }

  Future<void> processLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void navigateToPage(Widget destinationScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
    ).then((_) => fetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: isLoading
          ? _buildShimmerLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 10),
                  child: Text(
                    'Profil Saya',
                    style: TextStyle(
                      color: _AppColors.mainTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Akun Anda'),
                      _buildMenuTile(
                        icon: Icons.location_on_rounded,
                        title: 'Alamat Pengiriman',
                        onTapAction: () =>
                            navigateToPage(const AlamatPengirimanScreen()),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader('Informasi & Bantuan'),
                      _buildMenuTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Hubungi Admin',
                        onTapAction: () =>
                            navigateToPage(const HubungiAdminScreen()),
                      ),
                      _buildMenuTile(
                        icon: Icons.help_rounded,
                        title: 'Pusat Bantuan',
                        onTapAction: () =>
                            navigateToPage(const PusatBantuanScreen()),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuTile(
                        icon: Icons.logout_rounded,
                        title: 'Keluar',
                        isDestructive: true,
                        onTapAction: processLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: CustomShimmerBox(height: 32, width: 150),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: const [
              CustomShimmerBox(height: 180, borderRadius: 24),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: CustomShimmerBox(height: 14, width: 100),
              ),
              CustomShimmerBox(
                height: 56,
                borderRadius: 16,
                margin: EdgeInsets.only(bottom: 12),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: CustomShimmerBox(height: 14, width: 140),
              ),
              CustomShimmerBox(
                height: 56,
                borderRadius: 16,
                margin: EdgeInsets.only(bottom: 12),
              ),
              CustomShimmerBox(
                height: 56,
                borderRadius: 16,
                margin: EdgeInsets.only(bottom: 12),
              ),
              SizedBox(height: 16),
              CustomShimmerBox(
                height: 56,
                borderRadius: 16,
                margin: EdgeInsets.only(bottom: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE63946), Color(0xFFB02A36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _AppColors.profileCardDecorativeCircle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _AppColors.profileCardDecorativeCircle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: userAvatar != null
                        ? NetworkImage(userAvatar!)
                        : null,
                    child: userAvatar == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: _AppColors.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () => navigateToPage(
                        EditProfilScreen(
                          initialName: userName,
                          initialPhone: userPhone,
                          initialEmail: userEmail,
                          initialAddress: userAddress,
                        ),
                      ),
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: _AppColors.primaryColor,
                      ),
                      label: const Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: _AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: _AppColors.secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTapAction,
    bool isDestructive = false,
  }) {
    final Color iconColor = isDestructive
        ? _AppColors.destructiveColor
        : _AppColors.primaryColor;
    final Color textColor = isDestructive
        ? _AppColors.destructiveColor
        : _AppColors.mainTextColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: _AppColors.secondaryTextColor,
        ),
        onTap: onTapAction,
      ),
    );
  }
}
