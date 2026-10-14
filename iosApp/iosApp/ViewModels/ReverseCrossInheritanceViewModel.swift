@preconcurrency import KotlinCoroutineSupport
import KotlinRuntime
@preconcurrency import KotlinToSwift
import Observation
import os
import SwiftUI

@MainActor
@Observable
final class ReverseCrossInheritanceViewModel {
    private let control: SwiftTickerControl
    private var runTask: Task<Void, Never>?

    var isRunning = false
    var emissions: [String] = []

    init() {
        control = SwiftTickerControl()
    }

    func start() {
        guard !isRunning else { return }
        animated { isRunning = true }
        runTask = Task {
            async let start: Void = startTickerControl()
            async let observe: Void = observeEvents()
            _ = await start
            _ = await observe
        }
    }

    func stop() {
        animated { isRunning = false }
        control.stop()
        runTask?.cancel()
        runTask = nil
    }

    func reset() {
        stop()
        animated { emissions = [] }
    }

    private func startTickerControl() async {
        do {
            try await DiProvider.shared.startTickerControl(control: control)
        } catch is CancellationError {
        } catch {
            animated { emissions.append("Kotlin driver failed with: \(error)") }
        }
    }

    private func observeEvents() async {
        do {
            for try await value in control.observeEvents().asAsyncSequence() {
                animated { emissions.append(value.value) }
            }
        } catch is CancellationError {
        } catch {
            animated { emissions.append("Failed with: \(error)") }
        }
    }

    private func animated(_ mutation: () -> Void) {
        withAnimation(.easeInOut, mutation)
    }
}
