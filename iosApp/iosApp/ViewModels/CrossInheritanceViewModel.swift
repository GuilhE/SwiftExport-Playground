import KotlinRuntime
@preconcurrency import KotlinToSwift
import Observation
import SwiftUI

private final class SwiftTicker: KotlinBase, Ticker {
    func onTick(tick: Int32) async -> String {
        try? await Task.sleep(for: .seconds(1))
        return "Kotlin invoked Swift: tick #\(tick)"
    }
}

@MainActor
@Observable
final class CrossInheritanceViewModel {
    private let control: any TickerControl
    private var runTask: Task<Void, Never>?

    var isRunning = false
    var emissions: [String] = []

    init() {
        control = DiProvider.shared.tickerControl(ticker: SwiftTicker())
    }

    func start() {
        guard !isRunning else { return }
        withAnimation(.easeInOut) { isRunning = true }
        runTask = Task {
            async let drive: Void = control.start()
            async let observe: Void = observeEvents()
            _ = try? await drive
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
