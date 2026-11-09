// The tracker's code, as a library module. `internal` means "inside this module only".
dependencies {
    testImplementation(kotlin("test")) // kotlin.test, on JUnit 5
}

tasks.test {
    useJUnitPlatform()
}
