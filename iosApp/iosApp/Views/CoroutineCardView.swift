import SwiftUI

struct CoroutineCardView: View {
    let index: Int
    let viewModel: CoroutinesViewModel

    private var title: String {
        switch index {
        case 1: "suspend fun (2s delay)"
        case 2: "Flow (restart-collect)"
        case 3: "Flow (infinite spawn)"
        default: "Unknown Function"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button(action: {
                    Task { await viewModel.run(index: index) }
                }) {
                    HStack {
                        if viewModel.isLoading[index] {
                            ProgressView().scaleEffect(0.8)
                        }
                        Text(title)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading[index])

                if index == 1 {
                    Button(action: { viewModel.cancelSuspendFunction() }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                }

                if index == 2 {
                    Button(action: { viewModel.cancelCancelableFlow() }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }

            if !viewModel.results[index].isEmpty {
                LabeledResultView(title: "Result:", text: viewModel.results[index])
                    .transition(.opacity)
            }

            if index == 2 && !viewModel.cancelableFlowEmission.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Emissions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    EmissionsListView(emissions: viewModel.cancelableFlowEmission, color: .green)
                }
                .transition(.opacity)
            }

            if index == 3 && !viewModel.infiniteFlowEmission.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Emissions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    EmissionsListView(emissions: viewModel.infiniteFlowEmission, color: .orange)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
    }
}
