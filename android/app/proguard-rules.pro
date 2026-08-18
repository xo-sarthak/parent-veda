# =============================================================================
#  R8 keep rules
# -----------------------------------------------------------------------------
#  WHY THIS FILE EXISTS, precisely:
#
#  The release APK crashed on launch with
#
#      java.lang.RuntimeException: Unable to start receiver
#        com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
#      Caused by: java.lang.RuntimeException: Missing type parameter.
#
#  and the debug APK was fine. That gap IS the diagnosis: R8 only runs on
#  release, and the stack frames carry `r8-map-id-...`, so the code that failed
#  had been shrunk and renamed.
#
#  `flutter_local_notifications` persists scheduled notifications as JSON and
#  reads them back with Gson, via `new TypeToken<ArrayList<NotificationDetails>>(){}`.
#  Gson recovers the element type at runtime from the GENERIC SIGNATURE attribute
#  that javac writes into the class file. R8 drops that attribute unless told to
#  keep it, so `TypeToken` finds a raw `ArrayList` with no parameter and throws.
#
#  ⚠️ THE GENERAL LESSON, worth more than the fix: anything that reads its own
#  types at runtime -- Gson, Moshi, Jackson, most reflection -- has a dependency
#  the compiler cannot see, so a shrinker has no reason to preserve it. The
#  failure always looks like "works in debug, dies in release", and it always
#  looks like a bug in the plugin rather than in the build.
#
#  ⚠️ AND IT ONLY FIRES ON A REAL DEVICE LAUNCH. `flutter analyze` is clean,
#  every unit test passes, and the debug build on the same phone is perfect. The
#  only thing that catches it is installing the artifact you actually intend to
#  ship and opening it, which is why that is now a step rather than an
#  afterthought.
# =============================================================================

# Keep the generic signatures Gson reads. This one line is the actual fix.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Gson's own reflection entry points.
-dontwarn com.google.gson.**
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# The plugin's model classes are serialised by name, so renaming breaks the
# round trip even when the signature survives.
-keep class com.dexterous.** { *; }

# Razorpay ships its own reflective checkout models and documents this keep.
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# WebRTC and the passkey plugins also load classes by name from native code.
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Flutter's embedding, deferred components and plugin registrant.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
