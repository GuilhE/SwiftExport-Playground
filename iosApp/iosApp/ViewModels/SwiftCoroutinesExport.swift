import KotlinRuntime
import KotlinToSwift

// Swift implementing a Kotlin interface (cross-language inheritance), reusing the existing
// `CoroutinesExport`. Requires Kotlin 2.5.0-Beta2+ to subclass `KotlinBase` directly.
final class SwiftCoroutinesExport: KotlinRuntime.KotlinBase, CoroutinesExport {
    private let state = dataMutableStateFlow(initial: DataClass(value: "Hello from Swift"))

    func observeStateFlow() -> any KotlinCoroutineSupport.KotlinTypedStateFlow<any KotlinToSwift.Data> {
        state
    }

    func updateStateFlow(newValue: String) {
        state.value = DataClass(value: newValue)
    }

    func suspendFunction() async throws -> any KotlinToSwift.Data {
        DataClass(value: "Hello from Swift")
    }

    func createFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        coroutinesExport().createFlow()
    }

    func createCancelableFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        coroutinesExport().createCancelableFlow()
    }

    func cancelFlow() {}
}

@MainActor
func runCrossLanguageInheritanceProbe() async {
    let contract = SwiftCoroutinesExport()

    if let result = try? await describeCoroutinesExport(contract: contract) {
        print("[cross-language inheritance] \(result)")
    }

    contract.updateStateFlow(newValue: "Updated from Swift")
    print("[cross-language inheritance] state.value -> \(contract.observeStateFlow().value.value)")
}
