import Foundation
import KotlinRuntime
import KotlinRuntimeSupport
@preconcurrency import KotlinToSwift
@preconcurrency import OrgJetbrainsKotlinxKotlinxCoroutinesCore
import os

private typealias StateFlow = ExportedKotlinPackages.kotlinx.coroutines.flow.StateFlow
private typealias FlowCollector = ExportedKotlinPackages.kotlinx.coroutines.flow.FlowCollector

private final class SwiftStateFlowImpl: KotlinBase, StateFlow {
    private let hub: TickerEventsHub

    init(initial: any KotlinToSwift.Data) {
        hub = TickerEventsHub(initial: initial)
        super.init()
    }

    var value: (any KotlinRuntimeSupport._KotlinBridgeable)? {
        hub.value
    }

    var replayCache: [(any KotlinRuntimeSupport._KotlinBridgeable)?] {
        [hub.value]
    }

    // Kotlin's SharedFlow.collect returns Nothing, bound here as `-> Never`, but the base Flow
    // protocol still separately requires `-> Void`; one overload per requirement satisfies both.
    func collect(collector: any FlowCollector) async throws -> Never {
        for await data in hub.subscribe() {
            try await collector.emit(value: data)
        }
        throw CancellationError()
    }

    func collect(collector: any FlowCollector) async throws {
        _ = try await collect(collector: collector) as Never
    }

    func update(_ newValue: any KotlinToSwift.Data) {
        hub.update(newValue)
    }
}

private final class TickerEventsHub: @unchecked Sendable {
    private struct State {
        var current: any KotlinToSwift.Data
        var subscribers: [UUID: AsyncStream<any KotlinToSwift.Data>.Continuation] = [:]
    }

    private let lock: OSAllocatedUnfairLock<State>

    init(initial: any KotlinToSwift.Data) {
        lock = OSAllocatedUnfairLock(initialState: State(current: initial))
    }

    var value: any KotlinToSwift.Data {
        lock.withLock { $0.current }
    }

    func update(_ newValue: any KotlinToSwift.Data) {
        let continuations: [AsyncStream<any KotlinToSwift.Data>.Continuation] = lock.withLock { state in
            state.current = newValue
            return Array(state.subscribers.values)
        }
        for continuation in continuations {
            continuation.yield(newValue)
        }
    }

    func subscribe() -> AsyncStream<any KotlinToSwift.Data> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<any KotlinToSwift.Data>.makeStream()
        lock.withLock { state in
            continuation.yield(state.current)
            state.subscribers[id] = continuation
        }
        continuation.onTermination = { [weak self] _ in
            _ = self?.lock.withLock { $0.subscribers.removeValue(forKey: id) }
        }
        return stream
    }
}

private final class SwiftTicker: KotlinBase, Ticker {
    func onTick(tick: Int32) async -> String {
        try? await Task.sleep(for: .seconds(1))
        return "Swift drives itself: tick #\(tick)"
    }
}

private final class SwiftDataImpl: KotlinBase, KotlinToSwift.Data {
    let value: String

    init(_ value: String) {
        self.value = value
        super.init()
    }
}

final class SwiftTickerControl: KotlinBase, TickerControl {
    private let ticker: Ticker = SwiftTicker()
    private let stateFlow: SwiftStateFlowImpl = .init(initial: SwiftDataImpl("Waiting for Swift…"))
    private let stopped = OSAllocatedUnfairLock(initialState: false)

    private var isStopped: Bool { stopped.withLock { $0 } }

    func observeEvents() -> any KotlinTypedStateFlow<any KotlinToSwift.Data> {
        _KotlinTypedStateFlowImpl<any KotlinToSwift.Data>.create(stateFlow, KotlinToSwift.Data.self)
    }

    func start() async throws {
        stopped.withLock { $0 = false }
        var tick: Int32 = 0
        while !isStopped {
            guard !isStopped else { break }
            tick += 1
            let text = try await ticker.onTick(tick: tick)
            stateFlow.update(SwiftDataImpl(text))
        }
    }

    func stop() {
        stopped.withLock { $0 = true }
    }
}
