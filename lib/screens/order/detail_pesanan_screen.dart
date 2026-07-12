import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../utils/app_colors.dart';

class DetailPesananScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const DetailPesananScreen({super.key, required this.orderData});

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return isoString;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null || amount == 0) return 'Menunggu Konfirmasi';
    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    } catch (e) {
      return amount.toString();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return Colors.orangeAccent.shade700;
      case 'dirakit':
      case 'proses':
        return Colors.blueAccent;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.redAccent;
      default:
        return AppColors.primaryColor;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList(String label, dynamic listData) {
    if (listData == null || (listData is List && listData.isEmpty)) {
      return _buildDataRow(label, '-');
    }

    String formattedText = '';
    if (listData is List) {
      for (var item in listData) {
        final name = item['name'] ?? 'Komponen';
        final qty = item['qty'] ?? 1;
        formattedText += '• $name (x$qty)\n';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              formattedText.trim(),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Icon(Icons.account_balance_wallet_rounded, size: 60, color: AppColors.primaryColor),
              const SizedBox(height: 16),
              const Text('Konfirmasi Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mainTextColor)),
              const SizedBox(height: 8),
              Text(
                'Total tagihan Anda adalah ${_formatCurrency(orderData['final_price'])}.\nSelesaikan pembayaran agar proyek dapat diproses.', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey.shade600, height: 1.5)
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client
                          .from('orders')
                          .update({'status': 'Proses'})
                          .eq('id', orderData['id']);
                      if (context.mounted) {
                        Navigator.pop(context); // close modal
                        Navigator.pop(context); // go back to riwayat pesanan
                      }
                    } catch (e) {
                      debugPrint('Error updating status: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(orderData['status'] ?? '');
    final bool hasAdminNotes =
        orderData['admin_notes'] != null &&
        orderData['admin_notes'].toString().trim().isNotEmpty;
    final bool hasFinalPrice =
        orderData['final_price'] != null && orderData['final_price'] > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.mainTextColor),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: AppColors.mainTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    orderData['status'] ?? 'Menunggu Konfirmasi',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal Pengajuan: ${_formatDate(orderData['created_at'])}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            if (hasAdminNotes) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.mark_email_unread_outlined,
                          color: Colors.orange.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Admin',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      orderData['admin_notes'],
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Identitas Pemesan',
                    Icons.person_outline,
                  ),
                  Divider(color: Colors.grey.shade200, thickness: 1.5),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    'Nama Lengkap',
                    orderData['customer_name'] ?? '-',
                  ),
                  _buildDataRow(
                    'No. Telepon',
                    orderData['customer_phone'] ?? '-',
                  ),
                  _buildDataRow(
                    'Alamat Tujuan',
                    orderData['shipping_address'] ?? '-',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Spesifikasi Proyek', Icons.memory),
                  Divider(color: Colors.grey.shade200, thickness: 1.5),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    'Nama Proyek',
                    orderData['project_title'] ?? '-',
                  ),
                  _buildComponentList('Mikrokontroler', orderData['mcu_list']),
                  _buildComponentList('Sensor', orderData['sensor_list']),
                  _buildDataRow(
                    'Konektivitas',
                    orderData['connectivity'] ?? '-',
                  ),
                  _buildDataRow(
                    'Platform Output',
                    orderData['output_platform'] ?? '-',
                  ),
                  _buildDataRow(
                    'Sumber Daya',
                    orderData['power_supply'] ?? '-',
                  ),
                  _buildDataRow('Bentuk Fisik', orderData['enclosure'] ?? '-'),

                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi Cara Kerja:',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      orderData['description'] ?? '-',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Rincian Biaya', Icons.receipt_long_rounded),
                  Divider(color: Colors.grey.shade200, thickness: 1.5),
                  const SizedBox(height: 12),
                  
                  _buildDataRow(
                    'Total Komponen',
                    _formatCurrency((orderData['estimated_price'] ?? 0) - (orderData['service_fee'] ?? 0))
                  ),
                  _buildDataRow(
                    'Jasa Perakitan',
                    _formatCurrency(orderData['service_fee'])
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5, height: 1),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimasi Awal',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatCurrency(orderData['estimated_price']),
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: hasFinalPrice ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Harga Final',
                        style: TextStyle(
                          color: AppColors.mainTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hasFinalPrice ? _formatCurrency(orderData['final_price']) : 'Menunggu Admin',
                        style: TextStyle(
                          color: hasFinalPrice ? AppColors.primaryColor : Colors.orange.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (hasFinalPrice && orderData['status']?.toString().toLowerCase() == 'menunggu konfirmasi') ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showPaymentModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Lanjut ke Pembayaran',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
