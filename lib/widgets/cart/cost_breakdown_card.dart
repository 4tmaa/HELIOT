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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Estimasi Biaya', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Komponen Pasti', style: TextStyle(color: AppColors.secondaryTextColor)),
              Text(_formatCurrency(componentCost), style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimasi Jasa Perakitan', style: TextStyle(color: AppColors.secondaryTextColor)),
              Text(_formatCurrency(serviceFee), style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimasi Sementara', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatCurrency(total), style: const TextStyle(color: AppColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '* Item dengan label "Harga Menyusul" (seperti Aplikasi, Baterai, atau Enclosure) akan dihitung manual oleh admin dan diinformasikan kepada Anda untuk persetujuan akhir.',
            style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}