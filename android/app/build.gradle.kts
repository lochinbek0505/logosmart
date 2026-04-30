import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "uz.logosmart.logosmart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    aaptOptions {
        noCompress += "tflite"
    }

    defaultConfig {
        // TODO:  Specify your own unique Application ID (https://developer.android.com/studio/build/application-id. html).
        applicationId = "com.logosmart.logosmart"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // `release` kalitini key.properties'dan yuklaymiz
        create("release") {
            if (keystorePropertiesFile.exists()) {
                // AGP 8.x: `storeFile` File tipida:
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            } else {
                // Agar fayl topilmasa, build qilish uchun ixtiyoriy fallback (xohlasangiz olib tashlang)
                println("WARNING: key.properties topilmadi. Release imzosi sozlanmagan.")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // ENDI debug kaliti EMAS, o'z release imzomiz:
            signingConfig = signingConfigs.getByName("release")

            // R8 optimizatsiya
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            // debug uchun standart
        }
    }
}

flutter {
    source = "../.."
}