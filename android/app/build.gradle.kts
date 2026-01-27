import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    signingConfigs {
        create("release") {
            val alias = keystoreProperties.getProperty("keyAlias")
            val keyPw = keystoreProperties.getProperty("keyPassword")
            val storePw = keystoreProperties.getProperty("storePassword")
            val storeFilePath = keystoreProperties.getProperty("storeFile")

            keyAlias = alias
            keyPassword = keyPw
            storePassword = storePw
            
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
        }
    }

    namespace = "com.ekrembas.limitim"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" 
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ekrembas.limitim"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = false 
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
