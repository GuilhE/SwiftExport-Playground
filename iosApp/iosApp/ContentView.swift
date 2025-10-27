import Combine
import ComposeApp
import SwiftUI

struct ContentView: View {
    @State private var results: [String] = ["", "", "", ""]
    @State private var isLoading: [Bool] = [false, false, false, false]
    @State private var stateFlowValue: String = ""
    @State private var flowEmissions: [String] = []
    @State private var asyncStreamEmissions: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    Task {
                                        await getStateFlowValue()
                                    }
                                }) {
                                    HStack {
                                        if isLoading[0] {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                        Text("Get StateFlow")
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
                                        await getStateFlowValue()
                                    }
                                }) {
                                    HStack {
                                        Text("Update StateFlow")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
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
                        }
                        .padding(.horizontal)

                        ForEach(1 ..< 4, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Button(action: {
                                        Task {
                                            await suspendFunction(index: index)
                                        }
                                    }) {
                                        HStack {
                                            if isLoading[index] {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            }
                                            Text(getButtonTitle(for: index))
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    .disabled(isLoading[index])

                                    if index == 2 {
                                        Button(action: {
                                            com.playground.cancelSuspendFlowFunction()
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

                                if !results[index].isEmpty {
                                    Text("Result:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(results[index])
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.system(.body, design: .monospaced))
                                }

                                if index == 2 && !flowEmissions.isEmpty {
                                    Text("Emissions:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    FlowEmissionsListView(emissions: flowEmissions)
                                }

                                if index == 3 && !asyncStreamEmissions.isEmpty {
                                    Text("Emissions:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    AsyncStreamEmissionsListView(emissions: asyncStreamEmissions)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Kotlin SwiftExport")
            .navigationSubtitle("Coroutines tests")
            .animation(.easeInOut, value: results)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        results = ["", "", "", ""]
                        stateFlowValue = ""
                        flowEmissions = []
                        asyncStreamEmissions = []
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private struct FlowEmissionsListView: View {
        let emissions: [String]
        var body: some View {
            let items: [(Int, String)] = emissions.enumerated().map { ($0.offset, $0.element) }
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.0) { item in
                    Text("\(item.0 + 1). \(item.1)")
                        .font(.system(.caption, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private struct AsyncStreamEmissionsListView: View {
        let emissions: [String]
        var body: some View {
            let items: [(Int, String)] = emissions.enumerated().map { ($0.offset, $0.element) }
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.0) { item in
                    Text("\(item.0 + 1). \(item.1)")
                        .font(.system(.caption, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func getButtonTitle(for index: Int) -> String {
        switch index {
        case 1: return "suspend fun (2s delay)"
        case 2: return "suspend fun (restart-collect)"
        case 3: return "AsyncStream (infinite spawn)"
        default: return "Unknown Function"
        }
    }

    private func getStateFlowValue() async {
        if let value = com.playground.stateFlow.value {
            let data = value as! com.playground.DataClass
            results[0] = "\(data.value)"
        } else {
            results[0] = ""
        }
    }

    private func updateStateFlow() async {
        com.playground.updateStateFlow(newValue: "Updated at \(Int(Date().timeIntervalSince1970))")
    }

    private func suspendFunction(index: Int) async {
        switch index {
        case 1:
            isLoading[index] = true
            let res = await com.playground.suspendFunction()
            results[index] = res
            isLoading[index] = false

        case 2:
            flowEmissions = []
            results[index] = "Collecting emissions..."
            com.playground.suspendFlowFunction { value in
                DispatchQueue.main.async {
                    self.flowEmissions.append(value)
                    self.results[index] = "Collected \(self.flowEmissions.count) emission(s)\nLatest: \(value)"
                }
            }

        case 3:
            asyncStreamEmissions = []
            results[index] = "Collecting emissions..."
            Task {
                for await value in kotlinFlowToAsyncStream(com.playground.suspendFlowFunctionSpawn) {
                    DispatchQueue.main.async {
                        self.asyncStreamEmissions.append(value)
                        self.results[index] = "Collected \(self.asyncStreamEmissions.count) emission(s)\nLatest: \(value)"
                    }
                }
            }

        default: results[index] = "Function not found"
        }
    }

    private func kotlinFlowToAsyncStream(_ startFlow: (@escaping (String) -> Void) -> Void) -> AsyncStream<String> {
        AsyncStream { continuation in
            startFlow { value in
                continuation.yield(value)
            }
        }
    }
}
