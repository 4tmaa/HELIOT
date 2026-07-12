import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/widgets/custom_toast.dart';
import 'package:heliot/services/cart_service.dart';
import 'package:heliot/screens/main_navigation.dart';

class DetailTemplateScreen extends StatefulWidget {
  final dynamic template;

  const DetailTemplateScreen({super.key, required this.template});

  @override
  State<DetailTemplateScreen> createState() => _DetailTemplateScreenState();
}

class _DetailTemplateScreenState extends State<DetailTemplateScreen> {
  bool _isLoading = false;

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Harga Menyusul';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> _addToCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await Supabase.instance.client
          .from('template_components')
          .select('qty, components(*)')
          .eq('template_id', widget.template['id']);

      if (data.isEmpty) {
        if (mounted) {
          CustomToast.show(context, message: 'Proyek ini belum memiliki komponen terdaftar.', type: ToastType.warning);
        }
      } else {
        for (var row in data) {
          final component = row['components'] as Map<String, dynamic>;
          final int qty = row['qty'] as int;
          
          for (int i = 0; i < qty; i++) {
            CartService.instance.addComponent(component);
          }
        }

        if (mounted) {
          CustomToast.show(context, message: 'Berhasil memasukkan \${data.length} jenis komponen ke pesanan!', type: ToastType.success);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 1),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, message: 'Gagal mengambil data komponen: \$e', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.template['photo_url'];
    final String title = widget.template['title'] ?? 'Proyek Tanpa Nama';
    final String description = widget.template['description'] ?? 'Belum ada deskripsi lengkap untuk proyek ini.';
    final dynamic estimatedPrice = widget.template['estimated_price'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(204),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.mainTextColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: "template_image_\${widget.template['id'] ?? widget.template.hashCode}",
                    child: Container(
                      color: Colors.white,
                      child: photoUrl != null && photoUrl.toString().isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.developer_board, size: 80, color: Colors.grey)),
                            )
                          : const Center(child: Icon(Icons.developer_board, size: 80, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PROYEK',
                          style: TextStyle(color: AppColors.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(color: AppColors.mainTextColor, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimasi Harga', style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(estimatedPrice),
                            style: const TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Deskripsi Proyek',
                        style: TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Gunakan Proyek',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
