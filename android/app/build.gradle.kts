import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

FileInputStream(keystorePropertiesFile).use {
    keystoreProperties.load(it)
}

val releaseAdMobAppId = providers.gradleProperty("ADMOB_APP_ID")
    .orElse(providers.environmentVariable("ADMOB_APP_ID"))
    .orElse("ca-app-pub-2681549212751095~2564398166")
    .get()
val adMobAppIdPattern = Regex("""^ca-app-pub-\d+~\d+$""")

require(adMobAppIdPattern.matches(releaseAdMobAppId)) {
    "ADMOB_APP_ID must be an AdMob App ID shaped like " +
        "ca-app-pub-<digits>~<digits>; banner ad-unit IDs containing '/' " +
        "are not valid here."
}

android {
    namespace = "com.workproof.workhelper"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.workproof.workhelper"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["ADMOB_APP_ID"] =
            "ca-app-pub-3940256099942544~3347511713"
    }

    // Create the signing config before using it.
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storePassword = keystoreProperties.getProperty("storePassword")
            storeFile = file(
                keystoreProperties.getProperty("storeFile")
            )
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            manifestPlaceholders["ADMOB_APP_ID"] = releaseAdMobAppId
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
