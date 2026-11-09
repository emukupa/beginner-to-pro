// Settings shared by both modules. Kotlin 2.4 targets at most JVM 26, so both Kotlin and Java are
// pinned to 25, which any newer JDK runs.
plugins {
    kotlin("jvm") version "2.4.20" apply false
}

subprojects {
    apply(plugin = "org.jetbrains.kotlin.jvm")
    repositories { mavenCentral() }
    extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension> {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_25)
            allWarningsAsErrors.set(true)
        }
    }
    extensions.configure<JavaPluginExtension> {
        sourceCompatibility = JavaVersion.VERSION_25
        targetCompatibility = JavaVersion.VERSION_25
    }
}
