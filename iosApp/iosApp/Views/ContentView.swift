import SwiftUI

struct ContentView: View {
    @State private var coroutinesViewModel = CoroutinesViewModel()
    @State private var downloadViewModel = DownloadStateViewModel()
    @State private var kotlinInvokesSwift = KotlinInvokesSwiftViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    SectionHeader(title: "Coroutines")
                    StateFlowCardView(viewModel: coroutinesViewModel)

                    ForEach(1..<4, id: \.self) { index in
                        CoroutineCardView(index: index, viewModel: coroutinesViewModel)
                    }

                    SectionHeader(title: "Sealed classes")
                    SealedClassesCardView(viewModel: downloadViewModel)

                    SectionHeader(title: "Cross inheritance")
                    KotlinInvokesSwiftCardView(viewModel: kotlinInvokesSwift)
                }
            }
            .navigationTitle("Kotlin SwiftExport")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coroutinesViewModel.reset()
                        downloadViewModel.reset()
                        kotlinInvokesSwift.reset()
                    }) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
