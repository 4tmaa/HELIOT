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
    final bool isSelectedTBD = selectedValue != null && selectedValue!['is_tbd'] == true;
    final String selectedTBDLabel = selectedValue != null ? (selectedValue!['tbd_label'] ?? 'Harga Menyusul') : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.mainTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 12)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: isLoading ? null : () => _showSelectionModal(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selectedValue != null ? AppColors.primaryColor.withOpacity(0.5) : Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedValue != null ? selectedValue!['name'] : 'Ketuk untuk memilih',
                        style: TextStyle(color: selectedValue != null ? AppColors.mainTextColor : AppColors.secondaryTextColor, fontSize: 16, fontWeight: selectedValue != null ? FontWeight.bold : FontWeight.normal),
                      ),
                      if (selectedValue != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          isSelectedTBD 
                              ? selectedTBDLabel 
                              : ((selectedValue!['base_price'] as num).toInt() == 0 ? 'Tidak ada biaya tambahan' : _formatCurrency((selectedValue!['base_price'] as num).toInt())),
                          style: TextStyle(color: isSelectedTBD ? Colors.orange.shade700 : AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                  ),
                ),
                if (selectedValue != null && quantity != null && onQuantityChanged != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: quantity! > 1 ? () => onQuantityChanged!(quantity! - 1) : null,
                          child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.remove, size: 16, color: quantity! > 1 ? AppColors.mainTextColor : Colors.grey)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('$quantity', style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        InkWell(
                          onTap: () => onQuantityChanged!(quantity! + 1),
                          child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, size: 16, color: AppColors.mainTextColor)),
                        ),
                      ],
                    ),
                  )
                else
                  const Icon(Icons.arrow_forward_ios, color: AppColors.secondaryTextColor, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}