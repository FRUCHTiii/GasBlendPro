import SwiftUI

// MARK: - Apple-style Input Field
struct AppleInputField: View {
    let label: String
    @Binding var value: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                TextField("0", value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)

                Text(unit)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }
            .padding(10)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(8)
        }
    }
}

// MARK: - Pressure Range
struct PressureRange {
    let initial: Double
    let final: Double
}

// MARK: - Apple-style Result Row
struct AppleResultRow: View {
    let step: Int
    let label: String
    let value: Double
    let pressureRange: PressureRange
    let isRelease: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 36, height: 36)

                Text("\(step)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                let val = value.isNaN ? 0 : value
                let actionText = isRelease ? "Release" : "Add"
                Text(String(format: "%@ %.2f bar of %@", actionText, val, label))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                let initialPres = pressureRange.initial.isNaN ? 0 : pressureRange.initial
                let finalPres = pressureRange.final.isNaN ? 0 : pressureRange.final
                Text(String(format: "%.2f bar → %.2f bar", initialPres, finalPres))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemFill))
        .cornerRadius(10)
    }
}

// MARK: - Apple Final Mix Component
struct AppleFinalMixComponent: View {
    let label: String
    let value: Double
    let accentColor: Color

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)

            let val = value.isNaN ? 0 : value
            Text(String(format: "%.1f", val))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(accentColor)

            Text("%")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
