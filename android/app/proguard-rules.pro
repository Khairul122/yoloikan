# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Play Store split-install (deferred components) — tidak dipakai
# di app ini, tapi referensinya ada di io.flutter.embedding.engine
-dontwarn com.google.android.play.core.**

# Ultralytics YOLO / TFLite (model loading via reflection, JNI)
-keep class com.ultralytics.yolo.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.**
