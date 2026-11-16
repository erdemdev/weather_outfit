# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Google Play Core (referenced by Flutter deferred components)
-dontwarn com.google.android.play.core.**

# HTTP
-dontwarn okhttp3.**
-dontwarn okio.**
