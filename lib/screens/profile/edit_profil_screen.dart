import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/app_colors.dart';
import '../../widgets/custom_toast.dart';

class EditProfilScreen extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialAddress;

  const EditProfilScreen({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialEmail,
    this.initialAddress,
  });

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  bool isSaving = false;
  
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  String selectedCountryCode = '62';
  String selectedFlag = '🇮🇩';

  File? _avatarFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    emailController = TextEditingController(text: widget.initialEmail ?? '');
    addressController = TextEditingController(text: 'Memuat data...');
    phoneController = TextEditingController();

    _parseInitialPhoneNumber();
    _fetchData();
  }

  void _parseInitialPhoneNumber() {
    String rawPhone = widget.initialPhone ?? '';
    if (rawPhone != 'Belum diatur' && rawPhone.isNotEmpty) {
      if (rawPhone.startsWith('+')) {
        rawPhone = rawPhone.substring(1);
      }
      
      if (rawPhone.startsWith('62')) {
        selectedCountryCode = '62';
        selectedFlag = '🇮🇩';
        phoneController.text = rawPhone.substring(2);
      } else if (rawPhone.startsWith('1')) {
        selectedCountryCode = '1';
        selectedFlag = '🇺🇸';
        phoneController.text = rawPhone.substring(1);
      } else {
        phoneController.text = rawPhone;
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) return;

      final profileRes = await supabaseClient
          .from('profiles')
          .select('avatar_url')
          .eq('id', activeUser.id)
          .maybeSingle();

      final addressRes = await supabaseClient
          .from('shipping_addresses')
          .select('full_address, landmark, postal_code')
          .eq('user_id', activeUser.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (profileRes != null && profileRes['avatar_url'] != null) {
            _avatarUrl = profileRes['avatar_url'];
          }

          if (addressRes != null && addressRes['full_address'] != null && addressRes['full_address'].toString().isNotEmpty) {
            String full = addressRes['full_address'];
            if (addressRes['landmark'] != null && addressRes['landmark'].toString().isNotEmpty) {
              full += '\n(Patokan: ${addressRes['landmark']})';
            }
            if (addressRes['postal_code'] != null && addressRes['postal_code'].toString().isNotEmpty) {
              full += '\nKode Pos: ${addressRes['postal_code']}';
            }
            addressController.text = full;
          } else {
            addressController.text = 'Alamat belum diatur. Silakan atur di menu Alamat Pengiriman.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          addressController.text = 'Gagal memuat data.';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, message: 'Gagal membuka galeri.', type: ToastType.error);
      }
    }
  }

  Future<void> saveProfileData() async {
    setState(() {
      isSaving = true;
    });

    if (nameController.text.trim().isEmpty) {
      CustomToast.show(context, message: 'Nama Lengkap tidak boleh kosong.', type: ToastType.warning);
      setState(() => isSaving = false);
      return;
    }

    try {
      final activeUserId = supabaseClient.auth.currentUser!.id;
      String? finalImageUrl = _avatarUrl;

      if (_avatarFile != null) {
        final fileExt = _avatarFile!.path.split('.').last;
        final fileName = '${activeUserId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await supabaseClient.storage.from('avatars').upload(
          fileName,
          _avatarFile!,
          fileOptions: const FileOptions(upsert: true),
        );

        finalImageUrl = supabaseClient.storage.from('avatars').getPublicUrl(fileName);
      }

      final String fullPhoneNumber = phoneController.text.trim().isNotEmpty 
          ? '+$selectedCountryCode${phoneController.text.trim()}' 
          : '';

      await supabaseClient.from('profiles').upsert({
        'id': activeUserId,
        'full_name': nameController.text.trim(),
        'phone_number': fullPhoneNumber,
        'email': emailController.text.trim(),
        if (finalImageUrl != null) 'avatar_url': finalImageUrl,
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        CustomToast.show(context, message: 'Gagal menyimpan: ${error.toString()}', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.backgroundColor,
        textStyle: const TextStyle(color: AppColors.mainTextColor),
        searchTextStyle: const TextStyle(color: AppColors.mainTextColor),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          hintText: 'Cari negara...',
          hintStyle: const TextStyle(color: AppColors.secondaryTextColor),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          filled: true,
          fillColor: AppColors.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          selectedCountryCode = country.phoneCode;
          selectedFlag = country.flagEmoji;
        });
      },
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? AppColors.secondaryTextColor : AppColors.mainTextColor, 
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainTextColor),
        title: const Text('Edit Profil', style: TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surfaceColor,
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? NetworkImage(_avatarUrl!) as ImageProvider
                                : null,
                        child: _avatarFile == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 50, color: AppColors.secondaryTextColor)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Informasi Pribadi', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildModernTextField(
              controller: nameController,
              label: 'Nama Lengkap',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            
            _buildModernTextField(
              controller: emailController,
              label: 'Alamat Surel',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: _showCountryPicker,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Text(selectedFlag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text('+$selectedCountryCode', style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_drop_down, color: AppColors.secondaryTextColor),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: AppColors.secondaryTextColor.withOpacity(0.3)),
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.mainTextColor),
                      decoration: const InputDecoration(
                        hintText: '812 3456 7890',
                        hintStyle: TextStyle(color: AppColors.secondaryTextColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Informasi Pengiriman', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildModernTextField(
              controller: addressController,
              label: 'Alamat Lengkap',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              readOnly: true,
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.backgroundColor,
                  elevation: 5,
                  shadowColor: AppColors.primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isSaving ? null : saveProfileData,
                child: isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.backgroundColor, strokeWidth: 3))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}