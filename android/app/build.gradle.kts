plugins {
    id("com.android.application")
    // AGP 9부터 kotlin-android 플러그인을 직접 적용하지 않습니다. (Flutter Gradle 플러그인이 처리)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sleep_prototype"
    compileSdk = flutter.compileSdkVersion

    // NDK 버전은 Flutter SDK가 관리하는 값을 따릅니다. (Flutter 업그레이드 시 자동 갱신)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.sleep_prototype"
        // Flutter 3.47 기준 최소 지원 버전(API 24, Android 7.0)을 따릅니다.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
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
