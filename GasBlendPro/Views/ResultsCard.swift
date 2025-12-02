import SwiftUI
import SwiftData

// MARK: - Results Card View
struct ResultsCard: View {
    let result: BlendingResult
    let currentPressure: Double
    let storageTanks: [StorageTank]
    @Binding var showOxygenTankPicker: Bool
    @Binding var showHeliumTankPicker: Bool
    @Binding var oxygenDeducted: Bool
    @Binding var heliumDeducted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Blending Steps")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            VStack(spacing: 12) {
                // Calculate step numbers
                let steps = calculateStepNumbers(for: result)
                let releaseStep = steps.release
                let heliumStep = steps.helium
                let oxygenStep = steps.oxygen
                let airStep = steps.air

                // Release Air step (if needed)
                if result.airToRelease > 0.01 {
                    AppleResultRow(
                        step: releaseStep,
                        label: "Air",
                        value: result.airToRelease,
                        pressureRange: PressureRange(
                            initial: currentPressure,
                            final: result.pressureAfterRelease
                        ),
                        isRelease: true
                    )
                }

                // Add Helium step (if needed)
                if result.heliumToAdd > 0.01 {
                    AppleResultRow(
                        step: heliumStep,
                        label: "Helium",
                        value: result.heliumToAdd,
                        pressureRange: PressureRange(
                            initial: result.pressureAfterRelease,
                            final: result.pressureAfterHelium
                        ),
                        isRelease: false
                    )
                }

                // Add Oxygen step (if needed - only show if > 0.01)
                if result.oxygenToAdd > 0.01 {
                    let heliumAddition = result.heliumToAdd > 0.01 ? result.heliumToAdd : 0
                    let o2InitialPressure = result.pressureAfterRelease + heliumAddition
                    let o2FinalPressure = o2InitialPressure + result.oxygenToAdd
                    AppleResultRow(
                        step: oxygenStep,
                        label: "Oxygen",
                        value: result.oxygenToAdd,
                        pressureRange: PressureRange(initial: o2InitialPressure, final: o2FinalPressure),
                        isRelease: false
                    )
                }

                // Add Air step
                let heliumAddition = result.heliumToAdd > 0.01 ? result.heliumToAdd : 0
                let oxygenAddition = result.oxygenToAdd > 0.01 ? result.oxygenToAdd : 0
                let airInitialPressure = result.pressureAfterRelease + heliumAddition + oxygenAddition
                AppleResultRow(
                    step: airStep,
                    label: "Air",
                    value: result.airToAdd,
                    pressureRange: PressureRange(
                        initial: airInitialPressure,
                        final: result.pressureAfterOxygen
                    ),
                    isRelease: false
                )
            }

            FinalMixView(result: result)

            GasUsageSummaryView(
                result: result,
                oxygenTanks: oxygenTanks,
                heliumTanks: heliumTanks,
                showOxygenTankPicker: $showOxygenTankPicker,
                showHeliumTankPicker: $showHeliumTankPicker,
                oxygenDeducted: $oxygenDeducted,
                heliumDeducted: $heliumDeducted
            )
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private var oxygenTanks: [StorageTank] {
        storageTanks.filter { $0.gasType == .oxygen }
    }

    private var heliumTanks: [StorageTank] {
        storageTanks.filter { $0.gasType == .helium }
    }

    private func calculateStepNumbers(for result: BlendingResult) -> BlendingStepNumbers {
        var currentStep = 0

        let releaseStep = 1
        if result.airToRelease > 0.01 {
            currentStep += 1
        }
        let heliumStep = currentStep

        if result.heliumToAdd > 0.01 {
            currentStep += 1
        }
        let oxygenStep = currentStep

        if result.oxygenToAdd > 0.01 {
            currentStep += 1
        }
        let airStep = currentStep

        return BlendingStepNumbers(
            release: releaseStep,
            helium: heliumStep,
            oxygen: oxygenStep,
            air: airStep
        )
    }
}

// MARK: - Final Mix View
struct FinalMixView: View {
    let result: BlendingResult

    var body: some View {
        VStack(spacing: 12) {
            Text("Final Gas Mix")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                AppleFinalMixComponent(label: "O₂", value: result.finalMix.oxygen, accentColor: .green)
                Divider().frame(height: 40)

                if result.finalMix.helium > 0.1 {
                    AppleFinalMixComponent(label: "He", value: result.finalMix.helium, accentColor: .purple)
                    Divider().frame(height: 40)
                }

                AppleFinalMixComponent(label: "N₂", value: result.finalMix.nitrogen, accentColor: .indigo)
                Spacer()
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(8)
        }
    }
}

