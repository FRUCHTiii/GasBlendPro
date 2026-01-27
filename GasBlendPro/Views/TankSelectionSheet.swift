import SwiftUI
import SwiftData

// MARK: - Tank Selection Sheet
struct TankSelectionSheet: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query private var appSettingsList: [AppSettings]

    let gasType: GasType
    let volumeNeeded: Double
    let tanks: [StorageTank]
    let onDeducted: () -> Void

    private var appSettings: AppSettings? {
        appSettingsList.first
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(tanks) { tank in
                    TankSelectionRow(
                        tank: tank,
                        volumeNeeded: volumeNeeded,
                        temperature: appSettings?.gasTemperature ?? 20.0
                    ) {
                        useTank(tank)
                    }
                    .id("\(tank.id)-\(appSettings?.gasTemperature ?? 20.0)")
                }
            }
            .navigationTitle("Select \(gasType.rawValue) Tank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func useTank(_ tank: StorageTank) {
        let temperature = appSettings?.gasTemperature ?? 20.0
        tank.deductUsage(volumeUsed: volumeNeeded, temperature: temperature)
        onDeducted()
        dismiss()
    }
}

struct TankSelectionRow: View {
    let tank: StorageTank
    let volumeNeeded: Double
    let temperature: Double
    let onSelect: () -> Void

    @Query private var appSettingsList: [AppSettings]

    private var appSettings: AppSettings? {
        appSettingsList.first
    }

    private var pressureUnit: PressureUnit {
        appSettings?.pressureUnit ?? .bar
    }

    private var hasEnoughGas: Bool {
        tank.hasEnoughGas(volumeNeeded: volumeNeeded, temperature: temperature)
    }

    private var pressureNeeded: Double {
        RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: tank.tankVolume,
            storageTankPressure: tank.currentPressure,
            gasType: tank.gasType,
            temperature: temperature
        )
    }

    private var remainingPressure: Double {
        max(0, tank.currentPressure - pressureNeeded)
    }

    private var remainingPercentage: Double {
        guard tank.maxPressure > 0 else { return 0 }
        return (remainingPressure / tank.maxPressure) * 100.0
    }

    var body: some View {
        Button {
            if hasEnoughGas {
                onSelect()
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tank.name)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)

                        HStack(spacing: 6) {
                            Text("\(Int(tank.tankVolume))L")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            if tank.purity < 100 {
                                Text("•")
                                    .foregroundColor(.secondary)

                                Text(String(format: "%.1f%% purity", tank.purity))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.0f%%", tank.percentageFilled))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(fillLevelColor)

                        Text(pressureDisplayText(current: tank.currentPressure, max: tank.maxPressure))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                if hasEnoughGas {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Text("After use:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(afterUseText(pressure: remainingPressure, percentage: remainingPercentage))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(remainingFillLevelColor)
                    }
                    .padding(.top, 4)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)

                        Text("Insufficient gas in tank")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .disabled(!hasEnoughGas)
        .opacity(hasEnoughGas ? 1.0 : 0.5)
    }

    private var fillLevelColor: Color {
        let percentage = tank.percentageFilled
        if percentage > 50 {
            return .green
        } else if percentage > 20 {
            return .orange
        } else {
            return .red
        }
    }

    private var remainingFillLevelColor: Color {
        if remainingPercentage > 50 {
            return .green
        } else if remainingPercentage > 20 {
            return .orange
        } else {
            return .red
        }
    }

    private func pressureDisplayText(current: Double, max: Double) -> String {
        let currentConverted = UnitConversion.pressure(fromBar: current, to: pressureUnit)
        let maxConverted = UnitConversion.pressure(fromBar: max, to: pressureUnit)
        let precision = pressureUnit == .psi ? 0 : 0
        return String(
            format: "%.\(precision)f / %.\(precision)f %@",
            currentConverted,
            maxConverted,
            pressureUnit.symbol
        )
    }

    private func afterUseText(pressure: Double, percentage: Double) -> String {
        let converted = UnitConversion.pressure(fromBar: pressure, to: pressureUnit)
        let precision = pressureUnit == .psi ? 0 : 0
        return String(format: "%.\(precision)f %@ (%.0f%%)", converted, pressureUnit.symbol, percentage)
    }
}
