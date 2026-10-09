@file:OptIn(ExperimentalSwiftExportDsl::class)

import org.jetbrains.kotlin.gradle.swiftexport.ExperimentalSwiftExportDsl

plugins {
    alias(libs.plugins.kotlinMultiplatform)
}

kotlin {
    iosArm64()
    iosSimulatorArm64()

    export {
        swift {
            moduleName = "KotlinToSwift"
            rootPackage = "com.playground"
            xcodeIntegration()
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(libs.kotlinx.coroutines.core)
        }
    }
}
