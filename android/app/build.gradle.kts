import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load release signing config from android/key.properties if it exists.
// When the file (or the keystore it points at) is absent — e.g. on CI machines
// or other checkouts without the upload key — we fall back to debug signing so
// `flutter build`/`flutter run --release` still work.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning =
    keystorePropertiesFile.exists().also { exists ->
        if (exists) {
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        }
    } && keystoreProperties.getProperty("storeFile")?.let { file(it).exists() } == true

android {
    namespace = "com.tamir_uy.tamir_uy_mobile_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // The Play Store identity: fixed for good once the first build is uploaded.
        // `namespace` above (the Kotlin package) is deliberately left as is; only
        // the application ID is the public identifier.
        applicationId = "andozaai.com"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // ARCore requires API level 24 (Android 7.0) or higher.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Only define the release signing config when key.properties + keystore
        // are present; otherwise referencing missing properties would fail.
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Sign with the upload key when it's available, otherwise fall back
            // to the debug keys so builds still work on machines without it.
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// image_picker transitively pulls newer AndroidX libs (androidx.core 1.18,
// androidx.activity 1.12) whose AAR metadata demands AGP 8.9.1+, but this
// project is on AGP 8.7. Pin those to the latest AGP-8.7-compatible versions so
// the build succeeds without a full AGP/Gradle upgrade.
configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.activity:activity:1.9.3")
    }
}

dependencies {
    // Google ARCore — plane detection / hit tests for the floor-plan scanner (arscan/).
    implementation("com.google.ar:core:1.56.0")
    testImplementation("junit:junit:4.13.2")
}
