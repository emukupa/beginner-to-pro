// The program: reads input, prints, exits. Everything else comes from :core.
plugins {
    application
}

dependencies {
    implementation(project(":core"))
}

application {
    applicationName = "tracker"
    mainClass.set("tracker.app.MainKt")
}
