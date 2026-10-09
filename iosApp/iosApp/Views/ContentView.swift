import SwiftUI

struct ContentView: View {
    @State private var coroutines = CoroutinesViewModel()
    @State private var downloadStateDemo = DownloadStateViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    StateFlowCardView(viewModel: coroutines)

                    ForEach(1..<4, id: \.self) { index in
                        CoroutineCardView(index: index, viewModel: coroutines)
                    }

                    SealedClassesCardView(viewModel: downloadStateDemo)
                }
            }
            .navigationTitle("Kotlin SwiftExport")
            .navigationSubtitle("Coroutines → Swift concurrency")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coroutines.reset()
                        downloadStateDemo.reset()
                    }) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
