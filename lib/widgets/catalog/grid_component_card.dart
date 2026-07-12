import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/services/cart_service.dart';
import '../../screens/catalog/detail_komponen_screen.dart';
import '../custom_toast.dart';

class GridComponentCard extends StatelessWidget {
  final dynamic product;

  const GridComponentCard({super.key, required this.product});

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = product['photo_url'];
    final int difficulty = (product['difficulty_score'] as num?)?.toInt() ?? 0;
    final String category = product['category'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailKomponenScreen(product: product),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor, width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 3))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              color: Colors.grey.shade50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photoUrl != null && photoUrl.toString().isNotEmpty
                      ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey)))
                      : const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? '', style: const TextStyle(color: AppColors.mainTextColor, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(product['brief_description'] ?? 'Deskripsi produk...', style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: List.generate(5, (index) => Icon(index < difficulty ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.orange, size: 14))),
                          const SizedBox(height: 6),
                          Text(_formatCurrency((product['base_price'] as num?)?.toInt() ?? 0), style: const TextStyle(color: AppColors.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          CartService.instance.addComponent(product);
                          CustomToast.show(context, message: '${product['name']} ditambahkan', type: ToastType.success, duration: const Duration(seconds: 2));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}