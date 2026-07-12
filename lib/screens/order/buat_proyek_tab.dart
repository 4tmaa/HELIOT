import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:heliot/utils/app_colors.dart';
import 'package:heliot/services/cart_service.dart';
import '../../services/local_db_service.dart';
import 'package:heliot/widgets/custom_toast.dart';
import 'package:heliot/screens/profile/edit_profil_screen.dart';
import 'package:heliot/screens/profile/alamat_pengiriman_screen.dart';
import 'komponen_selection_card.dart';
import '../../widgets/cart/multi_select_section.dart';
import '../../widgets/cart/project_identity_form.dart';
import '../../widgets/cart/cost_breakdown_card.dart';

class BuatProyekTab extends StatefulWidget {
  final VoidCallback onProjectSubmitted;

  const BuatProyekTab({super.key, required this.onProjectSubmitted});

  @override
  State<BuatProyekTab> createState() => _BuatProyekTabState();
}

class _BuatProyekTabState extends State<BuatProyekTab> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  Map<String, dynamic>? _selectedConnectivity;
  Map<String, dynamic>? _selectedEnclosure;
  Map<String, dynamic>? _selectedOutput;
  Map<String, dynamic>? _selectedPower;
  
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  List<Map<String, dynamic>> _mcuList = [];
  List<Map<String, dynamic>> _sensorList = [];
  List<Map<String, dynamic>> _connectivityList = [];
  List<Map<String, dynamic>> _enclosureList = [];
  List<Map<String, dynamic>> _outputList = [];
  List<Map<String, dynamic>> _powerList = [];

  int _baseServiceFee = 25000;
  int _difficultyMultiplier = 15000;

  @override
  void initState() {
    super.initState();
    if (CartService.instance.initialProjectTitle != null) {
      _titleController.text = CartService.instance.initialProjectTitle!;
    }
    if (CartService.instance.initialProjectDescription != null) {
      _descriptionController.text = CartService.instance.initialProjectDescription!;
    }
    
    _fetchAllOptions();
    CartService.instance.selectedMCUs.addListener(_onCartChanged);
    CartService.instance.selectedSensors.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService.instance.selectedMCUs.removeListener(_onCartChanged);
    CartService.instance.selectedSensors.removeListener(_onCartChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchAllOptions() async {
    // Helper function to handle caching
    Future<dynamic> _fetchWithCache(String cacheKey, Future<dynamic> Function() fetchCallback) async {
      final cached = await LocalDatabaseService.instance.getCachedData(cacheKey);
      if (cached != null) return cached;
      final result = await fetchCallback();
      if (result != null) {
        await LocalDatabaseService.instance.saveToCache(cacheKey, result);
      }
      return result;
    }

    try {
      final compRes = await _fetchWithCache('components_proyek', () => supabaseClient.from('components').select('name, category, base_price, difficulty_score'));
      if (compRes != null && mounted) {
        setState(() {
          _mcuList = List<Map<String, dynamic>>.from(compRes.where((e) => e['category'] == 'Mikrokontroler'));
          _sensorList = List<Map<String, dynamic>>.from(compRes.where((e) => e['category'] == 'Sensor'));
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat komponen');
    }

    try {
      final connRes = await _fetchWithCache('connectivity_options', () => supabaseClient.from('connectivity_options').select('name, base_price'));
      if (connRes != null && mounted) setState(() => _connectivityList = List<Map<String, dynamic>>.from(connRes));
    } catch (e) {
      debugPrint('Gagal memuat konektivitas');
    }

    try {
      final enclRes = await _fetchWithCache('enclosure_options', () => supabaseClient.from('enclosure_options').select('name, base_price'));
      if (enclRes != null && mounted) {
        setState(() {
          _enclosureList = List<Map<String, dynamic>>.from((enclRes as List).map((e) => {
            ...(e as Map<String, dynamic>),
            'is_tbd': true,
            'tbd_label': 'Menyesuaikan dimensi',
            'base_price': 0,
          }));
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat enclosure');
    }

    try {
      final outRes = await _fetchWithCache('output_options', () => supabaseClient.from('output_options').select('name, base_price, difficulty_score'));
      if (outRes != null && mounted) {
        setState(() {
          _outputList = List<Map<String, dynamic>>.from((outRes as List).map((e) {
            final map = e as Map<String, dynamic>;
            final name = map['name'].toString().toLowerCase();
            final isDynamic = name.contains('aplikasi') || name.contains('web');
            return {
              ...map,
              'is_tbd': isDynamic,
              'tbd_label': isDynamic ? 'Menyesuaikan fitur' : null,
              'base_price': isDynamic ? 0 : map['base_price'],
            };
          }));
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat output');
    }

    try {
      final pwrRes = await _fetchWithCache('power_options', () => supabaseClient.from('power_options').select('name, base_price, difficulty_score'));
      if (pwrRes != null && mounted) {
        setState(() {
          _powerList = List<Map<String, dynamic>>.from((pwrRes as List).map((e) {
            final map = e as Map<String, dynamic>;
            final name = map['name'].toString().toLowerCase();
            final isDynamic = !name.contains('kabel') && !name.contains('gratis') && !name.contains('tidak ada');
            return {
              ...map,
              'is_tbd': isDynamic,
              'tbd_label': isDynamic ? 'Menyesuaikan spek' : null,
              'base_price': isDynamic ? 0 : map['base_price'],
            };
          }));
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat power');
    }

    try {
      final settingsRes = await _fetchWithCache('pricing_settings', () => supabaseClient.from('pricing_settings').select('base_service_fee, difficulty_multiplier').maybeSingle());
      if (settingsRes != null && mounted) {
        setState(() {
          _baseServiceFee = (settingsRes['base_service_fee'] as num?)?.toInt() ?? 25000;
          _difficultyMultiplier = (settingsRes['difficulty_multiplier'] as num?)?.toInt() ?? 15000;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat pengaturan harga');
    }

    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  Map<String, int> _calculateCosts() {
    int componentCost = 0;
    int totalDifficulty = 0;

    final currentMCUs = CartService.instance.selectedMCUs.value;
    for (var mcu in currentMCUs) {
      final price = (mcu['item']['base_price'] as num?)?.toInt() ?? 0;
      final diff = (mcu['item']['difficulty_score'] as num?)?.toInt() ?? 0;
      final qty = mcu['qty'] as int;
      componentCost += price * qty;
      totalDifficulty += diff * qty;
    }

    final currentSensors = CartService.instance.selectedSensors.value;
    for (var sensor in currentSensors) {
      final price = (sensor['item']['base_price'] as num?)?.toInt() ?? 0;
      final diff = (sensor['item']['difficulty_score'] as num?)?.toInt() ?? 0;
      final qty = sensor['qty'] as int;
      componentCost += price * qty;
      totalDifficulty += diff * qty;
    }

    if (_selectedConnectivity != null) {
      componentCost += (_selectedConnectivity!['base_price'] as num?)?.toInt() ?? 0;
    }

    if (_selectedOutput != null) {
      componentCost += (_selectedOutput!['base_price'] as num?)?.toInt() ?? 0;
      totalDifficulty += (_selectedOutput!['difficulty_score'] as num?)?.toInt() ?? 0;
    }

    if (_selectedPower != null) {
      componentCost += (_selectedPower!['base_price'] as num?)?.toInt() ?? 0;
      totalDifficulty += (_selectedPower!['difficulty_score'] as num?)?.toInt() ?? 0;
    }

    int serviceFee = currentMCUs.isEmpty && currentSensors.isEmpty 
        ? 0 
        : _baseServiceFee + (totalDifficulty * _difficultyMultiplier);

    return {
      'componentCost': componentCost,
      'serviceFee': serviceFee,
      'total': componentCost + serviceFee,
    };
  }

  void _showIncompleteProfileDialog(String message, Widget destinationScreen) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Profil Belum Lengkap', style: TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppColors.secondaryTextColor, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti', style: TextStyle(color: AppColors.secondaryTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => destinationScreen));
            },
            child: const Text('Lengkapi Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProject() async {
    final currentMCUs = CartService.instance.selectedMCUs.value;
    final currentSensors = CartService.instance.selectedSensors.value;

    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty || currentMCUs.isEmpty || currentSensors.isEmpty || _selectedPower == null || _selectedOutput == null) {
      CustomToast.show(context, message: 'Semua bidang wajib diisi.', type: ToastType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) throw Exception('Sesi tidak valid');

      final profileRes = await supabaseClient.from('profiles').select('full_name, phone_number').eq('id', activeUser.id).maybeSingle();
      if (profileRes == null || profileRes['full_name'] == null || profileRes['phone_number'] == null || profileRes['phone_number'].toString().isEmpty) {
        setState(() => _isSubmitting = false);
        _showIncompleteProfileDialog('Untuk memastikan pesanan Anda dapat diproses dan dihubungi oleh admin, silakan lengkapi Nama dan Nomor Telepon di profil Anda terlebih dahulu.', const EditProfilScreen());
        return;
      }

      final addressRes = await supabaseClient.from('shipping_addresses').select('full_address').eq('user_id', activeUser.id).maybeSingle();
      if (addressRes == null || addressRes['full_address'] == null || addressRes['full_address'].toString().isEmpty) {
        setState(() => _isSubmitting = false);
        _showIncompleteProfileDialog('Kami membutuhkan alamat pengiriman untuk mengirimkan alat yang sudah dirakit. Silakan atur alamat Anda terlebih dahulu.', const AlamatPengirimanScreen());
        return;
      }

      final costs = _calculateCosts();
      
      final mcuListData = currentMCUs.map((e) => {
        'name': e['item']['name'],
        'qty': e['qty'],
        'base_price': e['item']['base_price'],
        'difficulty_score': e['item']['difficulty_score'],
      }).toList();

      final sensorListData = currentSensors.map((e) => {
        'name': e['item']['name'],
        'qty': e['qty'],
        'base_price': e['item']['base_price'],
        'difficulty_score': e['item']['difficulty_score'],
      }).toList();

      await supabaseClient.from('orders').insert({
        'user_id': activeUser.id,
        'customer_name': profileRes['full_name'],
        'customer_phone': profileRes['phone_number'],
        'shipping_address': addressRes['full_address'],
        'project_title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'mcu_list': mcuListData,
        'sensor_list': sensorListData,
        'connectivity': _selectedConnectivity?['name'] ?? 'Tidak Ditentukan',
        'enclosure': _selectedEnclosure?['name'] ?? 'Tidak Ditentukan',
        'output_platform': _selectedOutput?['name'],
        'power_supply': _selectedPower?['name'],
        'estimated_price': costs['componentCost'],
        'service_fee': costs['serviceFee'],
        'status': 'Menunggu Konfirmasi',
      });

      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          CartService.instance.clearCart();
          _selectedConnectivity = null;
          _selectedEnclosure = null;
          _selectedOutput = null;
          _selectedPower = null;
        });
        widget.onProjectSubmitted();
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, message: 'Terjadi kesalahan: ${e.toString()}', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final costs = _calculateCosts();
    final currentMCUs = CartService.instance.selectedMCUs.value;
    final currentSensors = CartService.instance.selectedSensors.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryColor.withOpacity(0.2))),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryColor),
                SizedBox(width: 12),
                Expanded(child: Text('Biaya jasa otomatis dihitung berdasarkan tingkat kesulitan komponen yang dipilih.', style: TextStyle(color: AppColors.mainTextColor, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          MultiSelectSection(
            title: 'Mikrokontroler Utama *',
            subtitle: 'Pilih satu atau lebih otak sistem proyek.',
            icon: Icons.memory,
            sourceList: _mcuList,
            selectedList: currentMCUs,
            isMCU: true,
            isLoading: _isLoadingData,
          ),
          
          MultiSelectSection(
            title: 'Sensor & Aktuator *',
            subtitle: 'Pilih sensor yang dibutuhkan. Anda bisa memilih lebih dari satu.',
            icon: Icons.sensors,
            sourceList: _sensorList,
            selectedList: currentSensors,
            isMCU: false,
            isLoading: _isLoadingData,
          ),
          
          KomponenSelectionCard(
            title: 'Platform Output/Kontrol *',
            subtitle: 'Media untuk memantau data sensor Anda.',
            icon: Icons.dashboard,
            selectedValue: _selectedOutput,
            items: _outputList,
            isLoading: _isLoadingData,
            onSelected: (val) => setState(() => _selectedOutput = val),
          ),

          KomponenSelectionCard(
            title: 'Sumber Daya Listrik *',
            subtitle: 'Metode pemberian daya pada alat.',
            icon: Icons.battery_charging_full,
            selectedValue: _selectedPower,
            items: _powerList,
            isLoading: _isLoadingData,
            onSelected: (val) => setState(() => _selectedPower = val),
          ),

          KomponenSelectionCard(
            title: 'Modul Konektivitas',
            subtitle: 'Jalur komunikasi pengiriman data.',
            icon: Icons.wifi,
            selectedValue: _selectedConnectivity,
            items: _connectivityList,
            isLoading: _isLoadingData,
            onSelected: (val) => setState(() => _selectedConnectivity = val),
          ),
          
          KomponenSelectionCard(
            title: 'Bentuk Fisik (Enclosure)',
            subtitle: 'Pelindung fisik untuk komponen sirkuit.',
            icon: Icons.view_in_ar,
            selectedValue: _selectedEnclosure,
            items: _enclosureList,
            isLoading: _isLoadingData,
            onSelected: (val) => setState(() => _selectedEnclosure = val),
          ),
          
          const Divider(height: 32, color: Color(0xFFEEEEEE), thickness: 2),
          
          ProjectIdentityForm(
            titleController: _titleController,
            descriptionController: _descriptionController,
          ),
          
          const SizedBox(height: 32),
          
          if (costs['total']! > 0)
            CostBreakdownCard(
              componentCost: costs['componentCost']!,
              serviceFee: costs['serviceFee']!,
              total: costs['total']!,
            ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, elevation: 5, shadowColor: AppColors.primaryColor.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _isSubmitting || _isLoadingData ? null : _submitProject,
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Ajukan Pesanan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}