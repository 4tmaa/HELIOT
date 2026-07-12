import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import 'package:heliot/widgets/custom_loading.dart';
import 'detail_pesanan_screen.dart';

class RiwayatPesananTab extends StatefulWidget {
  const RiwayatPesananTab({super.key});

  @override
  State<RiwayatPesananTab> createState() => _RiwayatPesananTabState();
}

class _RiwayatPesananTabState extends State<RiwayatPesananTab> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() => _isLoading = true);

    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) return;

      final response = await supabaseClient
          .from('orders')
          .select()
          .eq('user_id', activeUser.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _orderHistory = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return isoString;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null || amount == 0) return 'Menunggu Estimasi';
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

  String _formatComponentList(dynamic listData) {
    if (listData == null) return '-';
    if (listData is List && listData.isNotEmpty) {
      final firstItem = listData[0]['name'] ?? 'Komponen';
      if (listData.length > 1) {
        return '$firstItem (+${listData.length - 1} lainnya)';
      }
      return firstItem;
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        itemCount: 4,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: CustomShimmerCard(height: 140, borderRadius: 16),
        ),
      );
    }

    if (_orderHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Riwayat',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proyek yang Anda ajukan akan muncul di sini.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: _fetchOrderHistory,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 100.0),
        itemCount: _orderHistory.length,
        itemBuilder: (context, index) {
          final order = _orderHistory[index];
          final statusColor = _getStatusColor(order['status'] ?? '');
          final String mcuDisplay = _formatComponentList(order['mcu_list']);
          final String sensorDisplay = _formatComponentList(
            order['sensor_list'],
          );

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPesananScreen(orderData: order),
                ),
              ).then((_) => _fetchOrderHistory());
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            order['project_title'] ?? 'Proyek Tanpa Nama',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            order['status'] ?? 'Menunggu',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.memory,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mcuDisplay,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.sensors,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sensorDisplay,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        color: Colors.grey.shade200,
                        height: 1,
                        thickness: 1.5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(order['created_at']),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          order['final_price'] != null &&
                                  order['final_price'] > 0
                              ? _formatCurrency(order['final_price'])
                              : _formatCurrency(order['estimated_price']),
                          style: TextStyle(
                            color:
                                order['final_price'] != null &&
                                    order['final_price'] > 0
                                ? AppColors.primaryColor
                                : Colors.grey.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
