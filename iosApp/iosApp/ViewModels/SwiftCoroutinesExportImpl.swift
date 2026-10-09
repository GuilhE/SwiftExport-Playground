import KotlinRuntime
import KotlinToSwift

/// Swift implementation of `CoroutinesExport` (cross-language inheritance). Requires Kotlin
/// 2.5.0-Beta2+ to subclass `KotlinBase` directly. Flow-returning members still delegate to a
/// Kotlin-owned instance, since Swift can't author a cold `Flow` on its own.
final class SwiftCoroutinesExportImpl: KotlinRuntime.KotlinBase, CoroutinesExport {
    private let state = typedMutableStateFlow(initial: DataClass(value: "Hello from Swift!"))
    private let kotlin = kotlinCoroutinesExportImpl()

    func observeStateFlow() -> any KotlinCoroutineSupport.KotlinTypedStateFlow<any KotlinToSwift.Data> {
        state
    }

    func updateStateFlow(newValue: String) {
        state.value = DataClass(value: newValue)
    }

    func suspendFunction() async throws -> any KotlinToSwift.Data {
        try await Task.sleep(for: .seconds(2))
        guard Bool.random() else { throw SwiftUpsError() }
        return DataClass(value: "Hello from Swift suspend fun")
    }

    func createFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        kotlin.createFlow()
    }

    func createCancelableFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        kotlin.createCancelableFlow()
    }

    func cancelFlow() {
        kotlin.cancelFlow()
    }
}

struct SwiftUpsError: Error, CustomStringConvertible {
    var description: String { "Ups! Something went wrong (from Swift)." }
}
