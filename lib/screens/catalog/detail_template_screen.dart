import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/widgets/custom_toast.dart';

class DetailTemplateScreen extends StatelessWidget {
  final dynamic template;

  const DetailTemplateScreen({super.key, required this.template});

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Harga Menyusul';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = template['photo_url'];
    final String title = template['title'] ?? 'Proyek Tanpa Nama';
    final String description = template['description'] ?? 'Belum ada deskripsi lengkap untuk templat ini.';
    final dynamic estimatedPrice = template['estimated_price'];

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
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.mainTextColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'template_image_${template['id'] ?? template.hashCode}',
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
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'TEMPLAT',
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
                        'Deskripsi Templat',
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
          
          // Fixed Bottom Bar
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
                onPressed: () {
                  // Currently just shows toast. In the future this can navigate to "Buat Proyek" and fill the cart.
                  CustomToast.show(context, message: 'Fitur pengisian otomatis dari templat segera hadir!', type: ToastType.info);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Gunakan Templat',
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
