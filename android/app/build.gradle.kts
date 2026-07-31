plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.parentveda.app"
    // Bumped to 36 (Flutter's default is 34) because file_picker's transitive
    // dependency flutter_plugin_android_lifecycle now requires compiling against
    // API 36. This is compile-time only - minSdk/targetSdk are unchanged, so it
    // doesn't affect which devices can install or the app's runtime behaviour.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications (backports java.time on older APIs).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.parentveda.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Default label, overridden per flavour below. The manifest reads
        // ${appLabel} rather than hardcoding a name, so the two apps can differ
        // by one line here instead of by a second manifest to keep in step.
        manifestPlaceholders["appLabel"] = "ParentVeda"
    }

    // ---- Two apps, one codebase -------------------------------------------
    //
    // `parent` is the app as it has always been: same applicationId, so an
    // existing install UPDATES rather than appearing twice. Changing it would
    // orphan every device that already has the app, which is a migration, not
    // a rename.
    //
    // `doctor` (ParentVeda+) gets its own applicationId suffix, so it installs
    // ALONGSIDE the parent app rather than replacing it. That matters even
    // though a clinician would only have one: during testing, one phone
    // needs both.
    //
    // Entry point is chosen at build time, not here:
    //     flutter build apk --release --flavor parent
    //     flutter build apk --release --flavor doctor --target lib/main_doctor.dart
    flavorDimensions += "audience"
    productFlavors {
        create("parent") {
            dimension = "audience"
            manifestPlaceholders["appLabel"] = "ParentVeda"
        }
        create("doctor") {
            dimension = "audience"
            applicationIdSuffix = ".doctor"
            manifestPlaceholders["appLabel"] = "ParentVeda+"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring runtime for flutter_local_notifications.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
