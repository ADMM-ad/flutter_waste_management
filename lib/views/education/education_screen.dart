import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EducationScreen extends StatefulWidget {
  final bool isNested;
  const EducationScreen({super.key, this.isNested = false});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Organik', 'icon': Icons.compost},
    {'title': 'Plastik', 'icon': Icons.local_drink_outlined},
    {'title': 'Kertas', 'icon': Icons.description_outlined},
    {'title': 'Prinsip 3R', 'icon': Icons.loop},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edukasi & Pedoman Sampah'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: _tabs.map((tab) => Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab['icon'] as IconData, size: 16),
                const SizedBox(width: 6),
                Text(tab['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrganicTab(),
          _buildPlasticTab(),
          _buildPaperTab(),
          _build3RTab(),
        ],
      ),
    );
  }

  Widget _buildOrganicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Sampah Organik (Mudah Terurai)',
            subtitle: 'Sampah dari sisa makanan dan bahan hayati alami yang dapat membusuk menjadi pupuk alami.',
            icon: Icons.compost,
            color: const Color(0xFF15803D),
            bgColor: const Color(0xFFDCFCE7),
          ),
          const SizedBox(height: 16),
          const Text('Contoh Sampah Organik:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildPillGrid([
            'Sisa Nasi & Sayur',
            'Kulit Buah & Biji',
            'Dedaunan Kering & Ranting',
            'Ampas Kopi & Teh',
            'Cangkang Telur',
            'Tulang Ikan & Daging',
          ], const Color(0xFF15803D)),
          const SizedBox(height: 16),
          const Text('Cara Penanganan & Daur Ulang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildStepCard(
            step: '1',
            title: 'Pisahkan dari Sampah Anorganik',
            desc: 'Jangan campur sisa makanan dengan plastik pembungkus atau staples kardus.',
          ),
          _buildStepCard(
            step: '2',
            title: 'Gunakan Tempat Sampah Tertutup',
            desc: 'Cegah bau tidak sedap dan perkembangbiakan lalat dengan menggunakan wadah berpenutup rapat.',
          ),
          _buildStepCard(
            step: '3',
            title: 'Olah Menjadi Kompos Organik',
            desc: 'Campur sampah basah dengan sekam atau tanah gembur dalam ember kompos untuk pupuk tanaman.',
          ),
        ],
      ),
    );
  }

  Widget _buildPlasticTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Sampah Plastik (Anorganik)',
            subtitle: 'Bahan polimer sintetis yang membutuhkan ratusan tahun untuk terurai. Wajib dipilah dan didaur ulang!',
            icon: Icons.local_drink_outlined,
            color: const Color(0xFF0284C7),
            bgColor: const Color(0xFFE0F2FE),
          ),
          const SizedBox(height: 16),
          const Text('Contoh Sampah Plastik:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildPillGrid([
            'Botol Air Mineral (PET)',
            'Gelas Plastik Minuman',
            'Kantong Kresek Belanja',
            'Wadah Sabun & Sampo (HDPE)',
            'Sedotan & Sendok Plastik',
            'Styrofoam & Kemasan Snack',
          ], const Color(0xFF0284C7)),
          const SizedBox(height: 16),
          const Text('Langkah Bijak Pengelolaan Plastik:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildStepCard(
            step: '1',
            title: 'Kosongkan & Bilas dari Sisa Cairan',
            desc: 'Botol dan gelas yang bersih memiliki nilai jual daur ulang jauh lebih tinggi di bank sampah.',
          ),
          _buildStepCard(
            step: '2',
            title: 'Pipihkan / Remas Wadah Plastik',
            desc: 'Meremas botol plastik menghemat volume tempat sampah hingga 70% dan memudahkan pengangkutan.',
          ),
          _buildStepCard(
            step: '3',
            title: 'Setorkan ke Bank Sampah atau Buat Ecobrick',
            desc: 'Manfaatkan kresek bersih untuk diisi padat ke dalam botol sebagai bahan bata ramah lingkungan.',
          ),
        ],
      ),
    );
  }

  Widget _buildPaperTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Sampah Kertas & Karton',
            subtitle: 'Material serat kayu yang sangat mudah didaur ulang menjadi bubur kertas dan karton kemasan baru.',
            icon: Icons.description_outlined,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFEF3C7),
          ),
          const SizedBox(height: 16),
          const Text('Contoh Sampah Kertas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildPillGrid([
            'Kardus Paket & Box Makanan',
            'Koran & Majalah Bekas',
            'Kertas Arsip & Buku Tulis',
            'Kantung Kertas (Paper Bag)',
            'Brosur & Selebaran Cetak',
          ], const Color(0xFFD97706)),
          const SizedBox(height: 16),
          const Text('Tips Pemilahan Kertas yang Benar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildStepCard(
            step: '1',
            title: 'Jaga Kertas Tetap Kering',
            desc: 'Kertas yang basah atau berjamur tidak dapat diproses oleh pabrik daur ulang.',
          ),
          _buildStepCard(
            step: '2',
            title: 'Hindari Kertas Bernoda Minyak',
            desc: 'Kertas minyak pembungkus gorengan atau nasi tidak dapat didaur ulang, masukkan ke residu.',
          ),
          _buildStepCard(
            step: '3',
            title: 'Bongkar dan Lipat Kardus',
            desc: 'Lepaskan selotip plastik dari kardus kemasan lalu lipat rata agar rapi saat dikumpulkan.',
          ),
        ],
      ),
    );
  }

  Widget _build3RTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Gerakan 3R (Reduce, Reuse, Recycle)',
            subtitle: 'Tiga prinsip dasar untuk meminimalkan timbulan sampah harian di tingkat rumah tangga.',
            icon: Icons.loop,
            color: AppColors.primary,
            bgColor: AppColors.primaryLight,
          ),
          const SizedBox(height: 16),
          _build3RCard(
            title: '1. REDUCE (Mengurangi)',
            desc: 'Mengurangi timbulan sampah dari sumbernya.',
            points: [
              'Bawa tas belanja kain sendiri saat berbelanja.',
              'Gunakan tumbler dan kotak makan pribadi.',
              'Tolak sedotan plastik dan kantong kresek berlebih.',
            ],
            color: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          _build3RCard(
            title: '2. REUSE (Menggunakan Kembali)',
            desc: 'Memanfaatkan kembali barang-barang yang masih layak pakai.',
            points: [
              'Gunakan toples kaca bekas untuk wadah bumbu.',
              'Manfaatkan sisi kosong kertas bekas untuk coretan/catatan.',
              'Donasikan pakaian atau barang bekas layak pakai.',
            ],
            color: const Color(0xFF0284C7),
          ),
          const SizedBox(height: 12),
          _build3RCard(
            title: '3. RECYCLE (Mendaur Ulang)',
            desc: 'Mengolah material sampah menjadi produk baru bermanfaat.',
            points: [
              'Pilah sampah di rumah sesuai 3 kategori utama.',
              'Setorkan sampah terpilah ke Bank Sampah terdekat.',
              'Dukung produk hasil daur ulang karya warga lokal.',
            ],
            color: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillGrid(List<String> items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildStepCard({required String step, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3RCard({required String title, required String desc, required List<String> points, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Divider(height: 20),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(p, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
