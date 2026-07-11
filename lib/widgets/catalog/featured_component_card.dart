import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/services/cart_service.dart';
import 'diagonal_banner_painter.dart';

class FeaturedComponentCard extends StatelessWidget {
  final dynamic product;

  const FeaturedComponentCard({super.key, required this.product});

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = product['photo_url'];
    final int difficulty = (product['difficulty_score'] as num?)?.toInt() ?? 0;
    final String category = product['category'] ?? '';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: CustomPaint(
                size: const Size(90, 90),
                painter: DiagonalBannerPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          photoUrl != null && photoUrl.toString().isNotEmpty
                              ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey)))
                              : const Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.grey)),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    product['name'] ?? '',
                    style: const TextStyle(color: AppColors.mainTextColor, fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['brief_description'] ?? 'Belum ada deskripsi singkat untuk komponen utama ini.',
                    style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13, height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga', style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(_formatCurrency((product['base_price'] as num?)?.toInt() ?? 0), style: const TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Kesulitan', style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                    5,
                                    (index) => Icon(
                                          index < difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
                                          color: Colors.orange,
                                          size: 20,
                                        )),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              CartService.instance.addComponent(product);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product['name']} ditambahkan ke pesanan', style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.primaryColor, duration: const Duration(seconds: 1)));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                              child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    ],
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