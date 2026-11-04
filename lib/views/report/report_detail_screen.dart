import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/status_badge_widget.dart';
import 'create_report_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false)
          .fetchReportDetail(widget.reportId);
    });
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDeleteReport(ReportModel report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: Text('Apakah Anda yakin ingin membatalkan dan menghapus laporan "${report.trackingCode}"? Data yang dihapus tidak dapat dipulihkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final success = await reportProvider.deleteReport(report.id);
      if (!mounted) return;
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dihapus.'),
            backgroundColor: AppColors.primary,
          ),
        );
        navigator.pop();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(reportProvider.errorMessage ?? 'Gagal menghapus laporan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openEditReport(ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(editReport: report),
      ),
    ).then((_) {
      if (mounted) {
        Provider.of<ReportProvider>(context, listen: false).fetchReportDetail(report.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final report = reportProvider.currentReport;
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: reportProvider.isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : report == null
              ? Center(
                  child: Text(
                    reportProvider.errorMessage ?? 'Laporan tidak ditemukan',
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tracking code & Status header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Kode Pelacakan', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      report.trackingCode,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                StatusBadgeWidget(status: report.status),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  report.createdAt != null
                                      ? dateFormat.format(report.createdAt!.toLocal())
                                      : '-',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Urgensi: ${report.urgency.toUpperCase()}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // High-res Photo preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          report.photoUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      // Rejection Alert Card
                      if (report.status.toLowerCase() == 'rejected' &&
                          report.rejectionNote != null &&
                          report.rejectionNote!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.rejectedBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.rejected.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.error_outline, color: AppColors.rejected, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Alasan Penolakan Petugas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.rejected,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                report.rejectionNote!,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // AI Prediction Card if available
                      if (report.aiPredictedCategory != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Analisis AI MobileNetV2', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    Text(
                                      '${report.aiPredictedCategory} (${((report.aiConfidenceScore ?? 0) * 100).toStringAsFixed(1)}%)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Content details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kategori Sampah', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              report.category?.name ?? 'Umum',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 14),
                            const Text('Deskripsi', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              report.description,
                              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 14),
                            const Text('Skala Volume', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              report.scale.toUpperCase(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.address ?? 'Titik Koordinat GPS',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${report.latitude.toStringAsFixed(6)}, ${report.longitude.toStringAsFixed(6)}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _openGoogleMaps(report.latitude, report.longitude),
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text('Maps'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Interactive OSM Map
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(report.latitude, report.longitude),
                                    initialZoom: 15.5,
                                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.flutter_waste_management',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(report.latitude, report.longitude),
                                          width: 44,
                                          height: 44,
                                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Logs / Audit Timeline
                      if (report.statusLogs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Riwayat Perubahan Status',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: report.statusLogs.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final log = report.statusLogs[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${log.fromStatus.toUpperCase()} ➔ ${log.toStatus.toUpperCase()}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              log.createdAt != null
                                                  ? dateFormat.format(log.createdAt!.toLocal())
                                                  : '-',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                        if (log.notes != null && log.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            log.notes!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                        if (log.changedBy != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Diubah oleh: ${log.changedBy}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],

                      // Action Buttons for Citizen on Pending Report
                      if (report.status.toLowerCase() == 'pending') ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _confirmDeleteReport(report),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Hapus Laporan', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openEditReport(report),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit Laporan', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
