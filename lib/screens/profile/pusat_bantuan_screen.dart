import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PusatBantuanScreen extends StatefulWidget {
  const PusatBantuanScreen({super.key});

  @override
  State<PusatBantuanScreen> createState() => _PusatBantuanScreenState();
}

class _PusatBantuanScreenState extends State<PusatBantuanScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, String>> _allFaqs = [
    {
      'question': 'Bagaimana cara memesan proyek IoT?',
      'answer': 'Anda dapat memesan proyek melalui menu Pesanan. Isi formulir spesifikasi alat yang Anda inginkan, lalu tim kami akan meninjau dan memberikan estimasi biaya serta waktu pengerjaan.'
    },
    {
      'question': 'Apakah saya bisa memantau alat saya dari jarak jauh?',
      'answer': 'Tentu saja. Setelah proyek selesai dan alat terhubung ke internet, Anda dapat memantau dan mengendalikannya langsung melalui panel kontrol di aplikasi ini.'
    },
    {
      'question': 'Berapa lama estimasi pengerjaan sebuah proyek?',
      'answer': 'Waktu pengerjaan sangat bergantung pada tingkat kompleksitas sistem dan ketersediaan komponen. Rata-rata proyek standar diselesaikan dalam waktu 7 hingga 14 hari kerja.'
    },
    {
      'question': 'Apakah ada garansi untuk alat yang telah dibuat?',
      'answer': 'Kami memberikan garansi perbaikan selama 30 hari setelah alat diterima. Garansi berlaku untuk cacat produksi dan kesalahan sistem, namun tidak mencakup kerusakan fisik akibat kelalaian pengguna.'
    },
    {
      'question': 'Bagaimana jika saya ingin mengubah spesifikasi di tengah pengerjaan?',
      'answer': 'Perubahan spesifikasi dapat dilakukan dengan menghubungi admin melalui menu Hubungi Admin. Namun, hal ini mungkin akan memengaruhi estimasi biaya dan memperpanjang waktu pengerjaan yang telah disepakati sebelumnya.'
    },
  ];

  List<Map<String, String>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs;
  }

  void _filterFaqs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = _allFaqs;
      } else {
        _filteredFaqs = _allFaqs.where((faq) {
          final questionLower = faq['question']!.toLowerCase();
          final answerLower = faq['answer']!.toLowerCase();
          final searchLower = query.toLowerCase();
          return questionLower.contains(searchLower) || answerLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text('Pusat Bantuan', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.help_rounded, size: 80, color: AppColors.primaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Halo, ada yang bisa dibantu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _searchController,
                  onChanged: _filterFaqs,
                  style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Cari topik atau pertanyaan...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredFaqs.isEmpty
                ? Center(
                    child: Text(
                      'Pertanyaan tidak ditemukan.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFaqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: AppColors.primaryColor,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            title: Text(
                              faq['question']!,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                child: Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}