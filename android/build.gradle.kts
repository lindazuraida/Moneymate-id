allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround: some older plugins (e.g. isar_flutter_libs 3.1.0+1) don't yet
// declare a `namespace` in their own build.gradle, which AGP 8+ requires.
// This assigns a fallback namespace to any Android library subproject that
// is missing one, instead of needing to patch the plugin's source directly.
// (Kotlin DSL version of the commonly recommended Groovy workaround.)
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            val getNamespace = ext.javaClass.getMethod("getNamespace")
            val currentNamespace = getNamespace.invoke(ext) as? String
            if (currentNamespace.isNullOrEmpty()) {
                val setNamespace = ext.javaClass.getMethod("setNamespace", String::class.java)
                setNamespace.invoke(ext, "com.moneymate.id.${project.name.replace("-", "_")}")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
