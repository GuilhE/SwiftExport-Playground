import SwiftUI

struct ContentView: View {
    @State private var coroutinesViewModel = CoroutinesViewModel()
    @State private var sealedClassesViewModel = SealedClassesViewModel()
    @State private var crossInheritanceViewModel = CrossInheritanceViewModel()
    @State private var reverseCrossInheritanceViewModel = ReverseCrossInheritanceViewModel()

    var body: some View {
        TabView {
            CoroutinesTab(viewModel: coroutinesViewModel)
                .tabItem { Label("Coroutines", systemImage: "arrow.triangle.2.circlepath") }

            SealedClassesTab(viewModel: sealedClassesViewModel)
                .tabItem { Label("Sealed classes", systemImage: "list.bullet") }

            InheritanceTab(
                crossInheritanceViewModel: crossInheritanceViewModel,
                reverseCrossInheritanceViewModel: reverseCrossInheritanceViewModel
            )
            .tabItem { Label("Inheritance", systemImage: "arrow.left.arrow.right") }
        }
    }
}

private struct CoroutinesTab: View {
    let viewModel: CoroutinesViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(0 ..< 4, id: \.self) { index in
                        CoroutinesView(index: index, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Coroutines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.reset() }) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
        }
    }
}

private struct SealedClassesTab: View {
    let viewModel: SealedClassesViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                SealedClassesView(viewModel: viewModel)
                    .padding(.top)
            }
            .navigationTitle("Sealed classes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.reset() }) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
        }
    }
}

private struct InheritanceTab: View {
    let crossInheritanceViewModel: CrossInheritanceViewModel
    let reverseCrossInheritanceViewModel: ReverseCrossInheritanceViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    SectionHeader(title: "Cross inheritance")
                    CrossInheritanceView(viewModel: crossInheritanceViewModel)

                    SectionHeader(title: "Reverse cross inheritance")
                    ReverseCrossInheritanceView(viewModel: reverseCrossInheritanceViewModel)
                }
            }
            .navigationTitle("Inheritance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        crossInheritanceViewModel.reset()
                        reverseCrossInheritanceViewModel.reset()
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
