import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/ikan_model.dart';
import '../../widgets/responsive_center.dart';

class SpeciesDetailArgs {
  final String className;
  final double confidence;
  final IkanModel species;
  final Uint8List? photo;
  final DateTime? timestamp;

  const SpeciesDetailArgs({
    required this.className,
    required this.confidence,
    required this.species,
    this.photo,
    this.timestamp,
  });
}

class SpeciesDetailView extends StatelessWidget {
  final SpeciesDetailArgs args;
  const SpeciesDetailView({super.key, required this.args});

  String _formatTimestamp(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final species = args.species;
    final pct = (args.confidence * 100).toStringAsFixed(1);
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final timestamp = args.timestamp ?? DateTime.now();
    final screenSize = MediaQuery.sizeOf(context);
    final headerHeight = (screenSize.height * 0.38).clamp(240.0, 420.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveCenter(
        maxWidth: 720,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: headerHeight,
              pinned: true,
              backgroundColor: species.warna,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _HeaderImage(
                  photo: args.photo,
                  species: species,
                  className: args.className,
                  confidence: pct,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama spesies
                    Text(species.nama, style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      args.className,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confidence pill + timestamp
                    Row(
                      children: [
                        _ConfidenceBadge(
                          confidence: pct,
                          color: species.warna,
                          l10n: l10n,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(timestamp),
                          style: AppTextStyles.monoData,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Divider(color: AppColors.outlineVariant, thickness: 1),
                    const SizedBox(height: 20),

                    // Label deskripsi
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: species.warna,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.description,
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    Text(
                      species.deskripsi,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.65),
                    ),

                    const SizedBox(height: 32),

                    // Tombol scan ulang
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.videocam_rounded, size: 18),
                        label: Text(l10n.scanAgain),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: species.warna,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header: foto kamera + AI bounding box label, atau gradient fallback ────

class _HeaderImage extends StatelessWidget {
  final Uint8List? photo;
  final IkanModel species;
  final String className;
  final String confidence;

  const _HeaderImage({
    required this.photo,
    required this.species,
    required this.className,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final p = photo;
    if (p != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(p, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  species.warna.withValues(alpha: 0.30),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$className $confidence%',
                style: AppTextStyles.monoData.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    // Fallback: gradient + ikon ikan
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            species.warna,
            species.warna.withValues(alpha: 0.70),
            AppColors.primary.withValues(alpha: 0.50),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.set_meal_rounded,
          size: 96,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

// ── Confidence badge ──────────────────────────────────────────────────────

class _ConfidenceBadge extends StatelessWidget {
  final String confidence;
  final Color color;
  final AppLocalizations l10n;
  const _ConfidenceBadge({
    required this.confidence,
    required this.color,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            l10n.confidentPercent(confidence),
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
