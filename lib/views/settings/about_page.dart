import 'package:flutter/material.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/settings_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final modelFile = AppConstants.modelPath.split('/').last;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.aboutApp, style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.waves_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.appTagline,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(l10n.aboutAppSection, style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              GroupCard(
                children: [
                  InfoRow(
                    label: l10n.appNameLabel,
                    value: AppConstants.appName,
                  ),
                  InfoRow(
                    label: l10n.versionLabel,
                    value: AppConstants.appVersion,
                  ),
                  InfoRow(label: l10n.modelAiLabel, value: modelFile),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.developerSection, style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              GroupCard(
                children: [
                  InfoRow(label: l10n.developerName, value: 'JULIANA SARI'),
                  InfoRow(label: l10n.developerNim, value: '210180171'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
