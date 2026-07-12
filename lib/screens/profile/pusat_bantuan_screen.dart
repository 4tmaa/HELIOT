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
      'question': 'Apa itu aplikasi HELIOT?',
      'answer':
          'HELIOT adalah platform terpadu untuk mengeksplorasi katalog komponen elektronik, membeli template IoT, dan memesan proyek IoT kustom sesuai dengan kebutuhan Anda.',
    },
    {
      'question': 'Bagaimana cara membeli komponen atau template?',
      'answer':
          'Anda dapat menelusuri menu Katalog, menambahkan komponen atau template yang Anda butuhkan ke keranjang, dan melanjutkan proses checkout hingga selesai.',
    },
    {
      'question': 'Apakah saya bisa memesan proyek IoT khusus (kustom)?',
      'answer':
          'Tentu saja! Buka menu Pesanan dan pilih opsi Buat Proyek. Isi formulir spesifikasi secara detail, lalu tim kami akan meninjau dan memberikan estimasi biaya serta waktu pengerjaan.',
    },
    {
      'question': 'Bagaimana cara melacak status pesanan saya?',
      'answer':
          'Anda dapat memantau status semua pesanan Anda melalui menu Pesanan pada tab Riwayat Pesanan. Di sana Anda dapat melihat status mulai dari Menunggu Konfirmasi, Diproses, hingga Selesai.',
    },
    {
      'question': 'Apakah saya bisa mengubah pesanan yang sudah dibuat?',
      'answer':
          'Perubahan spesifikasi atau pembatalan hanya dapat dilakukan sebelum pesanan mulai diproses. Jika pesanan sudah berstatus Diproses, silakan gunakan menu Hubungi Admin untuk berdiskusi dengan tim kami.',
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
          return questionLower.contains(searchLower) ||
              answerLower.contains(searchLower);
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
        iconTheme: const IconThemeData(color: AppColors.mainTextColor),
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(
            color: AppColors.mainTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.help_rounded,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Halo, ada yang bisa dibantu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _searchController,
                  onChanged: _filterFaqs,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari topik atau pertanyaan...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
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
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: _filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFaqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
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
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
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
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 20,
                                ),
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
