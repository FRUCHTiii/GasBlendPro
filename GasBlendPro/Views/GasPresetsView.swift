import SwiftUI
import SwiftData

struct GasPresetsView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \GasPreset.createdAt)
    private var presets: [GasPreset]
    @State private var showingAddPreset = false
    @State private var newPresetName = ""
    @State private var newPresetOxygen = 21.0
    @State private var newPresetHelium = 0.0

    var body: some View {
        ZStack {
            backgroundView

            List {
                ForEach(presets) { preset in
                    PresetListRow(preset: preset)
                }
                .onDelete(perform: deletePresets)

                if presets.isEmpty {
                    Text("No presets. Tap + to add one.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Gas Presets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddPreset = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPreset) {
            addPresetSheet
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

    private var addPresetSheet: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Name", text: $newPresetName)
                            .autocapitalization(.words)

                        HStack {
                            Text("Oxygen")
                            Spacer()
                            TextField("21", value: $newPresetOxygen, format: .number.precision(.fractionLength(0...1)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: newPresetOxygen) {
                                    newPresetOxygen = min(100, max(0, newPresetOxygen))
                                }
                            Text("%")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Helium")
                            Spacer()
                            TextField("0", value: $newPresetHelium, format: .number.precision(.fractionLength(0...1)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: newPresetHelium) {
                                    newPresetHelium = min(100, max(0, newPresetHelium))
                                }
                            Text("%")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Nitrogen")
                            Spacer()
                            let nitrogen = max(0, min(100, 100 - newPresetOxygen - newPresetHelium))
                            Text(String(format: "%.1f%%", nitrogen))
                                .foregroundColor(newPresetOxygen + newPresetHelium > 100 ? .red : .secondary)
                        }
                    } header: {
                        Text("Gas Composition")
                    }
                }
            }
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingAddPreset = false
                        resetAddPresetForm()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveNewPreset()
                    }
                    .disabled(newPresetName.isEmpty ||
                              newPresetName.count > 50 ||
                              newPresetOxygen + newPresetHelium > 100)
                }
            }
        }
    }

    private func initializeDefaultPresets() {
        PresetManager.initializeDefaults(in: modelContext, existingPresets: Array(presets))
    }

    private func saveNewPreset() {
        let preset = GasPreset(
            name: newPresetName,
            oxygen: newPresetOxygen,
            helium: newPresetHelium
        )
        modelContext.insert(preset)
        showingAddPreset = false
        resetAddPresetForm()
    }

    private func deletePresets(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(presets[index])
        }
    }

    private func resetAddPresetForm() {
        newPresetName = ""
        newPresetOxygen = 21.0
        newPresetHelium = 0.0
    }
}

struct PresetListRow: View {
    let preset: GasPreset

    var body: some View {
        HStack(spacing: 12) {
            // Gas composition badge
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)

                VStack(spacing: 1) {
                    Text(String(format: "%.0f", preset.oxygen))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.blue)
                    Text("/")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.blue.opacity(0.6))
                    Text(String(format: "%.0f", preset.helium))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(preset.name)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)

                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text(String(format: "O₂ %.0f%%", preset.oxygen))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    if preset.helium > 0.1 {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                            Text(String(format: "He %.0f%%", preset.helium))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.indigo)
                            .frame(width: 8, height: 8)
                        Text(String(format: "N₂ %.0f%%", preset.gasMix.nitrogen))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GasPresetsView()
    }
}
