// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navCamera => 'Camera';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get chooseMode => 'Choose Mode';

  @override
  String get realtimeDetection => 'Real-time Detection';

  @override
  String get useCameraDirect => 'Use the live camera';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get quickGuide => 'Quick Guide';

  @override
  String get goodLighting => 'Good Lighting';

  @override
  String get goodLightingDesc =>
      'Make sure the fish is clearly visible with good lighting for more accurate detection.';

  @override
  String get focusOnObject => 'Focus on the Object';

  @override
  String get focusOnObjectDesc =>
      'Aim the camera or pick a photo that shows the whole fish without other objects in the way.';

  @override
  String get welcomeTitle => 'Welcome to\nthe Data Ocean';

  @override
  String get welcomeDesc =>
      'Identify fish species quickly and accurately using Yolo technology.';

  @override
  String get uploadGalleryTitle => 'Upload Gallery';

  @override
  String get detectionResults => 'Detection Results';

  @override
  String get tapResultHint => 'Tap a result to view species details';

  @override
  String get analyzingImage => 'Analyzing image...';

  @override
  String get emptyGalleryHint =>
      'Tap the button below to\npick a fish photo from your gallery.';

  @override
  String get tapToPickPhoto => 'Tap to pick a photo';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get historyTitle => 'Detection History';

  @override
  String get clearHistoryDialogTitle => 'Clear History';

  @override
  String get searchSpeciesHint => 'Search species...';

  @override
  String get noMatchingResults => 'No matching results';

  @override
  String get noHistoryYet => 'No detection history yet';

  @override
  String get description => 'Description';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String confidentPercent(String value) {
    return '$value% confident';
  }

  @override
  String get liveDetection => 'Live Detection';

  @override
  String get targetLocked => 'Target Locked';

  @override
  String get accuracyLabel => 'Accuracy';

  @override
  String get aimCameraHint => 'Point the camera at a fish...';

  @override
  String get back => 'Back';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get cameraPermissionDesc =>
      'Allow camera access to use the real-time detection feature.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutAppSection => 'About App';

  @override
  String get appNameLabel => 'App Name';

  @override
  String get versionLabel => 'Version';

  @override
  String get modelAiLabel => 'Yolo Model';

  @override
  String get dataSection => 'Data';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteHistoryItemConfirm =>
      'This history item will be permanently deleted. Continue?';

  @override
  String get swipeToDeleteHint => 'Swipe left to delete an item';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get notification => 'Notification';

  @override
  String get notificationDesc => 'Receive notifications from the app';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Use a dark theme for the app';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Choose the app language';

  @override
  String get moreSection => 'More';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutApp => 'About App';

  @override
  String get featureInDevelopment => 'This feature is under development.';

  @override
  String get info => 'Info';

  @override
  String get ok => 'OK';

  @override
  String get developerSection => 'Developer';

  @override
  String get developerName => 'Name';

  @override
  String get developerNim => 'Student ID';

  @override
  String get chooseImageSource => 'Choose Image Source';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get lowConfidenceHint => 'Possibly not a fish';

  @override
  String get modelLoadFailedMsg =>
      'Failed to load Yolo model. Make sure the model file is valid.';

  @override
  String get noFishDetectedMsg => 'No fish detected. Try a clearer photo.';

  @override
  String get splashTagline => 'Yolo-Powered Marine Species Detection';

  @override
  String get initializingSystem => 'Initializing System';

  @override
  String unknownErrorMsg(String message) {
    return 'An error occurred: $message';
  }
}
