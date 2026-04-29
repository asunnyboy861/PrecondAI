import SwiftUI

struct WeatherAttributionView: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "apple.logo")
                .font(.caption2)
            Text("Weather")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Link("Legal", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                .font(.caption2)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}
