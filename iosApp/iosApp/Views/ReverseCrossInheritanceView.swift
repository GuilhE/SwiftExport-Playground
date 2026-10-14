import SwiftUI

struct ReverseCrossInheritanceView: View {
    let viewModel: ReverseCrossInheritanceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kotlin → calls Swift full implementation")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                Button(action: { viewModel.start() }) {
                    HStack {
                        if viewModel.isRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Start")
                        Spacer()
                    }
                    .padding()
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(10)
                }
                .disabled(viewModel.isRunning)

                if viewModel.isRunning {
                    Button(action: { viewModel.stop() }) {
                        Text("Stop")
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .transition(.opacity)
                }
            }

            if !viewModel.emissions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Emissions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    EmissionsListView(emissions: viewModel.emissions, color: .teal)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
    }
}
