# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.plugin.common.EventChannel { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }

-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
# Flutter deferred components - disable if not used
-dontwarn com.google.android.play.core.**

# Firebase Messaging Plugin
-keep class io.flutter.embedding.engine.FlutterEngine
-keep class io.flutter.plugin.common.MethodChannel
