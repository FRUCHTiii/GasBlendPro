import SwiftUI
import SwiftData

struct AddStorageTankView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""
    @State private var gasType: GasType = .oxygen
    @State private var tankVolume = ""
    @State private var maxPressure = ""
    @State private var currentPressure = ""
    @State private var purity = "100.0"
    @State private var showGasTypePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tank Information")) {
                    TextField("Tank Name", text: $name)
                        .autocapitalization(.words)
                        .textContentType(.name)
                        .submitLabel(.next)

                    Button {
                        showGasTypePicker = true
                    } label: {
                        HStack {
                            Text("Gas Type")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(gasType.rawValue)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Tank Specifications")) {
                    HStack {
                        TextField("Volume", text: $tankVolume)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        Text("Liters")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Max Pressure", text: $maxPressure)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        Text("bar")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Current Pressure", text: $currentPressure)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        Text("bar")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Purity", text: $purity)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }

                if let preview = previewText {
                    Section(header: Text("Summary")) {
                        Text(preview)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Storage Tank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTank()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showGasTypePicker) {
                gasTypePickerSheet
            }
        }
    }

    private var gasTypePickerSheet: some View {
        NavigationView {
            VStack {
                Picker("Gas Type", selection: $gasType) {
                    Text("Oxygen").tag(GasType.oxygen)
                    Text("Helium").tag(GasType.helium)
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle("Gas Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showGasTypePicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(250)])
    }

    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let volume = Double(tankVolume), volume > 0,
              let maxP = Double(maxPressure), maxP > 0,
              let currentP = Double(currentPressure), currentP >= 0,
              let purityValue = Double(purity), purityValue > 0, purityValue <= 100
        else { return false }

        return currentP <= maxP
    }

    private var previewText: String? {
        guard let maxP = Double(maxPressure),
              let currentP = Double(currentPressure),
              let purityValue = Double(purity),
              isValid
        else { return nil }

        let percentage = (currentP / maxP) * 100.0
        return String(
            format: "%@ tank: %@ L at %.0f bar (%.0f%% full) with %.1f%% purity",
            gasType.rawValue,
            tankVolume,
            currentP,
            percentage,
            purityValue
        )
    }

    private func addTank() {
        let tank = StorageTank(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            gasType: gasType,
            currentPressure: Double(currentPressure) ?? 0,
            maxPressure: Double(maxPressure) ?? 0,
            tankVolume: Double(tankVolume) ?? 0,
            purity: Double(purity) ?? 100.0
        )

        modelContext.insert(tank)
        dismiss()
    }
}

struct EditStorageTankView: View {
    @Environment(\.dismiss)
    private var dismiss
    let tank: StorageTank

    @State private var name = ""
    @State private var tankVolume = ""
    @State private var maxPressure = ""
    @State private var currentPressure = ""
    @State private var purity = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tank Information")) {
                    TextField("Tank Name", text: $name)
                        .autocapitalization(.words)
                        .textContentType(.name)
                        .submitLabel(.next)

                    HStack {
                        Text("Gas Type")
                        Spacer()
                        Text(tank.gasTypeLabel)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Tank Specifications")) {
                    HStack {
                        TextField("Volume", text: $tankVolume)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        Text("Liters")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Max Pressure", text: $maxPressure)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        Text("bar")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Current Pressure", text: $currentPressure)
                            .keyboardType(.decimalPad)
                            .submitLabel(.next)
                        Text("bar")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Purity", text: $purity)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Summary")) {
                    HStack {
                        Text("Filled")
                        Spacer()
                        Text(String(format: "%.0f%%", tank.percentageFilled))
                            .foregroundColor(fillLevelColor)
                    }
                }
            }
            .navigationTitle("Edit Tank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTank()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadTankData()
            }
        }
    }

    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let volume = Double(tankVolume), volume > 0,
              let maxP = Double(maxPressure), maxP > 0,
              let currentP = Double(currentPressure), currentP >= 0,
              let purityValue = Double(purity), purityValue > 0, purityValue <= 100
        else { return false }

        return currentP <= maxP
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

    private func loadTankData() {
        name = tank.name
        tankVolume = String(format: "%.0f", tank.tankVolume)
        maxPressure = String(format: "%.0f", tank.maxPressure)
        currentPressure = String(format: "%.0f", tank.currentPressure)
        purity = String(format: "%.1f", tank.purity)
    }

    private func saveTank() {
        tank.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        tank.tankVolume = Double(tankVolume) ?? tank.tankVolume
        tank.maxPressure = Double(maxPressure) ?? tank.maxPressure
        tank.currentPressure = Double(currentPressure) ?? tank.currentPressure
        tank.purity = Double(purity) ?? tank.purity

        dismiss()
    }
}

#Preview {
    AddStorageTankView()
}
