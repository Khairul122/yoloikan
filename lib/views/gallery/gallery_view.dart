import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/gallery_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/permission_helper.dart';
import '../../models/detection_result.dart';
import '../../services/history_repository.dart';
import '../../services/ikan_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/result_card.dart';
import '../../widgets/settings_widgets.dart';
import '../detail/species_detail_view.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: l10n.uploadGalleryTitle),
      body: Consumer<GalleryController>(
        builder: (context, ctrl, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final previewHeight = (constraints.maxHeight * 0.30).clamp(
                160.0,
                260.0,
              );
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).padding.bottom + 88,
                ),
                child: ResponsiveCenter(
                  maxWidth: 720,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ImagePreviewZone(ctrl: ctrl, height: previewHeight),
                      const SizedBox(height: 20),
                      if (ctrl.isLoading) _buildLoading(l10n),
                      if (ctrl.error != null) _buildError(l10n, ctrl),
                      if (ctrl.hasResults) ...[
                        Text(
                          l10n.detectionResults,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tapResultHint,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        ...ctrl.results.asMap().entries.map(
                          (e) => ResultCard(
                            result: e.value,
                            rank: e.key + 1,
                            isLowConfidence:
                                e.value.classIndex ==
                                AppConstants.nonFishClassIndex,
                            onTap:
                                (e.value.classIndex >= 0 &&
                                    e.value.classIndex !=
                                        AppConstants.nonFishClassIndex)
                                ? () => _openDetail(context, ctrl, e.value)
                                : null,
                          ),
                        ),
                      ],
                      if (!ctrl.isLoading &&
                          !ctrl.hasResults &&
                          ctrl.pickedImage == null)
                        _buildEmptyHint(l10n),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: const _PickImageFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    GalleryController ctrl,
    DetectionResult result,
  ) async {
    if (result.classIndex == AppConstants.nonFishClassIndex) return;

    final species = await IkanRepository.findById(result.classIndex);
    if (species == null || !context.mounted) return;

    // Ambil bytes dari file gambar sebagai foto di halaman detail
    Uint8List? photoBytes;
    try {
      photoBytes = await ctrl.pickedImage?.readAsBytes();
    } catch (_) {}

    if (!context.mounted) return;
    final timestamp = DateTime.now();
    try {
      await HistoryRepository.add(
        classIndex: result.classIndex,
        className: species.nama,
        confidence: result.confidence,
        photo: photoBytes,
      );
    } catch (e) {
      debugPrint('[GalleryView] gagal menyimpan riwayat: $e');
    }

    if (!context.mounted) return;
    Navigator.of(context).pushNamed(
      AppConstants.detailRoute,
      arguments: SpeciesDetailArgs(
        className: result.label,
        confidence: result.confidence,
        species: species,
        photo: photoBytes,
        timestamp: timestamp,
      ),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 14),
            Text(l10n.analyzingImage),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, GalleryController ctrl) {
    final msg = switch (ctrl.error!) {
      GalleryError.modelLoadFailed => l10n.modelLoadFailedMsg,
      GalleryError.noDetection => l10n.noFishDetectedMsg,
      GalleryError.unknown => l10n.unknownErrorMsg(ctrl.errorDetail ?? ''),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          l10n.emptyGalleryHint,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ImagePreviewZone extends StatelessWidget {
  final GalleryController ctrl;
  final double height;
  const _ImagePreviewZone({required this.ctrl, required this.height});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _showPickSourceSheet(context),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ctrl.pickedImage == null
                ? AppColors.primary.withValues(alpha: 0.25)
                : Colors.transparent,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          boxShadow: [AppColors.cardShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: ctrl.pickedImage != null
            ? Image.file(ctrl.pickedImage!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: (height * 0.22).clamp(36.0, 52.0),
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 10),
                  Text(l10n.tapToPickPhoto, style: AppTextStyles.bodyMedium),
                ],
              ),
      ),
    );
  }
}

class _PickImageFab extends StatelessWidget {
  const _PickImageFab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: () => _showPickSourceSheet(context),
      backgroundColor: AppColors.primary,
      elevation: 4,
      icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
      label: Text(l10n.pickImage, style: AppTextStyles.labelLarge),
    );
  }
}

/// Tampilkan bottom sheet untuk memilih sumber gambar (kamera/galeri),
/// lalu jalankan deteksi pada GalleryController.
void _showPickSourceSheet(BuildContext context) {
  final ctrl = context.read<GalleryController>();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PickSourceSheet(ctrl: ctrl),
  );
}

class _PickSourceSheet extends StatelessWidget {
  final GalleryController ctrl;
  const _PickSourceSheet({required this.ctrl});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    if (source == ImageSource.camera) {
      final granted = await PermissionHelper.requestCamera();
      if (!granted) {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cameraPermissionRequired)));
        return;
      }
    }
    await ctrl.pickAndDetect(source);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  l10n.chooseImageSource,
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ),
            GroupCard(
              children: [
                ActionRow(
                  icon: Icons.camera_alt_outlined,
                  label: l10n.takePhoto,
                  onTap: () => _pick(context, ImageSource.camera),
                ),
                ActionRow(
                  icon: Icons.photo_library_outlined,
                  label: l10n.pickFromGallery,
                  onTap: () => _pick(context, ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
