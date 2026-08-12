import SwiftUI

struct StateFlowCardView: View {
    let viewModel: CoroutinesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button(action: {
                    Task { await viewModel.run(index: 0) }
                }) {
                    HStack {
                        if viewModel.isLoading[0] {
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
                .disabled(viewModel.isLoading[0])

                Button(action: { viewModel.updateStateFlowValue() }) {
                    HStack {
                        Text("Update")
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }

                if viewModel.isLoading[0] {
                    Button(action: { viewModel.stopObservingStateFlow() }) {
                        Text("Stop")
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .transition(.opacity)
                }
            }

            if !viewModel.results[0].isEmpty {
                LabeledResultView(title: "Result:", text: viewModel.results[0])
                    .transition(.opacity)
            }

            if !viewModel.flowEmissions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Emissions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    EmissionsListView(emissions: viewModel.flowEmissions, color: .red)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
    }
}
