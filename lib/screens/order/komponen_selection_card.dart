import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';

class KomponenSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, dynamic>? selectedValue;
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final int? quantity;
  final ValueChanged<int>? onQuantityChanged;
  final bool isLoading;

  const KomponenSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
    this.quantity,
    this.onQuantityChanged,
    this.isLoading = false,
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
                child: items.isEmpty
                    ? const Center(child: Text('Data tidak tersedia', style: TextStyle(color: AppColors.secondaryTextColor)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = selectedValue != null && selectedValue!['name'] == item['name'];
                          final price = (item['base_price'] as num).toInt();
                          final bool isTBD = item['is_tbd'] == true;
                          final String tbdLabel = item['tbd_label'] ?? 'Harga Menyusul';
                          
                          return GestureDetector(
                            onTap: () {
                              onSelected(item);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(item['name'], style: TextStyle(color: isSelected ? AppColors.primaryColor : AppColors.mainTextColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
                                  ),
                                  Text(
                                    isTBD ? tbdLabel : (price == 0 ? 'Gratis' : '+ ${_formatCurrency(price)}'),
                                    style: TextStyle(color: isTBD ? Colors.orange.shade700 : AppColors.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 14),
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
    final bool isSelected = selectedValue != null;
    final bool isSelectedTBD = isSelected && selectedValue!['is_tbd'] == true;
    final String selectedTBDLabel = isSelected ? (selectedValue!['tbd_label'] ?? 'Harga Menyusul') : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => _showSelectionModal(context),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.02) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.5) : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isSelected ? AppColors.primaryColor : Colors.grey.shade600, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.mainTextColor)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryTextColor)),
                      
                      const SizedBox(height: 12),
                      if (isSelected) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedValue!['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 13),
                                ),
                              ),
                              if (quantity != null && onQuantityChanged != null) ...[
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: quantity! > 1 ? () => onQuantityChanged!(quantity! - 1) : null,
                                        child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.remove, size: 14, color: quantity! > 1 ? AppColors.mainTextColor : Colors.grey)),
                                      ),
                                      Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      InkWell(
                                        onTap: () => onQuantityChanged!(quantity! + 1),
                                        child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 14, color: AppColors.primaryColor)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelectedTBD ? Colors.orange.withValues(alpha: 0.1) : AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isSelectedTBD 
                                      ? selectedTBDLabel 
                                      : ((selectedValue!['base_price'] as num).toInt() == 0 ? 'Gratis' : '+ ${_formatCurrency((selectedValue!['base_price'] as num).toInt())}'),
                                  style: TextStyle(
                                    color: isSelectedTBD ? Colors.orange.shade800 : AppColors.primaryColor, 
                                    fontSize: 11, 
                                    fontWeight: FontWeight.w900
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: Colors.orange.shade400),
                            const SizedBox(width: 6),
                            Text('Belum dipilih', style: TextStyle(color: Colors.orange.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}