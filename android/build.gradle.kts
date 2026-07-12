allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// file_picker (via its transitive dep flutter_plugin_android_lifecycle) requires
// plugin modules to compile against Android API 36. Flutter does NOT propagate the
// app module's compileSdk to plugin subprojects, so each plugin keeps its own
// default (34). Bump any Android library plugin still below 36 up to 36 so the
// AAR-metadata check passes. Compile-time only.
//
// This uses AGP's finalizeDsl hook - the only correct timing window: it runs after
// the plugin's own android{} block is configured but BEFORE AGP reads compileSdk to
// wire up its tasks. (afterEvaluate is too early for eagerly-loaded plugins;
// projectsEvaluated is too late - "compileSdk has already been read".)
subprojects {
    plugins.withId("com.android.library") {
        extensions.getByType(com.android.build.api.variant.LibraryAndroidComponentsExtension::class.java)
            .finalizeDsl { android ->
                if ((android.compileSdk ?: 0) < 36) android.compileSdk = 36
            }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
