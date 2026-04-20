import org.gradle.api.Project
import com.android.build.api.dsl.CommonExtension
import com.android.build.gradle.BaseExtension

// This init script runs for all Gradle builds in CI when copied into
// <project-root>/android/gradle/init.d/ so Gradle will pick it up.

// Configure Android projects as early as possible using beforeProject so
// the AGP can observe the namespace/compileSdk values during variant creation.
gradle.beforeProject { project: Project ->
    try {
        val androidExt = project.extensions.findByName("android")
        if (androidExt == null) return@beforeProject

        // Kotlin DSL AGP extension
        if (androidExt is CommonExtension<*, *, *, *, *, *>) {
            try {
                if (androidExt.compileSdk < 34) androidExt.compileSdk = 34
            } catch (e: Exception) {
                // ignore
            }
            try {
                if (androidExt.namespace == null || androidExt.namespace.isEmpty()) {
                    androidExt.namespace = project.group?.toString() ?: project.name
                }
            } catch (e: Exception) {
                // ignore
            }
            return@beforeProject
        }

        // Groovy-based AGP extension (LibraryExtension / AppExtension)
        if (androidExt is BaseExtension) {
            try {
                // Try calling compileSdkVersion(int)
                val compileMethod = androidExt.javaClass.methods.firstOrNull { it.name == "compileSdkVersion" }
                if (compileMethod != null) {
                    // Some variants accept an Int or a String like "34"
                    try {
                        compileMethod.invoke(androidExt, 34)
                    } catch (e: Exception) {
                        try { compileMethod.invoke(androidExt, "34") } catch (_: Exception) {}
                    }
                } else {
                    // Try setter style if present
                    val setCompile = androidExt.javaClass.methods.firstOrNull { it.name == "setCompileSdkVersion" }
                    setCompile?.invoke(androidExt, "34")
                }
            } catch (e: Exception) {
                // ignore
            }

            try {
                // Namespace getter / setter
                val getNs = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
                val currentNs = try { getNs?.invoke(androidExt) as? String } catch (_: Exception) { null }
                if (currentNs == null || currentNs.isEmpty()) {
                    val setNs = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" }
                    setNs?.invoke(androidExt, project.group?.toString() ?: project.name)
                }
            } catch (e: Exception) {
                // ignore
            }
        }
    } catch (e: Exception) {
        // Never fail the build due to CI init script
    }
}
