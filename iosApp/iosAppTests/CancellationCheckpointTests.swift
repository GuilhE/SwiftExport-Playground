@preconcurrency import KotlinToSwift
import XCTest

/// Validates the README claim: "A `suspend` loop driven by the caller's `Task` needs its own
/// cancellation checkpoint." `TickerControlImpl.start()` has no internal `Job`/`CoroutineScope` —
/// it runs entirely on the Swift `Task` that calls it, and only stops because it calls
/// `ensureActive()` on every iteration. Remove that call in `TickerControl.kt` and this test fails:
/// emissions keep arriving well after the driving `Task` is cancelled.
@MainActor
final class CancellationCheckpointTests: XCTestCase {
    func testLoopStopsEmittingShortlyAfterCancellation() async throws {
        let control = DiProvider.shared.tickerControl(ticker: DelayedTicker(delayMillis: 5))

        let driveTask = Task {
            try? await control.start()
        }

        var emissionCount = 0
        let observeTask = Task {
            for try await _ in control.observeEvents().asAsyncSequence() {
                emissionCount += 1
            }
        }

        try await Task.sleep(for: .milliseconds(100))
        driveTask.cancel()
        observeTask.cancel()

        try await Task.sleep(for: .milliseconds(150))
        let countRightAfterCancel = emissionCount
        try await Task.sleep(for: .milliseconds(300))
        let countAfterSettling = emissionCount

        XCTAssertEqual(
            countRightAfterCancel,
            countAfterSettling,
            "emissions kept arriving after cancellation — the loop is missing its ensureActive() checkpoint"
        )
    }
}
