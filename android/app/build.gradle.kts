import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

android {
    namespace = "com.weather_outfit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.weather_outfit"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // keystore.properties dosyasından yüklenir
            // Yayınlamadan önce keystore oluşturun:
            // keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000
            val keystoreFile = rootProject.file("keystore.properties")
            if (keystoreFile.exists()) {
                val props = Properties()
                props.load(keystoreFile.inputStream())
                storeFile = rootProject.file(requireNotNull(props.getProperty("storeFile")))
                storePassword = requireNotNull(props.getProperty("storePassword"))
                keyAlias = requireNotNull(props.getProperty("keyAlias"))
                keyPassword = requireNotNull(props.getProperty("keyPassword"))
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.findByName("release")
            val hasKeystore = releaseConfig?.storeFile?.exists() == true
            signingConfig = if (hasKeystore) releaseConfig else signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
