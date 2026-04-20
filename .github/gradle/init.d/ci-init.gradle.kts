// Use Groovy to avoid "Unresolved reference" errors in CI
gradle.allprojects { project ->
    def applyAndroidOverrides = {
        if (!project.hasProperty('android')) return

        // 1. Specific fix for isar_flutter_libs namespace
        if (project.name == 'isar_flutter_libs') {
            project.android.namespace = 'dev.isar.isar_flutter_libs'
        }

        // 2. Force compileSdkVersion to 34 (Fixes android:attr/lStar error)
        try {
            project.android.compileSdkVersion 34
        } catch (Exception ignored) {
            try { project.android.compileSdk = 34 } catch (Exception ignored2) {}
        }

        // 3. Force namespace if missing (Satisfies AGP 8+ requirements)
        try {
            if (!project.android.namespace) {
                project.android.namespace = project.group ? project.group.toString() : project.name
            }
        } catch (Exception ignored) {}
    }

    // Apply overrides safely regardless of evaluation state
    if (project.state.executed) {
        applyAndroidOverrides()
    } else {
        project.afterEvaluate { applyAndroidOverrides() }
    }
}
