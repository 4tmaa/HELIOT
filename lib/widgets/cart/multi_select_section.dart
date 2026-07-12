import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/services/cart_service.dart';

class MultiSelectSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Map<String, dynamic>> sourceList;
  final List<Map<String, dynamic>> selectedList;
  final bool isMCU;
  final bool isLoading;

  const MultiSelectSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sourceList,
    required this.selectedList,
    required this.isMCU,
    required this.isLoading,
  });

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _showSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 5,
                width: 50,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Pilih $title', style: const TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: sourceList.isEmpty
                    ? const Center(child: Text('Data tidak tersedia', style: TextStyle(color: AppColors.secondaryTextColor)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sourceList.length,
                        itemBuilder: (context, index) {
                          final item = sourceList[index];
                          final price = (item['base_price'] as num?)?.toInt() ?? 0;
                          final diff = (item['difficulty_score'] as num?)?.toInt();
                          final bool isTBD = item['is_tbd'] == true;
                          final String tbdLabel = item['tbd_label'] ?? 'Harga Menyusul';
                          
                          return GestureDetector(
                            onTap: () {
                              CartService.instance.addComponent(item);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item['photo_url'] != null && item['photo_url'].toString().isNotEmpty
                                          ? Image.network(
                                              item['photo_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(icon, color: Colors.grey.shade400, size: 20),
                                            )
                                          : Icon(icon, color: Colors.grey.shade400, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'], style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                        if (diff != null && diff > 0) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                            child: Text('Tingkat Kesulitan: $diff', style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        ]
                                      ],
                                    ),
                                  ),
                                  Text(
                                    isTBD ? tbdLabel : (price == 0 ? 'Gratis' : '+ ${_formatCurrency(price)}'),
                                    style: TextStyle(color: isTBD ? Colors.orange.shade700 : AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.mainTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 12)),
        const SizedBox(height: 12),
        if (selectedList.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedList.length,
            itemBuilder: (context, index) {
              final sel = selectedList[index];
              final item = sel['item'];
              final qty = sel['qty'];
              final price = (item['base_price'] as num?)?.toInt() ?? 0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.08), 
                      blurRadius: 6, 
                      offset: const Offset(0, 3)
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item['photo_url'] != null && item['photo_url'].toString().isNotEmpty
                            ? Image.network(
                                item['photo_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(icon, color: Colors.grey.shade400, size: 24),
                              )
                            : Icon(icon, color: Colors.grey.shade400, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: const TextStyle(color: AppColors.mainTextColor, fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: price == 0 ? Colors.green.withValues(alpha: 0.1) : AppColors.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              price == 0 ? 'Gratis' : _formatCurrency(price),
                              style: TextStyle(
                                color: price == 0 ? Colors.green.shade700 : AppColors.primaryColor, 
                                fontSize: 12, 
                                fontWeight: FontWeight.w900
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => CartService.instance.updateQty(item, -1, isMCU),
                            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.remove, size: 16, color: AppColors.mainTextColor)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text('$qty', style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          InkWell(
                            onTap: () => CartService.instance.updateQty(item, 1, isMCU),
                            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add, size: 16, color: AppColors.primaryColor)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isLoading ? null : () => _showSelectionModal(context),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(selectedList.isEmpty ? 'Pilih $title' : 'Tambah $title', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}