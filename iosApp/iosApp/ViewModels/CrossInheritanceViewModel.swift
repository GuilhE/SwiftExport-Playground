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
        animated { isRunning = true }
        runTask = Task {
            async let drive: Void = control.start()
            async let observe: Void = observeEvents()
            _ = try? await drive
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
