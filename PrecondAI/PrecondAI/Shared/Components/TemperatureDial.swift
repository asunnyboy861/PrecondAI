import SwiftUI

struct TemperatureDial: View {
    @Binding var temperature: Double
    let range: ClosedRange<Double>

    private var temperatureColor: Color {
        let ratio = (temperature - range.lowerBound) / (range.upperBound - range.lowerBound)
        if ratio < 0.5 {
            return Color.blue.opacity(1 - ratio * 2).mixed(with: .white, fraction: ratio)
        } else {
            return Color.orange.opacity((ratio - 0.5) * 2).mixed(with: .white, fraction: 1 - ratio)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), temperatureColor.opacity(0.6), .orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: temperatureColor.opacity(0.3), radius: 20)

                VStack(spacing: 4) {
                    Text("\(Int(temperature))°")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Fahrenheit")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            HStack(spacing: 0) {
                Image(systemName: "snowflake")
                    .foregroundStyle(.blue)
                Slider(value: $temperature, in: range)
                    .tint(temperatureColor)
                    .padding(.horizontal, 12)
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 20)
        }
    }
}

extension Color {
    func mixed(with other: Color, fraction: Double) -> Color {
        let uiColor = UIColor(self)
        let otherColor = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        otherColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * fraction,
            green: g1 + (g2 - g1) * fraction,
            blue: b1 + (b2 - b1) * fraction,
            opacity: a1 + (a2 - a1) * fraction
        )
    }
}
