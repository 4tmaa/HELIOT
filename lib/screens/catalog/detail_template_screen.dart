import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/widgets/custom_toast.dart';
import 'package:heliot/services/cart_service.dart';
import 'package:heliot/screens/main_navigation.dart';

class DetailTemplateScreen extends StatefulWidget {
  final dynamic template;

  const DetailTemplateScreen({super.key, required this.template});

  @override
  State<DetailTemplateScreen> createState() => _DetailTemplateScreenState();
}

class _DetailTemplateScreenState extends State<DetailTemplateScreen> {
  bool _isLoading = false;
  bool _isFetchingComponents = true;
  List<Map<String, dynamic>> _components = [];

  @override
  void initState() {
    super.initState();
    _fetchComponents();
  }

  Future<void> _fetchComponents() async {
    try {
      final data = await Supabase.instance.client
          .from('template_components')
          .select('qty, components(*)')
          .eq('template_id', widget.template['id']);
      
      if (mounted) {
        setState(() {
          _components = List<Map<String, dynamic>>.from(data);
          _isFetchingComponents = false;
        });
      }
    } catch (e) {
      print('FETCH ERROR: $e');
      if (mounted) {
        setState(() {
          _isFetchingComponents = false;
        });
      }
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Harga Menyusul';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> _addToCart() async {
    if (_components.isEmpty) {
      CustomToast.show(context, message: 'Proyek ini belum memiliki komponen terdaftar.', type: ToastType.warning);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    for (var row in _components) {
      final component = row['components'] as Map<String, dynamic>;
      final int qty = row['qty'] as int;
      
      for (int i = 0; i < qty; i++) {
        CartService.instance.addComponent(component);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      CartService.instance.setProjectIdentity(
        widget.template['title'] ?? 'Proyek Baru',
        widget.template['description'] ?? '',
      );

      CustomToast.show(context, message: 'Berhasil memasukkan ${_components.length} jenis komponen ke pesanan!', type: ToastType.success);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 2),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.template['photo_url'];
    final String title = widget.template['title'] ?? 'Proyek Tanpa Nama';
    final String description = widget.template['description'] ?? 'Belum ada deskripsi lengkap untuk proyek ini.';
    final dynamic estimatedPrice = widget.template['estimated_price'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(204),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.mainTextColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: "template_image_\${widget.template['id'] ?? widget.template.hashCode}",
                    child: Container(
                      color: Colors.white,
                      child: photoUrl != null && photoUrl.toString().isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.developer_board, size: 80, color: Colors.grey)),
                            )
                          : const Center(child: Icon(Icons.developer_board, size: 80, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PROYEK',
                          style: TextStyle(color: AppColors.primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(color: AppColors.mainTextColor, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimasi Harga', style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(estimatedPrice),
                            style: const TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Deskripsi Proyek',
                        style: TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 14, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Komponen yang Didapat',
                        style: TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isFetchingComponents)
                        const Center(child: CircularProgressIndicator())
                      else if (_components.isEmpty)
                        const Text('Tidak ada data komponen.', style: TextStyle(color: AppColors.secondaryTextColor))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _components.length,
                          separatorBuilder: (context, index) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final row = _components[index];
                            final comp = row['components'];
                            final qty = row['qty'];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: comp['photo_url'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          comp['photo_url'], 
                                          fit: BoxFit.cover, 
                                          errorBuilder: (c,e,s) => const Icon(Icons.image, color: Colors.grey),
                                        ),
                                      )
                                    : const Icon(Icons.image_outlined, color: Colors.grey),
                              ),
                              title: Text(comp['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(comp['category'] ?? '', style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 12)),
                              trailing: Text('x$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryColor)),
                            );
                          },
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  )
                ]
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Gunakan Proyek',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
