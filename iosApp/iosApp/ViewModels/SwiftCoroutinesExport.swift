import KotlinRuntime
import KotlinToSwift

// MARK: - Can Swift implement a Kotlin interface (Flow-returning or not)?
//
// Reuses the very same `CoroutinesExport` interface that `DefaultCoroutinesExport` (Kotlin) already
// implements and `CoroutinesViewModel` (Swift) already consumes — just tried in the opposite
// direction: Swift implementing it instead of consuming it.
//
// NOT POSSIBLE with the current toolchain (Kotlin 2.5.0-Beta1-73 / kotlinx.coroutines 1.10.2), for
// ANY user-defined interface — not just Flow-returning members. The blocker is generic:
//
// Every Swift Export protocol for a Kotlin interface requires the conforming type to inherit from
// `KotlinRuntime.KotlinBase`. A class that explicitly subclasses `KotlinBase` CAN satisfy the
// protocol at the declaration level (this compiles fine, `suspendFunction` included):

final class SwiftCoroutinesExport: KotlinRuntime.KotlinBase, CoroutinesExport {
    func observeStateFlow() -> any KotlinCoroutineSupport.KotlinTypedStateFlow<any KotlinToSwift.Data> {
        fatalError("unreachable — see the instantiation note below")
    }

    func updateStateFlow(newValue: String) {}

    func suspendFunction() async throws -> any KotlinToSwift.Data {
        DataClass(value: "Hello from Swift")
    }

    func createFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        fatalError("unreachable — see the instantiation note below")
    }

    func createCancelableFlow() -> any KotlinCoroutineSupport.KotlinTypedFlow<any KotlinToSwift.Data> {
        fatalError("unreachable — see the instantiation note below")
    }

    func cancelFlow() {}
}

// ...but it can never be INSTANTIATED. `KotlinBase`'s plain `init()` is `NS_UNAVAILABLE`, and its
// only usable initializer, `init(__externalRCRefUnsafe:options:)`, requires a pointer to an
// *already-existing* native Kotlin object. Unlike concrete Kotlin classes (e.g. `DataClass`, which
// gets a public `com_playground_DataClass_init_allocate()` you can call), there is no generated
// "allocate a fresh native shell" function for a user-defined interface — Kotlin interfaces aren't
// directly instantiable on the Kotlin side either, so nothing exists to bind to. Concretely:
//
//let contract = SwiftCoroutinesExport()   // error: 'init()' is unavailable
//
// Swift Export *does* generate the reverse-dispatch plumbing to call back into a Swift object once
// one exists (`@BindReverseBridgeToMethod`, `..._reverse_swift` symbols, used e.g. by the built-in
// `KotlinTask`/`SwiftJob` bridge for cancellation) — but nothing public exposes a way to mint that
// backing native object for an arbitrary interface today.
