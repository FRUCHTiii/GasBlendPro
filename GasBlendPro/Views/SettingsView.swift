import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \GasPreset.createdAt)
    private var presets: [GasPreset]
    @Query private var settings: [AppSettings]
    @State private var showingAppearancePicker = false
    @State private var showingCurrentPresetPicker = false
    @State private var showingTargetPresetPicker = false

    private var appSettings: AppSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    private var currentPresetName: String {
        presets.first { preset in
            abs(preset.oxygen - appSettings.defaultCurrentOxygen) < 0.1 &&
            abs(preset.helium - appSettings.defaultCurrentHelium) < 0.1
        }?.name ?? "Custom"
    }

    private var targetPresetName: String {
        presets.first { preset in
            abs(preset.oxygen - appSettings.defaultTargetOxygen) < 0.1 &&
            abs(preset.helium - appSettings.defaultTargetHelium) < 0.1
        }?.name ?? "Custom"
    }

    var body: some View {
        ZStack {
            backgroundView

            List {
                Section(header: Text("Blender Defaults")) {
                    Button {
                        showingCurrentPresetPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "cylinder.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Current Mix")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(currentPresetName)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        showingTargetPresetPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "cylinder.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                                .frame(width: 28)

                            Text("Target Mix")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(targetPresetName)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Image(systemName: "gauge.high")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                            .frame(width: 28)

                        Text("Target Pressure")
                            .font(.system(size: 17))

                        Spacer()

                        TextField(
                            "200",
                            value: Binding(
                                get: { appSettings.defaultTargetPressure },
                                set: { appSettings.defaultTargetPressure = $0 }
                            ),
                            format: .number.precision(.fractionLength(0))
                        )
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onSubmit {
                            let selector = #selector(UIResponder.resignFirstResponder)
                            UIApplication.shared.sendAction(selector, to: nil, from: nil, for: nil)
                        }

                        Text("bar")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("General")) {
                    Button {
                        showingAppearancePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Appearance")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(appSettings.appearanceMode.displayName)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: GasPresetsView()) {
                        HStack {
                            Image(systemName: "cylinder.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Gas Presets")
                                .font(.system(size: 17))

                            Spacer()

                            Text("\(presets.count)")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAppearancePicker) {
            appearancePickerSheet
        }
        .sheet(isPresented: $showingCurrentPresetPicker) {
            presetPickerSheet(title: "Current Mix") { preset in
                appSettings.defaultCurrentOxygen = preset.oxygen
                appSettings.defaultCurrentHelium = preset.helium
                showingCurrentPresetPicker = false
            }
        }
        .sheet(isPresented: $showingTargetPresetPicker) {
            presetPickerSheet(title: "Target Mix") { preset in
                appSettings.defaultTargetOxygen = preset.oxygen
                appSettings.defaultTargetHelium = preset.helium
                showingTargetPresetPicker = false
            }
        }
        .onAppear {
            initializeDefaultPresets()
        }
    }

    private var backgroundView: some View {
        Group {
            if #available(iOS 16.0, *) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
            }
        }
    }

    private var appearancePickerSheet: some View {
        NavigationView {
            VStack {
                Picker("Appearance", selection: Binding(
                    get: { appSettings.appearanceMode },
                    set: { appSettings.appearanceMode = $0 }
                )) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingAppearancePicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }

    private func initializeDefaultPresets() {
        PresetManager.initializeDefaults(in: modelContext, existingPresets: Array(presets))
    }

    private func presetCompositionText(_ preset: GasPreset) -> String {
        String(format: "O₂: %.0f%%  •  He: %.0f%%", preset.oxygen, preset.helium)
    }

    private func presetPickerSheet(
        title: String,
        onSelect: @escaping (GasPreset) -> Void
    ) -> some View {
        NavigationView {
            ZStack {
                backgroundView

                List {
                    ForEach(presets) { preset in
                        Button {
                            onSelect(preset)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)

                                    Text(presetCompositionText(preset))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if title == "Current Mix" {
                            showingCurrentPresetPicker = false
                        } else {
                            showingTargetPresetPicker = false
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
