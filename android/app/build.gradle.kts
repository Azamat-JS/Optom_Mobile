import java.util.Properties

// Google Maps key comes from bsmart/.env (MAPS_API_KEY) — the same file Flutter loads at runtime —
// so there's one place to set it. Read at build time: rebuild after changing it.
val mapsApiKey: String = rootProject.file("../.env").takeIf { it.exists() }
    ?.readLines()
    ?.map { it.trim() }
    ?.firstOrNull { it.startsWith("MAPS_API_KEY=") }
    ?.substringAfter("=")
    ?.trim()
    ?: ""

// Release signing (Phase 7 N6): android/key.properties (git-ignored) points at the upload keystore —
// storeFile, storePassword, keyAlias, keyPassword. Without it a release build falls back to the
// debug key (fine for local testing, rejected by Google Play) and says so in the build log.
val keystoreProperties = Properties().apply {
    rootProject.file("key.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "uz.bsmart.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "uz.bsmart.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["mapsApiKey"] = mapsApiKey
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("bsmart: android/key.properties not found — release build signed with the DEBUG key (not uploadable to Google Play)")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
