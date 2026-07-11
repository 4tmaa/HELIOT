import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      return formatter.format(amount);
    } catch (e) {
      return amount.toString();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi': return Colors.orangeAccent.shade700;
      case 'dirakit':
      case 'proses': return Colors.blueAccent;
      case 'selesai': return Colors.green;
      case 'dibatalkan': return Colors.redAccent;
      default: return AppColors.primaryColor;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
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
            child: Text(label, style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.mainTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
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
            child: Text(label, style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13)),
          ),
          Expanded(
            child: Text(formattedText.trim(), style: const TextStyle(color: AppColors.mainTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(orderData['status'] ?? '');
    final bool hasAdminNotes = orderData['admin_notes'] != null && orderData['admin_notes'].toString().trim().isNotEmpty;
    final bool hasFinalPrice = orderData['final_price'] != null && orderData['final_price'] > 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainTextColor),
        title: const Text('Detail Pesanan', style: TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
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
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(orderData['status'] ?? 'Menunggu Konfirmasi', style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tanggal Pengajuan: ${_formatDate(orderData['created_at'])}', style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 12)),
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mark_email_unread_outlined, color: Colors.orange.shade800, size: 20),
                        const SizedBox(width: 8),
                        Text('Catatan Admin', style: TextStyle(color: Colors.orange.shade800, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(orderData['admin_notes'], style: const TextStyle(color: AppColors.mainTextColor, fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Identitas Pemesan', Icons.person_outline),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  _buildDataRow('Nama Lengkap', orderData['customer_name'] ?? '-'),
                  _buildDataRow('No. Telepon', orderData['customer_phone'] ?? '-'),
                  _buildDataRow('Alamat Tujuan', orderData['shipping_address'] ?? '-'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Spesifikasi Proyek', Icons.memory),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  _buildDataRow('Nama Proyek', orderData['project_title'] ?? '-'),
                  _buildComponentList('Mikrokontroler', orderData['mcu_list']),
                  _buildComponentList('Sensor', orderData['sensor_list']),
                  _buildDataRow('Konektivitas', orderData['connectivity'] ?? '-'),
                  _buildDataRow('Platform Output', orderData['output_platform'] ?? '-'),
                  _buildDataRow('Sumber Daya', orderData['power_supply'] ?? '-'),
                  _buildDataRow('Bentuk Fisik', orderData['enclosure'] ?? '-'),
                  
                  const SizedBox(height: 16),
                  const Text('Deskripsi Cara Kerja:', style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(orderData['description'] ?? '-', style: const TextStyle(color: AppColors.mainTextColor, fontSize: 13, height: 1.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: hasFinalPrice ? AppColors.primaryColor : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(16), 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimasi Awal', style: TextStyle(color: hasFinalPrice ? Colors.white70 : AppColors.secondaryTextColor, fontSize: 14)),
                      Text(_formatCurrency(orderData['estimated_price']), style: TextStyle(color: hasFinalPrice ? Colors.white70 : AppColors.mainTextColor, fontSize: 14, decoration: hasFinalPrice ? TextDecoration.lineThrough : null)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Harga Final', style: TextStyle(color: hasFinalPrice ? Colors.white : AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(hasFinalPrice ? _formatCurrency(orderData['final_price']) : 'Menunggu Admin', style: TextStyle(color: hasFinalPrice ? Colors.white : AppColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}