// MARK: - Oxygen Volume View
struct OxygenVolumeView: View {
    let result: BlendingResult
    let oxygenTanks: [StorageTank]
    @Binding var showOxygenTankPicker: Bool

    var body: some View {
        let o2VolumeVal = result.oxygenVolume.isNaN || result.oxygenVolume.isInfinite ? 0 : result.oxygenVolume
        let hasOxygen = result.oxygenToAdd > 0.01

        VStack(spacing: 8) {
            VStack(alignment: .center, spacing: 4) {
                Text("Oxygen")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f L", o2VolumeVal))
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.green)
            }
            Image(systemName: "drop.fill")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.green)
                .opacity(0.3)

            if hasOxygen && !oxygenTanks.isEmpty {
                Button {
                    showOxygenTankPicker = true
                } label: {
                    Label("Use from Tank", systemImage: "square.stack.3d.up")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .cardBackground()
        .cornerRadius(12)
    }
}

// MARK: - Helium Volume View
struct HeliumVolumeView: View {
    let result: BlendingResult
    let heliumTanks: [StorageTank]
    @Binding var showHeliumTankPicker: Bool

    var body: some View {
        let heVolumeVal = result.heliumVolume.isNaN || result.heliumVolume.isInfinite ? 0 : result.heliumVolume
        let hasHelium = result.heliumToAdd > 0.01

        VStack(spacing: 8) {
            VStack(alignment: .center, spacing: 4) {
                Text("Helium")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f L", heVolumeVal))
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.purple)
            }
            Image(systemName: "balloon.fill")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.purple)
                .opacity(0.3)

            if hasHelium && !heliumTanks.isEmpty {
                Button {
                    showHeliumTankPicker = true
                } label: {
                    Label("Use from Tank", systemImage: "square.stack.3d.up")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .cardBackground()
        .cornerRadius(12)
    }
}

// MARK: - Gas Usage Summary View
struct GasUsageSummaryView: View {
    let result: BlendingResult
    let oxygenTanks: [StorageTank]
    let heliumTanks: [StorageTank]
    @Binding var showOxygenTankPicker: Bool
    @Binding var showHeliumTankPicker: Bool
    @Binding var oxygenDeducted: Bool
    @Binding var heliumDeducted: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Gas Usage from Storage")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                // Oxygen usage
                if result.oxygenVolume > 0.01 {
                    GasUsageComponent(
                        label: "O₂",
                        volume: result.oxygenVolume,
                        accentColor: .green,
                        hasTanks: !oxygenTanks.isEmpty,
                        isDeducted: oxygenDeducted
                    ) {
                        if !oxygenDeducted {
                            showOxygenTankPicker = true
                        }
                    }

                    if result.heliumVolume > 0.1 {
                        Divider().frame(height: 40)
                    }
                }

                // Helium usage
                if result.heliumVolume > 0.1 {
                    GasUsageComponent(
                        label: "He",
                        volume: result.heliumVolume,
                        accentColor: .purple,
                        hasTanks: !heliumTanks.isEmpty,
                        isDeducted: heliumDeducted
                    ) {
                        if !heliumDeducted {
                            showHeliumTankPicker = true
                        }
                    }
                }

                Spacer()
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(8)
        }
    }
}

// MARK: - Gas Usage Component
struct GasUsageComponent: View {
    let label: String
    let volume: Double
    let accentColor: Color
    let hasTanks: Bool
    let isDeducted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center, spacing: 6) {
                HStack(spacing: 4) {
                    Text(label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    if isDeducted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }

                let val = volume.isNaN ? 0 : volume
                Text(String(format: "%.1f", val))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isDeducted ? .secondary : accentColor)

                Text("Liters")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)

                if hasTanks && !isDeducted {
                    Text("Tap to use")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(accentColor)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(isDeducted || !hasTanks)
        .opacity(isDeducted ? 0.6 : 1.0)
    }
}

// MARK: - Blending Step Numbers
struct BlendingStepNumbers {
    let release: Int
    let helium: Int
    let oxygen: Int
    let air: Int
}
