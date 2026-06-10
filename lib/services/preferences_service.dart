import 'package:shared_preferences/shared_preferences.dart';

/// Stores simple user preferences that don't need reactive app-wide wiring.
class PreferencesService {
  PreferencesService._();

  static const _notificationKey = 'notification_enabled';

  static Future<bool> getNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationKey) ?? true;
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, enabled);
  }
}
