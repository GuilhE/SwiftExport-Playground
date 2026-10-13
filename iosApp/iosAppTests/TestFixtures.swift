import KotlinRuntime
@preconcurrency import KotlinToSwift

/// Reusable `Ticker` implementation: sleeps for `delayMillis` then returns a formatted string.
/// Used across the validation tests instead of pulling in the demo's own `SwiftTicker`.
final class DelayedTicker: KotlinBase, Ticker {
    private let delayMillis: Int

    init(delayMillis: Int) {
        self.delayMillis = delayMillis
        super.init()
    }

    func onTick(tick: Int32) async -> String {
        try? await Task.sleep(for: .milliseconds(delayMillis))
        return "tick #\(tick)"
    }
}
