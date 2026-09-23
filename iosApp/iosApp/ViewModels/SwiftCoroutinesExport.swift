import KotlinToSwift

// MARK: - Can Swift implement a Kotlin interface (Flow-returning or not)?
//
// Reuses the very same `CoroutinesExport` interface that `DefaultCoroutinesExport` (Kotlin) already
// implements and `CoroutinesViewModel` (Swift) already consumes — just tried in the opposite
// direction: Swift implementing it instead of consuming it.
//
// Earlier attempts failed: subclassing `KotlinRuntime.KotlinBase` directly compiles but can never
// be instantiated (`init()` is unavailable), and rebinding to an existing donor ref via
// `.asBoundBridge` crashes at runtime. The missing piece, per
// https://kotlinlang.org/docs/native-swift-export.html#cross-language-inheritance: Swift must
// subclass a Kotlin-declared `open class` (`SwiftBase`, in `CoroutinesExport.kt`), not `KotlinBase`
// itself — only a concrete, instantiable Kotlin class gets a public allocator generated for it.

final class SwiftCoroutinesExport: SwiftBase, CoroutinesExport {
    func observeStateFlow() -> any KotlinCoroutineSupport.KotlinTypedStateFlow<any KotlinToSwift.Data> {
        fatalError("not exercised by this probe")
    }

    func updateStateFlow(newValue: String) {
        fatalError("not exercised by this probe")
    }

    func suspendFunction() async throws -> any KotlinToSwift.Data {
        DataClass(value: "Hello from Swift")
    }

    func createFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        fatalError("not exercised by this probe")
    }

    func createCancelableFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        fatalError("not exercised by this probe")
    }

    func cancelFlow() {
        fatalError("not exercised by this probe")
    }
}

@MainActor
func runCrossLanguageInheritanceProbe() async {
    let contract = SwiftCoroutinesExport()

    if let result = try? await contract.suspendFunction() {
        print("[cross-language inheritance] direct call -> \(result.value)")
    }

    // Works on Kotlin 2.4.20 (stable): prints "Kotlin saw: Hello from Swift" — Kotlin
    // genuinely received the Swift object, cast it to `CoroutinesExport`, and called our override.
    //
    // On Kotlin 2.5.0-Beta1-73 (the version this whole project otherwise targets) the exact same
    // code crashes the process instead:
    //     Uncaught Kotlin exception: kotlin.ClassCastException: class SwiftCoroutinesExport
    //     cannot be cast to class com.playground.CoroutinesExport
    // So this looks like a regression in the 2.5.0 dev/beta channel, not a fundamental limitation.
    if let result = try? await describeCoroutinesExport(contract: contract) {
        print("[cross-language inheritance] \(result)")
    }
}
