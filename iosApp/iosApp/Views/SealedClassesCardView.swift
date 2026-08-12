import SwiftUI

struct SealedClassesCardView: View {
    let viewModel: DownloadStateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sealed classes → Swift enum")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                Button(action: { viewModel.advance() }) {
                    HStack {
                        Text("Advance state")
                        Spacer()
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                }

                Button(action: { viewModel.reset() }) {
                    Text("Reset")
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
            }

            if !viewModel.isIdle {
                LabeledResultView(title: "Result:", text: viewModel.statusText)
                    .transition(.opacity)
            }

            if !viewModel.log.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("History:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    EmissionsListView(emissions: viewModel.log, color: .purple)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal)
    }
}
