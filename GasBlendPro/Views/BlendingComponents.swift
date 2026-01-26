import SwiftUI
import SwiftData
import UIKit

// MARK: - UITextField Wrapper with Select All
struct SelectAllTextField: UIViewRepresentable {
    @Binding var value: Double
    let placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textFieldDidChange),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        let formattedValue = value == 0 ? "" : String(format: "%.10g", value)
        uiView.text = formattedValue
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var value: Double

        init(value: Binding<Double>) {
            _value = value
        }

        @objc
        func textFieldDidChange(_ textField: UITextField) {
            if let text = textField.text, let newValue = Double(text) {
                value = newValue
            } else if textField.text?.isEmpty ?? true {
                value = 0
            }
        }

        // Select all text when user taps into the field
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.selectedTextRange = textField.textRange(
                from: textField.beginningOfDocument,
                to: textField.endOfDocument
            )
        }
    }
}

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
                SelectAllTextField(value: $value, placeholder: "0")
                    .frame(maxWidth: .infinity)

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

    @Query private var appSettingsList: [AppSettings]

    private var appSettings: AppSettings? {
        appSettingsList.first
    }

    private var pressureUnit: PressureUnit {
        appSettings?.pressureUnit ?? .bar
    }

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
                let convertedVal = UnitConversion.pressure(fromBar: val, to: pressureUnit)
                let precision = pressureUnit == .psi ? 0 : 2
                Text(
                    String(
                        format: "%@ %.\(precision)f %@ of %@",
                        actionText,
                        convertedVal,
                        pressureUnit.symbol,
                        label
                    )
                )
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)

                let initialPres = pressureRange.initial.isNaN ? 0 : pressureRange.initial
                let finalPres = pressureRange.final.isNaN ? 0 : pressureRange.final
                let convertedInitial = UnitConversion.pressure(fromBar: initialPres, to: pressureUnit)
                let convertedFinal = UnitConversion.pressure(fromBar: finalPres, to: pressureUnit)
                Text(
                    String(
                        format: "%.\(precision)f %@ → %.\(precision)f %@",
                        convertedInitial,
                        pressureUnit.symbol,
                        convertedFinal,
                        pressureUnit.symbol
                    )
                )
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
