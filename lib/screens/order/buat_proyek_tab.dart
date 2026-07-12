import 'dart:convert';
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
  
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

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
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (CartService.instance.initialProjectTitle != null) {
      _titleController.text = CartService.instance.initialProjectTitle!;
    }
    if (CartService.instance.initialProjectDescription != null) {
      _descriptionController.text =
          CartService.instance.initialProjectDescription!;
    }

    _loadCachedOrderState().then((_) {
      _fetchAllOptions();
      _fetchUserProfile();
    });
    
    _titleController.addListener(_saveOrderState);
    _descriptionController.addListener(_saveOrderState);
    _userNameController.addListener(_saveOrderState);
    _userEmailController.addListener(_saveOrderState);
    _userPhoneController.addListener(_saveOrderState);

    CartService.instance.selectedMCUs.addListener(_onCartChanged);
    CartService.instance.selectedSensors.addListener(_onCartChanged);
  }

  Future<void> _loadCachedOrderState() async {
    final cachedStep = await LocalDatabaseService.instance.getCachedData('order_current_step');
    if (cachedStep != null && mounted) {
      setState(() {
        _currentStep = int.tryParse(cachedStep.toString()) ?? 0;
      });
    }

    final cachedForm = await LocalDatabaseService.instance.getCachedData('order_form_data');
    if (cachedForm != null && mounted) {
      setState(() {
        if (cachedForm['title'] != null && _titleController.text.isEmpty) _titleController.text = cachedForm['title'];
        if (cachedForm['desc'] != null && _descriptionController.text.isEmpty) _descriptionController.text = cachedForm['desc'];
        if (cachedForm['userName'] != null && _userNameController.text.isEmpty) _userNameController.text = cachedForm['userName'];
        if (cachedForm['userEmail'] != null && _userEmailController.text.isEmpty) _userEmailController.text = cachedForm['userEmail'];
        if (cachedForm['userPhone'] != null && _userPhoneController.text.isEmpty) _userPhoneController.text = cachedForm['userPhone'];
        if (cachedForm['output'] != null && _selectedOutput == null) _selectedOutput = cachedForm['output'];
        if (cachedForm['power'] != null && _selectedPower == null) _selectedPower = cachedForm['power'];
        if (cachedForm['connectivity'] != null && _selectedConnectivity == null) _selectedConnectivity = cachedForm['connectivity'];
        if (cachedForm['enclosure'] != null && _selectedEnclosure == null) _selectedEnclosure = cachedForm['enclosure'];
      });
    }
  }

  void _saveOrderState() {
    LocalDatabaseService.instance.saveToCache('order_current_step', _currentStep);
    LocalDatabaseService.instance.saveToCache('order_form_data', {
      'title': _titleController.text,
      'desc': _descriptionController.text,
      'userName': _userNameController.text,
      'userEmail': _userEmailController.text,
      'userPhone': _userPhoneController.text,
      'output': _selectedOutput,
      'power': _selectedPower,
      'connectivity': _selectedConnectivity,
      'enclosure': _selectedEnclosure,
    });
  }

  Future<void> _fetchUserProfile() async {
    final activeUser = supabaseClient.auth.currentUser;
    if (activeUser != null) {
      _userEmailController.text = activeUser.email ?? '';
      try {
        final profileData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', activeUser.id)
            .maybeSingle();
        
        if (mounted && profileData != null) {
          setState(() {
            _userNameController.text = profileData['full_name'] ?? '';
            _userPhoneController.text = profileData['phone_number'] ?? '';
          });
        }
      } catch (e) {
        debugPrint('Gagal memuat profil: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveOrderState);
    _descriptionController.removeListener(_saveOrderState);
    _userNameController.removeListener(_saveOrderState);
    _userEmailController.removeListener(_saveOrderState);
    _userPhoneController.removeListener(_saveOrderState);

    CartService.instance.selectedMCUs.removeListener(_onCartChanged);
    CartService.instance.selectedSensors.removeListener(_onCartChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPhoneController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchAllOptions() async {
    // Helper function to handle caching
    Future<dynamic> _fetchWithCache(
      String cacheKey,
      Future<dynamic> Function() fetchCallback,
    ) async {
      final cached = await LocalDatabaseService.instance.getCachedData(
        cacheKey,
      );
      if (cached != null) return cached;
      final result = await fetchCallback();
      if (result != null) {
        await LocalDatabaseService.instance.saveToCache(cacheKey, result);
      }
      return result;
    }

    try {
      final compRes = await _fetchWithCache(
        'components_proyek',
        () => supabaseClient
            .from('components')
            .select('name, category, base_price, difficulty_score'),
      );
      if (compRes != null && mounted) {
        setState(() {
          _mcuList = List<Map<String, dynamic>>.from(
            compRes.where((e) => e['category'] == 'Mikrokontroler'),
          );
          _sensorList = List<Map<String, dynamic>>.from(
            compRes.where((e) => e['category'] == 'Sensor'),
          );
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat komponen');
    }

    try {
      final connRes = await _fetchWithCache(
        'connectivity_options',
        () => supabaseClient
            .from('connectivity_options')
            .select('name, base_price'),
      );
      if (connRes != null && mounted)
        setState(
          () => _connectivityList = List<Map<String, dynamic>>.from(connRes),
        );
    } catch (e) {
      debugPrint('Gagal memuat konektivitas');
    }

    try {
      final enclRes = await _fetchWithCache(
        'enclosure_options',
        () =>
            supabaseClient.from('enclosure_options').select('name, base_price'),
      );
      if (enclRes != null && mounted) {
        setState(() {
          _enclosureList = List<Map<String, dynamic>>.from(
            (enclRes as List).map(
              (e) => {
                ...(e as Map<String, dynamic>),
                'is_tbd': true,
                'tbd_label': 'Menyesuaikan dimensi',
                'base_price': 0,
              },
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat enclosure');
    }

    try {
      final outRes = await _fetchWithCache(
        'output_options',
        () => supabaseClient
            .from('output_options')
            .select('name, base_price, difficulty_score'),
      );
      if (outRes != null && mounted) {
        setState(() {
          _outputList = List<Map<String, dynamic>>.from(
            (outRes as List).map((e) {
              final map = e as Map<String, dynamic>;
              final name = map['name'].toString().toLowerCase();
              final isDynamic =
                  name.contains('aplikasi') || name.contains('web');
              return {
                ...map,
                'is_tbd': isDynamic,
                'tbd_label': isDynamic ? 'Menyesuaikan fitur' : null,
                'base_price': isDynamic ? 0 : map['base_price'],
              };
            }),
          );
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat output');
    }

    try {
      final pwrRes = await _fetchWithCache(
        'power_options',
        () => supabaseClient
            .from('power_options')
            .select('name, base_price, difficulty_score'),
      );
      if (pwrRes != null && mounted) {
        setState(() {
          _powerList = List<Map<String, dynamic>>.from(
            (pwrRes as List).map((e) {
              final map = e as Map<String, dynamic>;
              final name = map['name'].toString().toLowerCase();
              final isDynamic =
                  !name.contains('kabel') &&
                  !name.contains('gratis') &&
                  !name.contains('tidak ada');
              return {
                ...map,
                'is_tbd': isDynamic,
                'tbd_label': isDynamic ? 'Menyesuaikan spek' : null,
                'base_price': isDynamic ? 0 : map['base_price'],
              };
            }),
          );
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat power');
    }

    try {
      final settingsRes = await _fetchWithCache(
        'pricing_settings',
        () => supabaseClient
            .from('pricing_settings')
            .select('base_service_fee, difficulty_multiplier')
            .maybeSingle(),
      );
      if (settingsRes != null && mounted) {
        setState(() {
          _baseServiceFee =
              (settingsRes['base_service_fee'] as num?)?.toInt() ?? 25000;
          _difficultyMultiplier =
              (settingsRes['difficulty_multiplier'] as num?)?.toInt() ?? 15000;
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
      componentCost +=
          (_selectedConnectivity!['base_price'] as num?)?.toInt() ?? 0;
    }

    if (_selectedOutput != null) {
      componentCost += (_selectedOutput!['base_price'] as num?)?.toInt() ?? 0;
      totalDifficulty +=
          (_selectedOutput!['difficulty_score'] as num?)?.toInt() ?? 0;
    }

    if (_selectedPower != null) {
      componentCost += (_selectedPower!['base_price'] as num?)?.toInt() ?? 0;
      totalDifficulty +=
          (_selectedPower!['difficulty_score'] as num?)?.toInt() ?? 0;
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
            Text(
              'Profil Belum Lengkap',
              style: TextStyle(
                color: AppColors.mainTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.secondaryTextColor,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Nanti',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationScreen),
              );
            },
            child: const Text(
              'Lengkapi Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProject() async {
    final currentMCUs = CartService.instance.selectedMCUs.value;
    final currentSensors = CartService.instance.selectedSensors.value;

    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        currentMCUs.isEmpty ||
        currentSensors.isEmpty ||
        _selectedPower == null ||
        _selectedOutput == null) {
      CustomToast.show(
        context,
        message: 'Semua bidang wajib diisi.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) throw Exception('Sesi tidak valid');

      final profileRes = await supabaseClient
          .from('profiles')
          .select('full_name, phone_number')
          .eq('id', activeUser.id)
          .maybeSingle();
      if (profileRes == null ||
          profileRes['full_name'] == null ||
          profileRes['phone_number'] == null ||
          profileRes['phone_number'].toString().isEmpty) {
        setState(() => _isSubmitting = false);
        _showIncompleteProfileDialog(
          'Untuk memastikan pesanan Anda dapat diproses dan dihubungi oleh admin, silakan lengkapi Nama dan Nomor Telepon di profil Anda terlebih dahulu.',
          const EditProfilScreen(),
        );
        return;
      }

      final addressRes = await supabaseClient
          .from('shipping_addresses')
          .select('full_address')
          .eq('user_id', activeUser.id)
          .maybeSingle();
      if (addressRes == null ||
          addressRes['full_address'] == null ||
          addressRes['full_address'].toString().isEmpty) {
        setState(() => _isSubmitting = false);
        _showIncompleteProfileDialog(
          'Kami membutuhkan alamat pengiriman untuk mengirimkan alat yang sudah dirakit. Silakan atur alamat Anda terlebih dahulu.',
          const AlamatPengirimanScreen(),
        );
        return;
      }

      final costs = _calculateCosts();

      final mcuListData = currentMCUs
          .map(
            (e) => {
              'name': e['item']['name'],
              'qty': e['qty'],
              'base_price': e['item']['base_price'],
              'difficulty_score': e['item']['difficulty_score'],
            },
          )
          .toList();

      final sensorListData = currentSensors
          .map(
            (e) => {
              'name': e['item']['name'],
              'qty': e['qty'],
              'base_price': e['item']['base_price'],
              'difficulty_score': e['item']['difficulty_score'],
            },
          )
          .toList();

      await supabaseClient.from('orders').insert({
        'user_id': activeUser.id,
        'customer_name': profileRes['full_name'],
        'customer_phone': profileRes['phone_number'],
        'shipping_address': addressRes['full_address'],
        'project_title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'mcu_list': mcuListData,
        'sensor_list': sensorListData,
        'connectivity': _selectedConnectivity != null ? jsonEncode(_selectedConnectivity) : null,
        'enclosure': _selectedEnclosure != null ? jsonEncode(_selectedEnclosure) : null,
        'output_platform': _selectedOutput != null ? jsonEncode(_selectedOutput) : null,
        'power_supply': _selectedPower != null ? jsonEncode(_selectedPower) : null,
        'estimated_price': costs['total'],
        'service_fee': costs['serviceFee'],
        'status': 'Menunggu Konfirmasi',
      });

      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          CartService.instance.clearCart();
          LocalDatabaseService.instance.saveToCache('order_current_step', 0);
          LocalDatabaseService.instance.saveToCache('order_form_data', null);
          _selectedConnectivity = null;
          _selectedEnclosure = null;
          _selectedOutput = null;
          _selectedPower = null;
        });
        widget.onProjectSubmitted();
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Terjadi kesalahan: ${e.toString()}',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      final currentMCUs = CartService.instance.selectedMCUs.value;
      final currentSensors = CartService.instance.selectedSensors.value;
      if (currentMCUs.isEmpty || currentSensors.isEmpty) {
        CustomToast.show(context, message: 'Silakan pilih mikrokontroler dan sensor terlebih dahulu.', type: ToastType.warning);
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedPower == null || _selectedOutput == null) {
        CustomToast.show(context, message: 'Platform Output dan Sumber Daya wajib diisi.', type: ToastType.warning);
        return;
      }
    } else if (_currentStep == 2) {
      if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty ||
          _userNameController.text.trim().isEmpty || _userEmailController.text.trim().isEmpty ||
          _userPhoneController.text.trim().isEmpty) {
        CustomToast.show(context, message: 'Semua kolom identitas wajib diisi.', type: ToastType.warning);
        return;
      }
    } else if (_currentStep == 3) {
      _submitProject();
      return;
    }
    setState(() {
      _currentStep += 1;
    });
    _saveOrderState();
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      _saveOrderState();
    }
  }

  Widget _buildStepHeader() {
    final steps = ['Komponen', 'Spesifikasi', 'Identitas', 'Rincian'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index % 2 == 1) {
            final stepIndex = index ~/ 2;
            final isActive = _currentStep > stepIndex;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4).copyWith(bottom: 16),
                height: 2,
                color: isActive ? AppColors.primaryColor : Colors.grey.shade300,
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isActive = _currentStep >= stepIndex;
          return Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isActive ? AppColors.primaryColor : Colors.grey.shade300,
                child: Text('${stepIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(steps[stepIndex], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppColors.primaryColor : Colors.grey)),
            ],
          );
        }),
      ),
    );
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
          _buildStepHeader(),

          if (_currentStep == 0) ...[
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
          ],

          if (_currentStep == 1) ...[
            KomponenSelectionCard(
              title: 'Platform Output (Opsional)',
              subtitle: 'Medium untuk memantau data perangkat.',
              icon: Icons.dashboard_customize,
              selectedValue: _selectedOutput,
              items: _outputList,
              isLoading: _isLoadingData,
              onSelected: (val) {
                setState(() => _selectedOutput = val);
                _saveOrderState();
              },
            ),
            const SizedBox(height: 16),
            KomponenSelectionCard(
              title: 'Sumber Daya Listrik *',
              subtitle: 'Metode pemberian daya pada alat.',
              icon: Icons.battery_charging_full,
              selectedValue: _selectedPower,
              items: _powerList,
              isLoading: _isLoadingData,
              onSelected: (val) {
                setState(() => _selectedPower = val);
                _saveOrderState();
              },
            ),
            const SizedBox(height: 16),
            KomponenSelectionCard(
              title: 'Modul Konektivitas',
              subtitle: 'Jalur komunikasi pengiriman data.',
              icon: Icons.wifi,
              selectedValue: _selectedConnectivity,
              items: _connectivityList,
              isLoading: _isLoadingData,
              onSelected: (val) {
                setState(() => _selectedConnectivity = val);
                _saveOrderState();
              },
            ),
            const SizedBox(height: 16),
            KomponenSelectionCard(
              title: 'Bentuk Fisik (Enclosure)',
              subtitle: 'Pelindung fisik komponen sirkuit.',
              icon: Icons.view_in_ar,
              selectedValue: _selectedEnclosure,
              items: _enclosureList,
              isLoading: _isLoadingData,
              onSelected: (val) {
                setState(() => _selectedEnclosure = val);
                _saveOrderState();
              },
            ),
          ],

          if (_currentStep == 2) ...[
            ProjectIdentityForm(
              titleController: _titleController,
              descriptionController: _descriptionController,
              userNameController: _userNameController,
              userEmailController: _userEmailController,
              userPhoneController: _userPhoneController,
            ),
          ],

          if (_currentStep == 3) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Biaya jasa otomatis dihitung berdasarkan tingkat kesulitan komponen yang dipilih.',
                      style: TextStyle(color: AppColors.mainTextColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (costs['total']! > 0)
              CostBreakdownCard(
                componentCost: costs['componentCost']!,
                serviceFee: costs['serviceFee']!,
                total: costs['total']!,
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Belum ada komponen yang dipilih.'),
                ),
              ),
          ],

          Container(
            margin: EdgeInsets.only(top: 32, bottom: 24 + MediaQuery.paddingOf(context).bottom),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.primaryColor),
                      ),
                      child: const Text('Kembali', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting || _isLoadingData ? null : _onStepContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting && _currentStep == 3
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep == 3 ? 'Ajukan Pesanan' : 'Selanjutnya',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
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
