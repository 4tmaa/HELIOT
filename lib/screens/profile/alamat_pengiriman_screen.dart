import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../utils/app_colors.dart';
import '../../widgets/custom_toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/local_db_service.dart';

class AlamatPengirimanScreen extends StatefulWidget {
  const AlamatPengirimanScreen({super.key});

  @override
  State<AlamatPengirimanScreen> createState() => _AlamatPengirimanScreenState();
}

class _AlamatPengirimanScreenState extends State<AlamatPengirimanScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  final MapController _mapController = MapController();
  
  bool isLoading = false;
  bool isDetectingLocation = false;
  
  LatLng currentLatLng = const LatLng(-6.175392, 106.827153);
  Marker? _currentMarker;

  late TextEditingController addressController;
  late TextEditingController detailController;
  late TextEditingController postalCodeController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
    detailController = TextEditingController();
    postalCodeController = TextEditingController();
    
    _fetchExistingAddress();
  }

  @override
  void dispose() {
    addressController.dispose();
    detailController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingAddress() async {
    final activeUser = supabaseClient.auth.currentUser;
    if (activeUser == null) return;

    try {
      final cachedAddress = await LocalDatabaseService.instance.getCachedData('shipping_address');
      if (cachedAddress != null && mounted) {
        setState(() {
          _updateAddressState(cachedAddress);
        });
      }

      final addressData = await supabaseClient
          .from('shipping_addresses')
          .select()
          .eq('user_id', activeUser.id)
          .maybeSingle();

      if (addressData != null) {
        await LocalDatabaseService.instance.saveToCache('shipping_address', addressData);
        if (mounted) {
          setState(() {
            _updateAddressState(addressData);
          });
        }
      } else if (cachedAddress == null) {
        _setMarker(currentLatLng);
      }
    } catch (e) {
      _setMarker(currentLatLng);
    }
  }

  void _updateAddressState(Map<String, dynamic> addressData) {
    addressController.text = addressData['full_address'] ?? '';
    detailController.text = addressData['landmark'] ?? '';
    postalCodeController.text = addressData['postal_code'] ?? '';
    
    if (addressData['latitude'] != null && addressData['longitude'] != null) {
      currentLatLng = LatLng(addressData['latitude'], addressData['longitude']);
      _setMarker(currentLatLng);
      _mapController.move(currentLatLng, 15.0);
    } else {
      _setMarker(currentLatLng);
    }
  }

  void _setMarker(LatLng position) {
    setState(() {
      currentLatLng = position;
      _currentMarker = Marker(
        point: position,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isDetectingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      _mapController.move(newPosition, 16.0);
      _setMarker(newPosition);
      await _getAddressFromLatLng(position.latitude, position.longitude);

    } catch (e) {
      if (mounted) {
        CustomToast.show(context, message: e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          isDetectingLocation = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];

        List<String> rawParts = [
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
          place.subAdministrativeArea ?? '',
          place.administrativeArea ?? ''
        ];

        List<String> cleanParts = [];
        for (String part in rawParts) {
          if (part.trim().isNotEmpty && !cleanParts.contains(part)) {
            cleanParts.add(part);
          }
        }

        if (mounted) {
          setState(() {
            addressController.text = cleanParts.join(', ');
            postalCodeController.text = place.postalCode ?? '';
          });
        }
        return;
      }
    } catch (e) {}

    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1&accept-language=id');

      final response = await http.get(url, headers: {
        'User-Agent': 'com.tugasakhir.iotbuilder' 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['address'] != null) {
          final address = data['address'];

          final jalan = address['road'] ?? '';
          final dusun = address['hamlet'] ?? address['neighbourhood'] ?? '';
          final desa = address['village'] ?? address['suburb'] ?? address['residential'] ?? '';
          final kecamatan = address['city_district'] ?? address['town'] ?? address['county'] ?? '';
          final kota = address['city'] ?? address['municipality'] ?? address['state_district'] ?? '';
          final provinsi = address['state'] ?? address['region'] ?? '';

          List<String> rawParts = [jalan, dusun, desa, kecamatan, kota, provinsi];
          List<String> cleanParts = [];

          for (String part in rawParts) {
            if (part.trim().isNotEmpty && !cleanParts.contains(part)) {
              cleanParts.add(part);
            }
          }

          if (mounted) {
            setState(() {
              addressController.text = cleanParts.isNotEmpty ? cleanParts.join(', ') : (data['display_name'] ?? '');
              postalCodeController.text = address['postcode'] ?? '';
            });
          }
        }
      }
    } catch (fallbackError) {
      if (mounted) {
        CustomToast.show(context, message: 'Gagal mendeteksi lokasi. Periksa koneksi internet.', type: ToastType.error);
      }
    }
  }

  Future<void> _saveAddress() async {
    if (addressController.text.trim().isEmpty) {
      CustomToast.show(context, message: 'Alamat utama belum terdeteksi.', type: ToastType.warning);
      return;
    }

    setState(() => isLoading = true);

    try {
      final activeUserId = supabaseClient.auth.currentUser!.id;

      final existingAddress = await supabaseClient
          .from('shipping_addresses')
          .select('id')
          .eq('user_id', activeUserId)
          .maybeSingle();

      final addressDataToSave = {
        'user_id': activeUserId,
        'full_address': addressController.text.trim(),
        'landmark': detailController.text.trim(),
        'postal_code': postalCodeController.text.trim(),
        'latitude': currentLatLng.latitude,
        'longitude': currentLatLng.longitude,
        'is_default': true,
      };

      if (existingAddress != null) {
        await supabaseClient
            .from('shipping_addresses')
            .update(addressDataToSave)
            .eq('user_id', activeUserId);
      } else {
        await supabaseClient
            .from('shipping_addresses')
            .insert(addressDataToSave);
      }

      await LocalDatabaseService.instance.saveToCache('shipping_address', addressDataToSave);

      if (mounted) {
        CustomToast.show(context, message: 'Alamat pengiriman berhasil diperbarui.', type: ToastType.success);
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        CustomToast.show(context, message: 'Gagal menyimpan: ${error.toString()}', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainTextColor),
        title: const Text('Alamat Pengiriman', style: TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: currentLatLng,
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) {
                          _setMarker(point);
                          _getAddressFromLatLng(point.latitude, point.longitude);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.osm.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tugasakhir.iotbuilder',
                        ),
                        MarkerLayer(
                          markers: [
                            if (_currentMarker != null) _currentMarker!
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        onPressed: isDetectingLocation ? null : _getCurrentLocation,
                        child: isDetectingLocation 
                            ? const CircularProgressIndicator(color: AppColors.backgroundColor) 
                            : const Icon(Icons.my_location, color: AppColors.backgroundColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: addressController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.mainTextColor),
              decoration: InputDecoration(
                labelText: 'Detail Alamat Utama',
                filled: true,
                fillColor: AppColors.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: detailController,
              style: const TextStyle(color: AppColors.mainTextColor),
              decoration: InputDecoration(
                labelText: 'Patokan / Detail Pendukung',
                hintText: 'Misal: Samping pos satpam',
                hintStyle: const TextStyle(color: AppColors.secondaryTextColor),
                filled: true,
                fillColor: AppColors.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.home_work_outlined, color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: postalCodeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.mainTextColor),
              decoration: InputDecoration(
                labelText: 'Kode Pos',
                filled: true,
                fillColor: AppColors.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.markunread_mailbox_outlined, color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ? null : _saveAddress,
                child: isLoading
                    ? const CircularProgressIndicator(color: AppColors.backgroundColor)
                    : const Text('Simpan Alamat', style: TextStyle(color: AppColors.backgroundColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}