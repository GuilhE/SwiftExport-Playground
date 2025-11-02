import ComposeApp
import SwiftUI

struct ContentView: View {
    @State private var results: [String] = ["", "", "", ""]
    @State private var isLoading: [Bool] = [false, false, false, false]
    @State private var stateFlowValue: String = ""
    @State private var flowEmissions: [String] = []
    @State private var callbackEmissions: [String] = []
    @State private var asyncStreamEmissions: [String] = []

    private var animationTrigger: Int {
        results.hashValue ^
            flowEmissions.hashValue ^
            callbackEmissions.hashValue ^
            asyncStreamEmissions.hashValue
    }

    var body: some View {
        ScrollViewReader { _ in
            NavigationView {
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Button(action: { Task { await getStateFlowValue() } }) {
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

                                    Button(action: { Task { await updateStateFlow() } }) {
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

                            ForEach(0 ..< 4, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 10) {
                                        Button(action: { Task { await coroutines(index: index) } }) {
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

                                        if index == 2 {
                                            Button(action: {
                                                cancelCoroutine()
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

                                    if index == 2 && !callbackEmissions.isEmpty {
                                        Text("Emissions:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        EmissionsListView(emissions: callbackEmissions, color: Color.green)
                                    }

                                    if index == 3 && !asyncStreamEmissions.isEmpty {
                                        Text("Emissions:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        EmissionsListView(emissions: asyncStreamEmissions, color: Color.orange)
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
                            callbackEmissions = []
                            asyncStreamEmissions = []
                        }) {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }

    private func getButtonTitle(for index: Int) -> String {
        switch index {
        case 0: return "Collect StateFlow"
        case 1: return "suspend fun (2s delay)"
        case 2: return "AsyncStream (restart-collect)"
        case 3: return "AsyncStream (infinite spawn)"
        default: return "Unknown Function"
        }
    }

    private struct EmissionsListView: View {
        let emissions: [String]
        let color: Color
        var body: some View {
            let items: [(Int, String)] = emissions.enumerated().map { ($0.offset, $0.element) }
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

    private func getStateFlowValue() async {
        if let value = stateFlow.value {
            let data = value as! DataClass
            results[0] = "\(data.value)"
        } else {
            results[0] = ""
        }
    }

    private func updateStateFlow() async {
        com.playground.updateStateFlow(newValue: "Updated at \(Int(Date().timeIntervalSince1970))")
    }

    private func coroutines(index: Int) async {
        switch index {
        case 0:
            flowCollector { value in flowEmissions.append(value) }

        case 1:
            isLoading[index] = true
            let res = await suspendFunction()
            results[index] = res.value
            isLoading[index] = false

        case 2:
            callbackEmissions = []
            results[index] = "Collecting emissions..."
            spawnCancelableCoroutine { value in
                callbackEmissions.append(value)
                results[index] = "Collected \(self.callbackEmissions.count) emission(s)\nLatest: \(value)"
            }

        case 3:
            asyncStreamEmissions = []
            results[index] = "Collecting emissions..."
            for await value in toAsyncStream(spawnCoroutine) {
                asyncStreamEmissions.append(value)
                results[index] = "Collected \(asyncStreamEmissions.count) emission(s)\nLatest: \(value)"
            }

        default: results[index] = "Function not found"
        }
    }

    private func toAsyncStream(_ callback: (@escaping (String) -> Void) -> Void) -> AsyncStream<String> {
        AsyncStream { continuation in
            callback { value in continuation.yield(value) }
        }
    }
}

#Preview {
    ContentView()
}
