import SwiftUI
import SwiftData

struct BlendingCalculatorView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \GasPreset.createdAt)
    private var presets: [GasPreset]
    @Query private var settings: [AppSettings]

    // Session persistence - survives navigation but not app restart
    @AppStorage("session.currentOxygen")
    private var sessionCurrentOxygen: Double?
    @AppStorage("session.currentHelium")
    private var sessionCurrentHelium: Double?
    @AppStorage("session.currentPressure")
    private var sessionCurrentPressure: Double?
    @AppStorage("session.targetOxygen")
    private var sessionTargetOxygen: Double?
    @AppStorage("session.targetHelium")
    private var sessionTargetHelium: Double?
    @AppStorage("session.targetPressure")
    private var sessionTargetPressure: Double?
    @AppStorage("session.tankVolume")
    private var sessionTankVolume: Double?
    @AppStorage("session.resultJSON")
    private var sessionResultJSON: String?
    @AppStorage("session.hasActiveSession")
    private var hasActiveSession: Bool = false

    @State private var currentMix = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
    @State private var currentPressure: Double = 100
    @State private var targetMix = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
    @State private var targetPressure: Double = 200
    @State private var currentHelium: Double = 0
    @State private var targetHelium: Double = 0
    @State private var topupMix = CommonGasMixes.air
    @State private var tankVolume: Double = 12
    @State private var blendingResult: BlendingResult?
    @State private var selectedCurrentPreset: GasPreset?
    @State private var selectedTargetPreset: GasPreset?
    @State private var showCurrentPresetPicker = false
    @State private var showTargetPresetPicker = false
    @State private var errorMessage: String?
    @State private var isCurrentPresetManuallyChanged = false
    @State private var isTargetPresetManuallyChanged = false
    @State private var isInitialized = false

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                if let error = errorMessage {
                    errorBannerView(error)
                }

                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            currentMixCardView
                            targetMixCardView
                            tankConfigCardView

                            if let result = blendingResult {
                                resultsCardView(result)
                                    .id("results")
                            }

                            Spacer().frame(height: 12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: blendingResult) {
                        withAnimation {
                            scrollProxy.scrollTo("results", anchor: .top)
                        }
                    }
                }

                calculateButtonView
            }
        }
        .navigationTitle("Blender")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    resetToDefaults()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 17))
                }
            }
        }
        .onAppear {
            if !isInitialized {
                initializePresets()
                isInitialized = true
            }
        }
        .onChange(of: currentMix.oxygen) { saveSession() }
        .onChange(of: currentHelium) { saveSession() }
        .onChange(of: currentPressure) { saveSession() }
        .onChange(of: targetMix.oxygen) { saveSession() }
        .onChange(of: targetHelium) { saveSession() }
        .onChange(of: targetPressure) { saveSession() }
        .onChange(of: tankVolume) { saveSession() }
        .onChange(of: blendingResult) { saveSession() }
    }

    // MARK: - View Components

    private var backgroundView: some View {
        Group {
            if #available(iOS 16.0, *) {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.98, green: 0.98, blue: 1.0)
                    .ignoresSafeArea()
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blender")
                .font(.system(size: 32, weight: .bold, design: .default))
                .tracking(-0.5)

            Text("Precise Gas Mix Calculator")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func errorBannerView(_ error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)

            Text(error)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.red)

            Spacer()
        }
        .padding(12)
        .background(Color(red: 1.0, green: 0.92, blue: 0.92))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private var currentMixCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Mix")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                AppleInputField(label: "O₂", value: $currentMix.oxygen, unit: "%")
                AppleInputField(label: "He", value: $currentHelium, unit: "%")
                AppleInputField(label: "Pressure", value: $currentPressure, unit: "bar")
            }

            currentPresetPickerView
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
        .onChange(of: currentMix.oxygen) {
            if !isCurrentPresetManuallyChanged {
                checkAndUpdateCurrentPreset()
            }
            isCurrentPresetManuallyChanged = false
        }
        .onChange(of: currentHelium) {
            if !isCurrentPresetManuallyChanged {
                checkAndUpdateCurrentPreset()
            }
            isCurrentPresetManuallyChanged = false
        }
    }

    private var targetMixCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Mix")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                AppleInputField(label: "O₂", value: $targetMix.oxygen, unit: "%")
                AppleInputField(label: "He", value: $targetHelium, unit: "%")
                AppleInputField(label: "Pressure", value: $targetPressure, unit: "bar")
            }

            presetMenuView
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
        .onChange(of: targetMix.oxygen) {
            if !isTargetPresetManuallyChanged {
                checkAndUpdateTargetPreset()
            }
            isTargetPresetManuallyChanged = false
        }
        .onChange(of: targetHelium) {
            if !isTargetPresetManuallyChanged {
                checkAndUpdateTargetPreset()
            }
            isTargetPresetManuallyChanged = false
        }
    }

    private var currentPresetPickerView: some View {
        Button {
            showCurrentPresetPicker = true
        } label: {
            presetPickerButtonContent(selectedPreset: selectedCurrentPreset)
        }
        .sheet(isPresented: $showCurrentPresetPicker) {
            presetPickerSheet(
                title: "Current Mix Preset",
                selectedPreset: $selectedCurrentPreset,
                isPresented: $showCurrentPresetPicker
            ) { preset in
                handleCurrentPresetChange(preset: preset)
            }
        }
    }

    private var presetMenuView: some View {
        Button {
            showTargetPresetPicker = true
        } label: {
            presetPickerButtonContent(selectedPreset: selectedTargetPreset)
        }
        .sheet(isPresented: $showTargetPresetPicker) {
            presetPickerSheet(
                title: "Target Mix Preset",
                selectedPreset: $selectedTargetPreset,
                isPresented: $showTargetPresetPicker
            ) { preset in
                handleTargetPresetChange(preset: preset)
            }
        }
    }

    private func presetPickerButtonContent(selectedPreset: GasPreset?) -> some View {
        HStack {
            Text(selectedPreset?.name ?? "Custom")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemFill))
        .cornerRadius(8)
    }

    private func presetPickerSheet(
        title: String,
        selectedPreset: Binding<GasPreset?>,
        isPresented: Binding<Bool>,
        onSelect: @escaping (GasPreset?) -> Void
    ) -> some View {
        NavigationView {
            VStack {
                Picker("Preset", selection: selectedPreset) {
                    Text("Custom").tag(nil as GasPreset?)
                    ForEach(presets) { preset in
                        Text(preset.name).tag(preset as GasPreset?)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSelect(selectedPreset.wrappedValue)
                        isPresented.wrappedValue = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }

    private var tankConfigCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tank Configuration")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            AppleInputField(label: "Volume", value: $tankVolume, unit: "L")

            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14, weight: .semibold))
                Text("Top-up gas: Air (21% O₂)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private func resultsCardView(_ result: BlendingResult) -> some View {
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

            finalMixView(result)

            HStack(spacing: 12) {
                oxygenVolumeView(result)
                if result.heliumVolume > 0.01 {
                    heliumVolumeView(result)
                }
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private func finalMixView(_ result: BlendingResult) -> some View {
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

    private func oxygenVolumeView(_ result: BlendingResult) -> some View {
        let o2VolumeVal = result.oxygenVolume.isNaN || result.oxygenVolume.isInfinite ? 0 : result.oxygenVolume

        return VStack(spacing: 8) {
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
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .cardBackground()
        .cornerRadius(12)
    }

    private func heliumVolumeView(_ result: BlendingResult) -> some View {
        let heVolumeVal = result.heliumVolume.isNaN || result.heliumVolume.isInfinite ? 0 : result.heliumVolume

        return VStack(spacing: 8) {
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
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .cardBackground()
        .cornerRadius(12)
    }

    private var calculateButtonView: some View {
        Button(action: performCalculation) {
            Text("Calculate")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.48, blue: 1.0),
                            Color(red: 0.0, green: 0.42, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func performCalculation() {
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        // Clear previous error and result
        errorMessage = nil
        blendingResult = nil

        // Validation checks
        if let error = validateInputs() {
            errorMessage = error
            return
        }

        // Update mixes with calculated nitrogen and helium
        let adjustedCurrentMix = createAdjustedMix(oxygen: currentMix.oxygen, helium: currentHelium)
        let adjustedTargetMix = createAdjustedMix(oxygen: targetMix.oxygen, helium: targetHelium)

        // Final validation - ensure mixes are valid
        if !adjustedCurrentMix.isValid {
            errorMessage = "Current mix invalid"
            return
        }
        if !adjustedTargetMix.isValid {
            errorMessage = "Target mix invalid"
            return
        }

        calculateAndSetResult(
            adjustedCurrentMix: adjustedCurrentMix,
            adjustedTargetMix: adjustedTargetMix
        )
    }

    private func validateInputs() -> String? {
        if currentMix.oxygen < 0 || currentMix.oxygen > 100 {
            return "Current O₂ must be between 0-100%"
        }
        if currentHelium < 0 || currentHelium > 100 {
            return "Current He must be between 0-100%"
        }
        if targetMix.oxygen < 0 || targetMix.oxygen > 100 {
            return "Target O₂ must be between 0-100%"
        }
        if targetHelium < 0 || targetHelium > 100 {
            return "Target He must be between 0-100%"
        }

        let currentTotal = currentMix.oxygen + currentHelium
        if currentTotal > 100 {
            return "Current gas mix exceeds 100% (O₂ + He > 100)"
        }

        let targetTotal = targetMix.oxygen + targetHelium
        if targetTotal > 100 {
            return "Target gas mix exceeds 100% (O₂ + He > 100)"
        }

        if currentPressure < 0 || currentPressure > 500 {
            return "Current pressure must be between 0-500 bar"
        }
        if targetPressure <= 0 || targetPressure > 500 {
            return "Target pressure must be between 0-500 bar"
        }
        if targetPressure < currentPressure {
            return "Target pressure must be ≥ current pressure"
        }
        if tankVolume <= 0 || tankVolume > 50 {
            return "Tank volume must be between 0-50 liters"
        }

        return nil
    }

    private func createAdjustedMix(oxygen: Double, helium: Double) -> GasMix {
        GasMix(
            oxygen: oxygen,
            nitrogen: max(0, 100.0 - oxygen - helium),
            helium: helium
        )
    }

    private func calculateAndSetResult(
        adjustedCurrentMix: GasMix,
        adjustedTargetMix: GasMix
    ) {
        let result = BlendingCalculator.calculateBlend(
            currentMix: adjustedCurrentMix,
            currentPressure: currentPressure,
            targetMix: adjustedTargetMix,
            targetPressure: targetPressure,
            topupMix: topupMix,
            tankVolume: tankVolume
        )

        if let result = result {
            blendingResult = result
        } else {
            setCalculationError(
                currentMix: adjustedCurrentMix,
                targetMix: adjustedTargetMix
            )
        }
    }

    private func setCalculationError(currentMix: GasMix, targetMix: GasMix) {
        if targetMix.oxygen < currentMix.oxygen && currentPressure < 10 {
            errorMessage = "Cannot reduce oxygen percentage - starting pressure too low. " +
                "Increase starting pressure or adjust target mix."
        } else if targetMix.helium < currentMix.helium {
            errorMessage = "Cannot remove helium from the mix. " +
                "Start with a lower helium percentage."
        } else {
            errorMessage = "This blend is not possible with available gases (Air, O₂, He). " +
                "Try adjusting your target mix."
        }
    }

    private func handleCurrentPresetChange(preset: GasPreset?) {
        selectedCurrentPreset = preset
        isCurrentPresetManuallyChanged = true
        if let preset = preset {
            currentMix = GasMix(oxygen: preset.oxygen, nitrogen: preset.gasMix.nitrogen, helium: preset.helium)
            currentHelium = preset.helium
        }
    }

    private func handleTargetPresetChange(preset: GasPreset?) {
        selectedTargetPreset = preset
        isTargetPresetManuallyChanged = true
        if let preset = preset {
            targetMix = GasMix(oxygen: preset.oxygen, nitrogen: preset.gasMix.nitrogen, helium: preset.helium)
            targetHelium = preset.helium
        }
    }

    private func checkAndUpdateCurrentPreset() {
        // Check if current values match any preset
        let matchingPreset = presets.first { preset in
            abs(preset.oxygen - currentMix.oxygen) < 0.1 &&
            abs(preset.helium - currentHelium) < 0.1
        }
        selectedCurrentPreset = matchingPreset
    }

    private func checkAndUpdateTargetPreset() {
        // Check if target values match any preset
        let matchingPreset = presets.first { preset in
            abs(preset.oxygen - targetMix.oxygen) < 0.1 &&
            abs(preset.helium - targetHelium) < 0.1
        }
        selectedTargetPreset = matchingPreset
    }

    private func initializePresets() {
        // Check if there's an active session to restore
        if hasActiveSession, let sessionCO2 = sessionCurrentOxygen,
           let sessionCHe = sessionCurrentHelium,
           let sessionCP = sessionCurrentPressure,
           let sessionTO2 = sessionTargetOxygen,
           let sessionTHe = sessionTargetHelium,
           let sessionTP = sessionTargetPressure,
           let sessionTV = sessionTankVolume {
            // Restore from session
            currentMix = GasMix(oxygen: sessionCO2, nitrogen: max(0, 100 - sessionCO2 - sessionCHe), helium: sessionCHe)
            currentHelium = sessionCHe
            currentPressure = sessionCP
            targetMix = GasMix(oxygen: sessionTO2, nitrogen: max(0, 100 - sessionTO2 - sessionTHe), helium: sessionTHe)
            targetHelium = sessionTHe
            targetPressure = sessionTP
            tankVolume = sessionTV

            // Restore calculation result if available
            if let resultJSON = sessionResultJSON,
               let resultData = resultJSON.data(using: .utf8),
               let result = try? JSONDecoder().decode(BlendingResult.self, from: resultData) {
                blendingResult = result
            }
        } else {
            // Load defaults from settings
            if let appSettings = settings.first {
                currentMix = appSettings.defaultCurrentMix
                currentHelium = appSettings.defaultCurrentHelium
                targetMix = appSettings.defaultTargetMix
                targetHelium = appSettings.defaultTargetHelium
                targetPressure = appSettings.defaultTargetPressure
            }
        }

        // Initialize current preset based on loaded values
        checkAndUpdateCurrentPreset()

        // Initialize target preset based on loaded values
        checkAndUpdateTargetPreset()
    }

    private func saveSession() {
        sessionCurrentOxygen = currentMix.oxygen
        sessionCurrentHelium = currentHelium
        sessionCurrentPressure = currentPressure
        sessionTargetOxygen = targetMix.oxygen
        sessionTargetHelium = targetHelium
        sessionTargetPressure = targetPressure
        sessionTankVolume = tankVolume

        // Save calculation result if available
        if let result = blendingResult,
           let resultData = try? JSONEncoder().encode(result),
           let resultJSON = String(data: resultData, encoding: .utf8) {
            sessionResultJSON = resultJSON
        } else {
            sessionResultJSON = nil
        }

        hasActiveSession = true
    }

    private func resetToDefaults() {
        // Clear session
        hasActiveSession = false
        sessionCurrentOxygen = nil
        sessionCurrentHelium = nil
        sessionCurrentPressure = nil
        sessionTargetOxygen = nil
        sessionTargetHelium = nil
        sessionTargetPressure = nil
        sessionTankVolume = nil
        sessionResultJSON = nil

        // Clear results and errors
        blendingResult = nil
        errorMessage = nil

        // Load defaults from settings
        if let appSettings = settings.first {
            currentMix = appSettings.defaultCurrentMix
            currentHelium = appSettings.defaultCurrentHelium
            targetMix = appSettings.defaultTargetMix
            targetHelium = appSettings.defaultTargetHelium
            targetPressure = appSettings.defaultTargetPressure
        }

        // Reset to default pressure
        currentPressure = 100
        tankVolume = 12

        // Update presets
        checkAndUpdateCurrentPreset()
        checkAndUpdateTargetPreset()
    }

    private func calculateStepNumbers(for result: BlendingResult) -> BlendingStepNumbers {
        let releaseStep = 1
        var currentStep = releaseStep

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

// MARK: - Blending Step Numbers
struct BlendingStepNumbers {
    let release: Int
    let helium: Int
    let oxygen: Int
    let air: Int
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

// MARK: - View Extension for Card Background
extension View {
    func cardBackground() -> some View {
        self.background(
            Group {
                if #available(iOS 15.0, *) {
                    Color(uiColor: .secondarySystemBackground)
                } else {
                    Color.white
                }
            }
        )
    }
}

#Preview {
    BlendingCalculatorView()
}
