import SwiftUI

struct ContentView: View {
    @State private var coroutinesViewModel = CoroutinesViewModel()
    @State private var sealedClassesViewModel = SealedClassesViewModel()
    @State private var crossInheritanceViewModel = CrossInheritanceViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    SectionHeader(title: "Coroutines")
                    ForEach(0..<4, id: \.self) { index in
                        CoroutinesView(index: index, viewModel: coroutinesViewModel)
                    }

                    SectionHeader(title: "Sealed classes")
                    SealedClassesView(viewModel: sealedClassesViewModel)

                    SectionHeader(title: "Cross inheritance")
                    CrossInheritanceView(viewModel: crossInheritanceViewModel)
                }
            }
            .navigationTitle("Kotlin SwiftExport")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coroutinesViewModel.reset()
                        sealedClassesViewModel.reset()
                        crossInheritanceViewModel.reset()
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
