import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_helper.dart';
import '../../core/utils/ui_helpers.dart';
import '../../providers/ai_detection_provider.dart';
import '../../providers/report_form_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/ai_result_card_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/searchable_dropdown.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto fetch GPS location on screen open
      final formProvider = Provider.of<ReportFormProvider>(context, listen: false);
      formProvider.fetchLocation();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ambil Foto Sampah',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                  title: const Text('Buka Kamera'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await ImageHelper.pickFromCamera();
                    if (file != null) _processImage(file);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await ImageHelper.pickFromGallery();
                    if (file != null) _processImage(file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processImage(File file) {
    final formProvider = Provider.of<ReportFormProvider>(context, listen: false);
    formProvider.setImageFile(file);
  }

  Future<void> _analyzeWithAi() async {
    final formProvider = Provider.of<ReportFormProvider>(context, listen: false);
    final aiProvider = Provider.of<AiDetectionProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (formProvider.imageFile == null) return;

    final prediction = await aiProvider.analyzeImage(formProvider.imageFile!);
    if (prediction != null) {
      formProvider.setAiPrediction(prediction, reportProvider.categories);
      if (mounted) {
        UiHelpers.showSnackBar(
          context,
          'AI Terdeteksi: ${prediction.predictedClass} (${(prediction.confidenceScore * 100).toStringAsFixed(1)}%)',
          isSuccess: true,
        );
      }
    } else {
      if (mounted) {
        UiHelpers.showSnackBar(
          context,
          'Server AI sedang offline. Silakan pilih kategori secara manual di bawah.',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    final formProvider = Provider.of<ReportFormProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    formProvider.setDescription(_descriptionController.text);

    final report = await formProvider.submitReport();
    if (!mounted) return;

    if (report != null) {
      reportProvider.addReport(report);
      UiHelpers.showSnackBar(context, 'Laporan berhasil dikirim!', isSuccess: true);
      Navigator.of(context).pop();
    } else {
      UiHelpers.showSnackBar(
        context,
        formProvider.errorMessage ?? 'Gagal mengirim laporan',
        isError: true,
        onRetry: _handleSubmit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<ReportFormProvider>(context);
    final aiProvider = Provider.of<AiDetectionProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Laporan Baru'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Picker Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (formProvider.imageFile != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          formProvider.imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showImagePickerModal,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Ganti Foto'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: aiProvider.isAnalyzing ? null : _analyzeWithAi,
                              icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                              label: Text(
                                aiProvider.isAnalyzing ? 'Menganalisis...' : 'Cek Kategori AI',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text(
                                'Ambil Foto Sampah',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pilih foto, lalu gunakan tombol Cek AI atau input manual',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Analyzing Indicator or Result Card
              if (aiProvider.isAnalyzing)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'AI sedang menganalisis gambar sampah...',
                          style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                )
              else if (formProvider.aiPrediction != null)
                AiResultCardWidget(prediction: formProvider.aiPrediction!),

              const SizedBox(height: 16),

              // Form Inputs Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Searchable Dropdown (DESIGN.md Official)
                    SearchableDropdown<int>(
                      label: 'Kategori Sampah *',
                      placeholder: 'Cari atau pilih jenis sampah...',
                      selectedValue: formProvider.selectedCategoryId,
                      items: reportProvider.categories.map((cat) {
                        IconData icon;
                        final nameLower = cat.name.toLowerCase();
                        if (nameLower.contains('organ')) {
                          icon = Icons.eco;
                        } else if (nameLower.contains('plast')) {
                          icon = Icons.water_drop;
                        } else {
                          icon = Icons.description;
                        }
                        return SearchableDropdownItem<int>(
                          value: cat.id,
                          label: cat.name,
                          subtitle: cat.description,
                          icon: icon,
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) formProvider.setCategory(val);
                      },
                      validator: (val) => val == null ? 'Pilih salah satu kategori sampah' : null,
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    CustomTextField(
                      label: 'Deskripsi Kondisi Sampah *',
                      hint: 'Jelaskan kondisi tumpukan sampah, patokan jalan, dll...',
                      controller: _descriptionController,
                      maxLines: 3,
                      onChanged: (val) => formProvider.setDescription(val),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Deskripsi wajib diisi';
                        if (val.trim().length < 10) return 'Deskripsi minimal 10 karakter (saat ini ${val.trim().length})';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Scale Selector
                    const Text('Skala Volume Sampah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        expandedInsets: EdgeInsets.zero,
                        style: SegmentedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          selectedBackgroundColor: AppColors.primary,
                          selectedForegroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        segments: const [
                          ButtonSegment(value: 'small', label: Center(child: Text('Kecil'))),
                          ButtonSegment(value: 'medium', label: Center(child: Text('Sedang'))),
                          ButtonSegment(value: 'large', label: Center(child: Text('Besar'))),
                        ],
                        selected: {formProvider.scale},
                        onSelectionChanged: (val) {
                          formProvider.setScale(val.first);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Urgency Selector
                    const Text('Tingkat Urgensi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        expandedInsets: EdgeInsets.zero,
                        style: SegmentedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          selectedBackgroundColor: AppColors.primary,
                          selectedForegroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        segments: const [
                          ButtonSegment(value: 'low', label: Center(child: Text('Rendah'))),
                          ButtonSegment(value: 'medium', label: Center(child: Text('Sedang'))),
                          ButtonSegment(value: 'high', label: Center(child: Text('Darurat'))),
                        ],
                        selected: {formProvider.urgency},
                        onSelectionChanged: (val) {
                          formProvider.setUrgency(val.first);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // GPS Location Section
                    const Text('Lokasi Koordinat GPS *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  formProvider.isLocating
                                      ? 'Mendeteksi titik koordinat GPS...'
                                      : (formProvider.latitude != null
                                          ? 'Lat: ${formProvider.latitude!.toStringAsFixed(6)}, Long: ${formProvider.longitude!.toStringAsFixed(6)}'
                                          : 'Titik koordinat belum didapatkan'),
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.my_location, color: AppColors.primary),
                                tooltip: 'Ambil Ulang Lokasi',
                                onPressed: () => formProvider.fetchLocation(),
                              ),
                            ],
                          ),
                          if (formProvider.address != null && formProvider.address!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              formProvider.address!,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: 'Kirim Laporan Sampah',
                isLoading: formProvider.isSubmitting,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
