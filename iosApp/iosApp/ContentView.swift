import Coroutines
import SwiftUI

struct ContentView: View {
    @State private var results: [String] = ["", "", "", ""]
    @State private var isLoading: [Bool] = [false, false, false, false]
    @State private var stateFlowValue: String = ""
    @State private var flowEmissions: [String] = []
    @State private var cancelableFlowEmission: [String] = []
    @State private var infiniteFlowEmission: [String] = []
    @State private var suspendTask: Task<Void, Never>?

    private var animationTrigger: Int {
        results.hashValue ^
            flowEmissions.hashValue ^
            cancelableFlowEmission.hashValue ^
            infiniteFlowEmission.hashValue
    }

    var body: some View {
        ScrollViewReader { _ in
            NavigationView {
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Button(action: {
                                        Task {
                                            await coroutines(index: 0)
                                        }
                                    }) {
                                        HStack {
                                            if isLoading[0] {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            }
                                            Text("Flow")
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    .disabled(isLoading[0])

                                    Button(action: {
                                        Task {
                                            await updateStateFlow()
                                        }
                                    }) {
                                        HStack {
                                            Text("Update")
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(10)
                                    }

                                    if isLoading[0] {
                                        Button(action: {
                                            suspendTask?.cancel()
                                            results[0] = "Stopped observing"
                                            isLoading[0] = false
                                        }) {
                                            Text("Stop")
                                                .padding()
                                                .background(Color.red.opacity(0.1))
                                                .cornerRadius(10)
                                        }
                                    }
                                }

                                if !results[0].isEmpty {
                                    Text("Result:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(results[0])
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.system(.body, design: .monospaced))
                                }

                                if !flowEmissions.isEmpty {
                                    Text("Emissions:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    EmissionsListView(emissions: flowEmissions, color: Color.red)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(1..<4, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        Button(action: {
                                            Task {
                                                await coroutines(index: index)
                                            }
                                        }) {
                                            HStack {
                                                if isLoading[index] {
                                                    ProgressView().scaleEffect(0.8)
                                                }
                                                Text(getButtonTitle(for: index))
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                        .disabled(isLoading[index])

                                        if index == 1 {
                                            Button(action: { suspendTask?.cancel() }) {
                                                HStack {
                                                    Text("Cancel")
                                                }
                                                .padding()
                                                .background(Color.red.opacity(0.1))
                                                .cornerRadius(10)
                                            }
                                        }

                                        if index == 2 {
                                            Button(action: {
                                                cancelFlow()
                                                results[index] = "Cancelled"
                                                isLoading[index] = false
                                            }) {
                                                Text("Cancel")
                                                    .padding()
                                                    .background(Color.red.opacity(0.1))
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }

                                    if !results[index].isEmpty && index != 0 {
                                        Text("Result:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(results[index])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                            .font(.system(.body, design: .monospaced))
                                    }

                                    if index == 0 && !flowEmissions.isEmpty {
                                        Text("Emissions:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        EmissionsListView(emissions: flowEmissions, color: Color.red)
                                    }

                                    if index == 2 && !cancelableFlowEmission.isEmpty {
                                        Text("Emissions:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        EmissionsListView(emissions: cancelableFlowEmission, color: Color.green)
                                    }

                                    if index == 3 && !infiniteFlowEmission.isEmpty {
                                        Text("Emissions:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        EmissionsListView(emissions: infiniteFlowEmission, color: Color.orange)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .navigationTitle("Kotlin SwiftExport")
                .navigationSubtitle("Coroutines tests")
                .animation(.easeInOut, value: animationTrigger)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            results = ["", "", "", ""]
                            stateFlowValue = ""
                            flowEmissions = []
                            cancelableFlowEmission = []
                            infiniteFlowEmission = []
                        }) {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }

    private struct EmissionsListView: View {
        let emissions: [String]
        let color: Color
        var body: some View {
            let items: [(Int, String)] = emissions.enumerated().map {
                ($0.offset, $0.element)
            }
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.0) { item in
                    Text("\(item.0 + 1). \(item.1)")
                        .font(.system(.caption, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(color.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func updateStateFlow() async {
        com.playground.updateStateFlow(newValue: "Updated at \(Int(Date().timeIntervalSince1970))")
    }

    private func coroutines(index: Int) async {
        switch index {
        case 0:
            flowEmissions = []
            results[0] = "Observing StateFlow..."
            isLoading[0] = true
            suspendTask?.cancel()
            suspendTask = Task {
                do {
                    for try await value in observeStateFlow().asAsyncSequence() {
                        flowEmissions.append(value.value)
                        results[0] = "Collected \(self.flowEmissions.count) emission(s)\nLatest: \(value.value)"
                    }
                    isLoading[0] = false
                } catch {
                    results[0] = "Failed with: \(error)"
                    isLoading[0] = false
                }
            }

        case 1:
            isLoading[index] = true
            suspendTask?.cancel()
            suspendTask = Task {
                do {
                    let res = try await suspendFunction()
                    results[index] = res.value
                    isLoading[index] = false
                } catch {
                    results[index] = "Failed with: \(error)"
                    isLoading[index] = false
                }
            }

        case 2:
            cancelableFlowEmission = []
            results[index] = "Collecting emissions..."
            do {
                for try await value in createCancelableFlow().asAsyncSequence() {
                    cancelableFlowEmission.append(value.value)
                    results[index] = "Collected \(self.cancelableFlowEmission.count) emission(s)\nLatest: \(value.value)"
                }
            } catch {
                results[index] = "Failed with: \(error)"
            }

        case 3:
            infiniteFlowEmission = []
            results[index] = "Collecting emissions..."
            do {
                for try await value in createFlow().asAsyncSequence() {
                    infiniteFlowEmission.append(value.value)
                    results[index] = "Collected \(infiniteFlowEmission.count) emission(s)\nLatest: \(value.value)"
                }
            } catch {
                results[index] = "Failed with: \(error)"
            }

        default: results[index] = "Function not found"
        }
    }
}

private func getButtonTitle(for index: Int) -> String {
    switch index {
    case 1: return "suspend fun (2s delay)"
    case 2: return "Flow (restart-collect)"
    case 3: return "Flow (infinite spawn)"
    default: return "Unknown Function"
    }
}

#Preview {
    ContentView()
}
