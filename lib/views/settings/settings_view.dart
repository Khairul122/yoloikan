import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../controllers/locale_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/preferences_service.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/settings_widgets.dart';
import 'about_page.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    PreferencesService.getNotificationEnabled().then((value) {
      if (mounted) setState(() => _notificationEnabled = value);
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SystemNavigator.pop();
    }
  }

  Future<void> _showComingSoonDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.info),
        content: Text(l10n.featureInDevelopment),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(l10n.settingsTitle, style: AppTextStyles.titleLarge),
              const SizedBox(height: 20),
              const _ProfileHeader(),
              const SizedBox(height: 24),
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
                  InfoRow(
                    label: l10n.modelAiLabel,
                    value: AppConstants.modelPath.split('/').last,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.preferencesSection, style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              GroupCard(
                children: [
                  PreferenceSwitchRow(
                    icon: Icons.notifications_outlined,
                    label: l10n.notification,
                    subtitle: l10n.notificationDesc,
                    value: _notificationEnabled,
                    onChanged: (v) {
                      setState(() => _notificationEnabled = v);
                      PreferencesService.setNotificationEnabled(v);
                    },
                  ),
                  PreferenceSwitchRow(
                    icon: Icons.dark_mode_outlined,
                    label: l10n.darkMode,
                    subtitle: l10n.darkModeDesc,
                    value: themeController.isDark,
                    onChanged: (v) => themeController.setDarkMode(v),
                  ),
                  LanguageRow(
                    icon: Icons.language_rounded,
                    label: l10n.language,
                    subtitle: l10n.languageDesc,
                    value: localeController.locale.languageCode,
                    onChanged: (code) => localeController.setLocale(code),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.moreSection, style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              GroupCard(
                children: [
                  ActionRow(
                    icon: Icons.help_outline_rounded,
                    label: l10n.helpCenter,
                    onTap: () => _showComingSoonDialog(context),
                  ),
                  ActionRow(
                    icon: Icons.privacy_tip_outlined,
                    label: l10n.privacyPolicy,
                    onTap: () => _showComingSoonDialog(context),
                  ),
                  ActionRow(
                    icon: Icons.info_outline_rounded,
                    label: l10n.aboutApp,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.dataSection, style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              GroupCard(
                children: [
                  ActionRow(
                    icon: Icons.logout_rounded,
                    label: l10n.logout,
                    color: AppColors.error,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text('JULIANA SARI', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text('NIM: 210180171', style: AppTextStyles.monoData),
        ],
      ),
    );
  }
}
