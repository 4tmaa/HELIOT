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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text('Hubungi Admin', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.support_agent_rounded, size: 80, color: AppColors.primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Ada yang bisa kami bantu?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Kirimkan pesan atau kendala Anda di bawah ini, tim kami akan membalas secepatnya.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              const Text('Kategori Pesan', style: TextStyle(color: AppColors.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 16, fontWeight: FontWeight.w500),
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
              const Text('Detail Pesan', style: TextStyle(color: AppColors.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Tuliskan pesan Anda secara detail di sini...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _sendMessage,
                  child: _isSubmitting
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 12),
                            Text('Kirim Pesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}