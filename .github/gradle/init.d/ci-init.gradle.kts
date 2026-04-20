import org.gradle.api.Project
import com.android.build.api.dsl.CommonExtension

// This init script runs for all Gradle builds in CI when copied into
// <project-root>/android/gradle/init.d/ so Gradle will pick it up.

// Iterate all projects and enforce compileSdk and namespace safety for Android projects
gradle.rootProject { root ->
    root.allprojects.forEach { project ->
        project.afterEvaluate {
            val androidExt = project.extensions.findByName("android")
            if (androidExt is CommonExtension<*,*,*,*,*,*>) {
                try {
                    // force compileSdk if lower than desired
                    if (androidExt.compileSdk < 34) {
                        androidExt.compileSdk = 34
                    }
                } catch (e: Exception) {
                    // ignore if compileSdk isn't available in this variant
                }

                try {
                    if (androidExt.namespace == null || androidExt.namespace.isEmpty()) {
                        androidExt.namespace = project.group?.toString() ?: project.name
                    }
                } catch (e: Exception) {
                    // ignore namespace assignment failures
                }
            }
        }
    }
}
