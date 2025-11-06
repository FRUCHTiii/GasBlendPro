import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \GasPreset.createdAt)
    private var presets: [GasPreset]
    @Query private var settings: [AppSettings]
    @State private var showingAppearancePicker = false

    private var appSettings: AppSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    var body: some View {
        ZStack {
            backgroundView

            List {
                Section {
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
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
