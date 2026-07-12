import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_toast.dart';

class HubungiAdminScreen extends StatefulWidget {
  const HubungiAdminScreen({super.key});

  @override
  State<HubungiAdminScreen> createState() => _HubungiAdminScreenState();
}

class _HubungiAdminScreenState extends State<HubungiAdminScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  
  bool _isSubmitting = false;
  String _selectedCategory = 'Pertanyaan Umum';
  
  final List<String> _categories = [
    'Pertanyaan Umum',
    'Kendala Teknis',
    'Status Pesanan',
    'Kerja Sama / Bisnis',
    'Lainnya'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      CustomToast.show(context, message: 'Pesan tidak boleh kosong.', type: ToastType.warning);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) throw Exception('Sesi tidak valid.');

      await supabaseClient.from('admin_messages').insert({
        'user_id': activeUser.id,
        'category': _selectedCategory,
        'message': _messageController.text.trim(),
      });

      if (mounted) {
        _messageController.clear();
        CustomToast.show(context, message: 'Pesan terkirim. Admin akan segera merespons.', type: ToastType.success);
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        CustomToast.show(context, message: 'Gagal mengirim pesan: ${error.toString()}', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainTextColor),
        title: const Text('Hubungi Admin', style: TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent, size: 64, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ada yang bisa kami bantu?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mainTextColor),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kirimkan pesan atau kendala Anda di bawah ini, tim kami akan membalas secepatnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryTextColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kategori Pesan', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        dropdownColor: AppColors.surfaceColor,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
                        style: const TextStyle(color: AppColors.mainTextColor, fontSize: 16),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Detail Pesan', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 6,
                    style: const TextStyle(color: AppColors.mainTextColor),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan pesan Anda secara detail di sini...',
                      hintStyle: const TextStyle(color: AppColors.secondaryTextColor),
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
                      contentPadding: const EdgeInsets.all(20),
                    ),
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
                      onPressed: _isSubmitting ? null : _sendMessage,
                      child: _isSubmitting
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.backgroundColor, strokeWidth: 3))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 20),
                                SizedBox(width: 12),
                                Text('Kirim Pesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
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
}