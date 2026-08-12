import SwiftUI

struct EmissionsListView: View {
    let emissions: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(emissions.enumerated()), id: \.offset) { item in
                Text("\(item.offset + 1). \(item.element)")
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
