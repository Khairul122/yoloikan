import 'package:flutter/material.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../models/detection_result.dart';
import 'confidence_bar.dart';

class ResultCard extends StatelessWidget {
  final DetectionResult result;
  final int rank;
  final VoidCallback? onTap;
  final bool isLowConfidence;

  const ResultCard({
    super.key,
    required this.result,
    required this.rank,
    this.onTap,
    this.isLowConfidence = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final confidenceColor = isLowConfidence
        ? AppColors.onSurfaceVariant
        : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rank == 1
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.set_meal_rounded,
                size: 20,
                color: rank == 1 ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          result.displayLabel,
                          style: AppTextStyles.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result.confidencePercent,
                        style: AppTextStyles.confidenceLabel.copyWith(
                          color: confidenceColor,
                        ),
                      ),
                    ],
                  ),
                  if (isLowConfidence) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.lowConfidenceHint,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  ConfidenceBar(value: result.confidence),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
