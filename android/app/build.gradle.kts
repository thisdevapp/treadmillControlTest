plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sleep_prototype"
    compileSdk = flutter.compileSdkVersion
    
    // 플러그인들이 요구하는 최신 NDK 버전으로 설정합니다.
    // NDK 27은 현재 가장 최신 안정화 버전군에 속하며, 향후 업데이트 시에도 유리합니다.
    ndkVersion = "27.0.12077973"

    compileOptions {
        // 최신 안드로이드 개발 표준인 Java 17로 업그레이드하여 성능과 호환성을 확보합니다.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.sleep_prototype"
        // 최신 라이브러리(Drift 등) 호환을 위해 minSdk는 최소 21(Android 5.0) 이상을 권장합니다.
        minSdk = 21 
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

flutter {
    source = "../.."
}
