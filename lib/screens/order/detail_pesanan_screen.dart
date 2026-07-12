import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/app_colors.dart';

class DetailPesananScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const DetailPesananScreen({super.key, required this.orderData});

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> with WidgetsBindingObserver {
  late Map<String, dynamic> _currentOrderData;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentOrderData = Map<String, dynamic>.from(widget.orderData);
    _setupRealtimeSubscription();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPaymentStatus();
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('status')
          .eq('id', _currentOrderData['id'])
          .maybeSingle();

      if (response != null && response['status'] != null) {
        final newStatus = response['status'];
        if (newStatus != _currentOrderData['status']) {
          if (mounted) {
            setState(() {
              _currentOrderData['status'] = newStatus;
            });
            if (newStatus == 'DIPROSES') {
              _showPaymentSuccessDialog();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error polling status: $e');
    }
  }

  void _setupRealtimeSubscription() {
    final orderId = _currentOrderData['id'];
    _realtimeChannel = Supabase.instance.client
        .channel('public:orders:id=$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['status'] != _currentOrderData['status']) {
              if (mounted) {
                setState(() {
                  _currentOrderData['status'] = newRecord['status'];
                  // Anda juga bisa mengupdate field lain jika diperlukan
                });
                
                // Jika status berubah menjadi DIPROSES (Artinya pembayaran berhasil)
                if (newRecord['status'] == 'DIPROSES') {
                  _showPaymentSuccessDialog();
                }
              }
            }
          },
        )
        .subscribe();
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Pembayaran Berhasil!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Terima kasih! Pembayaran Anda telah kami terima dan proyek Anda akan segera kami proses.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke riwayat pesanan agar refresh
              },
              child: const Text('Kembali ke Riwayat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

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
                'Total tagihan Anda adalah ${_formatCurrency(_currentOrderData['final_price'])}.\nSelesaikan pembayaran agar proyek dapat diproses.', 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey.shade600, height: 1.5)
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Tampilkan loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      // Panggil Edge Function Midtrans
                      final response = await Supabase.instance.client.functions.invoke(
                        'create_midtrans_transaction',
                        body: {'order_id': _currentOrderData['id']},
                      );

                      // Tutup loading dialog
                      if (context.mounted) Navigator.pop(context);

                      if (response.status == 200) {
                        final data = response.data;
                        if (data['success'] == true && data['redirect_url'] != null) {
                          final Uri url = Uri.parse(data['redirect_url']);
                          try {
                            // Tutup modal konfirmasi
                            if (context.mounted) Navigator.pop(context);
                            // Buka browser utama HP (disarankan untuk payment gateway agar deep-link e-wallet berfungsi)
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            throw Exception('Could not launch payment URL: $e');
                          }
                        } else {
                          throw Exception(data['error'] ?? 'Unknown error from server');
                        }
                      } else {
                        throw Exception('Failed to connect to payment server');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // close modal if still open
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memproses pembayaran: $e')),
                        );
                      }
                      debugPrint('Error payment: $e');
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Pesanan?'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus pesanan ini? Pesanan akan dibatalkan dan dihapus secara permanen dari riwayat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.from('orders').delete().eq('id', _currentOrderData['id']);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              } catch (e) {
                debugPrint('Error deleting order: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Batalkan Pesanan?'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.from('orders').update({'status': 'Dibatalkan'}).eq('id', _currentOrderData['id']);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              } catch (e) {
                debugPrint('Error cancelling order: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _parseSpec(dynamic specData) {
    if (specData == null || specData == '-' || specData == 'Tidak Ditentukan') return null;
    if (specData is Map<String, dynamic>) return specData;
    if (specData is String) {
      if (specData.trim().startsWith('{')) {
        try {
          return jsonDecode(specData);
        } catch (_) {}
      }
      return {'name': specData, 'base_price': 0};
    }
    return null;
  }

  Widget _buildCostRow(
    String label, 
    dynamic amount, {
    bool isSubtotal = false, 
    bool showIfZero = false,
    bool hasFinalPrice = false,
  }) {
    if (amount == null) return const SizedBox.shrink();
    if (amount == 0 && !showIfZero) return const SizedBox.shrink();

    String displayAmount;
    bool isPending = amount == 0 && showIfZero && !hasFinalPrice;

    if (amount == 0 && showIfZero) {
      displayAmount = hasFinalPrice ? 'Gratis' : 'Menyesuaikan';
    } else {
      displayAmount = _formatCurrency(amount);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSubtotal ? Colors.grey.shade800 : Colors.grey.shade600,
              fontSize: isSubtotal ? 14 : 13,
              fontWeight: isSubtotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            displayAmount,
            style: TextStyle(
              color: isPending ? Colors.orange.shade700 : (isSubtotal ? Colors.grey.shade800 : Colors.grey.shade600),
              fontSize: isSubtotal ? 14 : 13,
              fontWeight: isPending || isSubtotal ? FontWeight.bold : FontWeight.normal,
              fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_currentOrderData['status'] ?? '');
    final bool hasAdminNotes =
        _currentOrderData['admin_notes'] != null &&
        _currentOrderData['admin_notes'].toString().trim().isNotEmpty;
    final bool hasFinalPrice =
        _currentOrderData['final_price'] != null && _currentOrderData['final_price'] > 0;

    int mcuCost = 0;
    if (_currentOrderData['mcu_list'] is List) {
      for (var item in _currentOrderData['mcu_list']) {
        mcuCost += ((item['base_price'] as num?)?.toInt() ?? 0) * ((item['qty'] as num?)?.toInt() ?? 1);
      }
    }

    int sensorCost = 0;
    if (_currentOrderData['sensor_list'] is List) {
      for (var item in _currentOrderData['sensor_list']) {
        sensorCost += ((item['base_price'] as num?)?.toInt() ?? 0) * ((item['qty'] as num?)?.toInt() ?? 1);
      }
    }

    final connSpec = _parseSpec(_currentOrderData['connectivity']);
    final outSpec = _parseSpec(_currentOrderData['output_platform']);
    final pwrSpec = _parseSpec(_currentOrderData['power_supply']);
    final encSpec = _parseSpec(_currentOrderData['enclosure']);

    int connCost = (connSpec?['base_price'] as num?)?.toInt() ?? 0;
    int outCost = (outSpec?['base_price'] as num?)?.toInt() ?? 0;
    int pwrCost = (pwrSpec?['base_price'] as num?)?.toInt() ?? 0;
    int encCost = (encSpec?['base_price'] as num?)?.toInt() ?? 0;

    int identifiedComponentCost = mcuCost + sensorCost + connCost + outCost + pwrCost + encCost;
    int actualComponentCost = ((_currentOrderData['estimated_price'] as num?)?.toInt() ?? 0) - ((_currentOrderData['service_fee'] as num?)?.toInt() ?? 0);
    int unexplainedCost = actualComponentCost - identifiedComponentCost;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
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
                    _currentOrderData['status'] ?? 'Menunggu Konfirmasi',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal Pengajuan: ${_formatDate(_currentOrderData['created_at'])}',
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
                      _currentOrderData['admin_notes'],
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
                    _currentOrderData['customer_name'] ?? '-',
                  ),
                  _buildDataRow(
                    'No. Telepon',
                    _currentOrderData['customer_phone'] ?? '-',
                  ),
                  _buildDataRow(
                    'Alamat Tujuan',
                    _currentOrderData['shipping_address'] ?? '-',
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
                  _buildDataRow('Nama Proyek', _currentOrderData['project_title'] ?? '-'),
                  _buildComponentList('Mikrokontroler', _currentOrderData['mcu_list']),
                  _buildComponentList('Sensor', _currentOrderData['sensor_list']),
                  
                  _buildDataRow('Konektivitas', _parseSpec(_currentOrderData['connectivity'])?['name'] ?? '-'),
                  _buildDataRow('Platform Output', _parseSpec(_currentOrderData['output_platform'])?['name'] ?? '-'),
                  _buildDataRow('Sumber Daya', _parseSpec(_currentOrderData['power_supply'])?['name'] ?? '-'),
                  _buildDataRow('Bentuk Fisik', _parseSpec(_currentOrderData['enclosure'])?['name'] ?? '-'),

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
                      _currentOrderData['description'] ?? '-',
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
                  
                  _buildCostRow('Mikrokontroler', mcuCost),
                  _buildCostRow('Sensor & Aktuator', sensorCost),
                  _buildCostRow('Konektivitas', connCost, showIfZero: connSpec != null, hasFinalPrice: hasFinalPrice),
                  _buildCostRow('Platform Output', outCost, showIfZero: outSpec != null, hasFinalPrice: hasFinalPrice),
                  _buildCostRow('Sumber Daya', pwrCost, showIfZero: pwrSpec != null, hasFinalPrice: hasFinalPrice),
                  _buildCostRow('Bentuk Fisik', encCost, showIfZero: encSpec != null, hasFinalPrice: hasFinalPrice),
                  if (unexplainedCost > 0)
                    _buildCostRow('Spesifikasi Lainnya', unexplainedCost),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 1),
                  ),

                  _buildCostRow('Jasa Perakitan', _currentOrderData['service_fee'], isSubtotal: false),
                  
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
                        _formatCurrency(_currentOrderData['estimated_price']),
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: hasFinalPrice ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                  if (!hasFinalPrice) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Estimasi awal belum termasuk harga spesifikasi yang memerlukan penyesuaian fitur dan dimensi (contoh: Aplikasi, Baterai, Enclosure). Harga final akan diinformasikan oleh admin.',
                              style: TextStyle(color: Colors.orange.shade900, fontSize: 11, fontWeight: FontWeight.w500, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                        hasFinalPrice ? _formatCurrency(_currentOrderData['final_price']) : 'Menunggu Admin',
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

            if (hasFinalPrice && (_currentOrderData['status']?.toString().toLowerCase() == 'menunggu konfirmasi' || _currentOrderData['status']?.toString().toLowerCase() == 'menunggu pembayaran')) ...[
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
            
            if (_currentOrderData['status']?.toString().toLowerCase() != 'dibatalkan' && _currentOrderData['status']?.toString().toLowerCase() != 'selesai') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batalkan Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
