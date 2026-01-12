buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Paksa versi AGP ke 8.9.1 di sini
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("com.google.gms:google-services:4.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")
    }
}

plugins {
    // Biarkan blok ini tetap ada tetapi jangan berikan versi di sini 
    // karena sudah didefinisikan di buildscript di atas
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. Konfigurasi Direktori Build (Custom path)
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 4. Ketergantungan Evaluasi
subprojects {
    project.evaluationDependsOn(":app")
}

// 5. Task Clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}