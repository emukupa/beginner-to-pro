// The tracker as a Gradle build with two modules: core (one package per job) and app (the program).
//   ./gradlew installDist                                   app/build/install/tracker/bin/tracker
//   ./gradlew test                                          the tests in core
//   ../../contract/run.sh "$PWD/app/build/install/tracker/bin/tracker"     the contract
rootProject.name = "tracker"
include("core", "app")
