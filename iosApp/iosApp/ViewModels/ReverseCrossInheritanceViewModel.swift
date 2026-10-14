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
        withAnimation(.easeInOut) { isRunning = true }
        runTask = Task {
            async let start: Void = startTickerControl()
            async let observe: Void = observeEvents()
            _ = await start
            _ = await observe
        }
    }

    func stop() {
        withAnimation(.easeInOut) { isRunning = false }
        control.stop()
        runTask?.cancel()
        runTask = nil
    }

    func reset() {
        stop()
        emissions = []
    }

    private func startTickerControl() async {
        do {
            try await DiProvider.shared.startTickerControl(control: control)
        } catch is CancellationError {
        } catch {
            emissions.insert("Kotlin driver failed with: \(error)", at: 0)
        }
    }

    private func observeEvents() async {
        do {
            for try await value in control.observeEvents().asAsyncSequence() {
                emissions.insert(value.value, at: 0)
            }
        } catch is CancellationError {
        } catch {
            emissions.insert("Failed with: \(error)", at: 0)
        }
    }
}
