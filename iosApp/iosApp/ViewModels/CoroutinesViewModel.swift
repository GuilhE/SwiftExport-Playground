import Foundation
import KotlinToSwift
import Observation
import SwiftUI

@MainActor
@Observable
final class CoroutinesViewModel {
    var results: [String] = ["", "", "", ""]
    var isLoading: [Bool] = [false, false, false, false]
    var flowEmissions: [String] = []
    var cancelableFlowEmission: [String] = []
    var infiniteFlowEmission: [String] = []

    private var suspendTask: Task<Void, Never>?
    /// Indices whose in-flight collection was cancelled by the user; the cancelling method
    /// already wrote a friendly "Cancelled"/"Stopped" message, so the loop's `catch` block
    /// must not race it with a later "Failed with: CancellationError()" overwrite.
    private var suppressedFailureIndices: Set<Int> = []

    func reset() {
        animated {
            results = ["", "", "", ""]
            flowEmissions = []
            cancelableFlowEmission = []
            infiniteFlowEmission = []
        }
    }

    func run(index: Int) async {
        switch index {
        case 0: startObservingStateFlow()
        case 1: await runSuspendFunction()
        case 2: await collectCancelableFlow()
        case 3: await collectInfiniteFlow()
        default: results[index] = "Function not found"
        }
    }

    func updateStateFlowValue() {
        updateStateFlow(newValue: "Updated at \(Int(Date().timeIntervalSince1970))")
    }

    func stopObservingStateFlow() {
        suppressedFailureIndices.insert(0)
        suspendTask?.cancel()
        animated {
            results[0] = "Stopped observing"
            isLoading[0] = false
        }
    }

    func cancelSuspendFunction() {
        suppressedFailureIndices.insert(1)
        suspendTask?.cancel()
        animated {
            results[1] = "Cancelled"
            isLoading[1] = false
        }
    }

    func cancelCancelableFlow() {
        suppressedFailureIndices.insert(2)
        cancelFlow()
        animated {
            results[2] = "Cancelled"
            isLoading[2] = false
        }
    }

    private func startObservingStateFlow() {
        suspendTask?.cancel()
        animated {
            flowEmissions = []
            results[0] = "Observing StateFlow..."
            isLoading[0] = true
        }
        suspendTask = Task {
            do {
                for try await value in observeStateFlow().asAsyncSequence() {
                    animated {
                        flowEmissions.append(value.value)
                        results[0] = "Collected \(flowEmissions.count) emission(s)\nLatest: \(value.value)"
                    }
                }
                animated { isLoading[0] = false }
            } catch {
                guard suppressedFailureIndices.remove(0) == nil else { return }
                animated {
                    results[0] = "Failed with: \(error)"
                    isLoading[0] = false
                }
            }
        }
    }

    private func runSuspendFunction() async {
        suspendTask?.cancel()
        animated { isLoading[1] = true }
        suspendTask = Task {
            do {
                let value = try await suspendFunction()
                animated {
                    results[1] = value.value
                    isLoading[1] = false
                }
            } catch {
                guard suppressedFailureIndices.remove(1) == nil else { return }
                animated {
                    results[1] = "Failed with: \(error)"
                    isLoading[1] = false
                }
            }
        }
    }

    private func collectCancelableFlow() async {
        animated {
            cancelableFlowEmission = []
            results[2] = "Collecting emissions..."
        }
        do {
            for try await value in createCancelableFlow().asAsyncSequence() {
                animated {
                    cancelableFlowEmission.append(value.value)
                    results[2] = "Collected \(cancelableFlowEmission.count) emission(s)\nLatest: \(value.value)"
                }
            }
        } catch {
            guard suppressedFailureIndices.remove(2) == nil else { return }
            animated { results[2] = "Failed with: \(error)" }
        }
    }

    private func collectInfiniteFlow() async {
        animated {
            infiniteFlowEmission = []
            results[3] = "Collecting emissions..."
        }
        do {
            for try await value in createFlow().asAsyncSequence() {
                animated {
                    infiniteFlowEmission.append(value.value)
                    results[3] = "Collected \(infiniteFlowEmission.count) emission(s)\nLatest: \(value.value)"
                }
            }
        } catch {
            animated { results[3] = "Failed with: \(error)" }
        }
    }

    private func animated(_ mutation: () -> Void) {
        withAnimation(.easeInOut, mutation)
    }
}
