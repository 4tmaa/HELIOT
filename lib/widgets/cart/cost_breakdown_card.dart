import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:heliot/utils/app_colors.dart';

class CostBreakdownCard extends StatelessWidget {
  final int componentCost;
  final int serviceFee;
  final int total;

  const CostBreakdownCard({
    super.key,
    required this.componentCost,
    required this.serviceFee,
    required this.total,
  });

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Rincian Estimasi Biaya', style: TextStyle(color: AppColors.mainTextColor, fontSize: 17, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Komponen Pasti', style: TextStyle(color: AppColors.secondaryTextColor, fontWeight: FontWeight.w500)),
              Text(_formatCurrency(componentCost), style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimasi Jasa Perakitan', style: TextStyle(color: AppColors.secondaryTextColor, fontWeight: FontWeight.w500)),
              Text(_formatCurrency(serviceFee), style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Total Estimasi\nSementara', style: TextStyle(color: AppColors.mainTextColor, fontSize: 15, fontWeight: FontWeight.bold, height: 1.3)),
              Text(_formatCurrency(total), style: const TextStyle(color: AppColors.primaryColor, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Item dengan label "Harga Menyusul" (seperti Aplikasi, Baterai, atau Enclosure) akan dihitung manual oleh admin dan diinformasikan kepada Anda untuk persetujuan akhir.',
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 11, fontWeight: FontWeight.w500, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}