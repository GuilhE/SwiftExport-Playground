import KotlinToSwift
import Observation
import SwiftUI

@MainActor
@Observable
final class DownloadStateViewModel {
    var current: any DownloadState = idleDownloadState()
    var log: [String] = []

    var isIdle: Bool {
        if case .idle = current.sealedType() {
            return true
        }
        return false
    }

    var statusText: String {
        switch current.sealedType() {
        case .idle:
            "Idle"
        case let .inProgress(state):
            "Downloading… \(state.value.percent)%"
        case let .completed(state):
            "Completed: \(state.value.fileName)"
        case let .failed(state):
            "Failed: \(state.value.reason)"
        }
    }

    func advance() {
        withAnimation(.easeInOut) {
            current = nextDownloadState(current: current)
            log.append(statusText)
        }
    }

    func reset() {
        withAnimation(.easeInOut) {
            current = idleDownloadState()
            log = []
        }
    }
}
