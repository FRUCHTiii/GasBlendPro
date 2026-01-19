import SwiftUI
import SwiftData

struct AddStorageTankView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""
    @State private var gasType: GasType = .oxygen
    @State private var tankVolume: Double = 50
    @State private var maxPressure: Double = 200
    @State private var currentPressure: Double = 200
    @State private var purity: Double = 100.0
    @State private var showGasTypePicker = false

    var body: some View {
        NavigationView {
            ZStack {
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        tankInfoCard
                        specificationsCard
                        summaryCard
                        Spacer().frame(height: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
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
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showGasTypePicker) {
                gasTypePickerSheet
            }
        }
    }

    private var backgroundView: some View {
        Group {
            if #available(iOS 16.0, *) {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
            } else {
                Color(uiColor: .systemBackground)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }

    private var tankInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tank Information")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            // Tank Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Tank Name")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                TextField("e.g., O₂ Main", text: $name)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(8)
                    .autocapitalization(.words)
                    .submitLabel(.next)
            }

            // Gas Type Picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Gas Type")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                Button {
                    showGasTypePicker = true
                } label: {
                    HStack {
                        Text(gasType.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Spacer()

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private var specificationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tank Specifications")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                AppleInputField(label: "Volume", value: $tankVolume, unit: "L")
                AppleInputField(label: "Max Pressure", value: $maxPressure, unit: "bar")
            }

            HStack(spacing: 12) {
                AppleInputField(label: "Current Pressure", value: $currentPressure, unit: "bar")
                AppleInputField(label: "Purity", value: $purity, unit: "%")
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            if isValid {
                VStack(spacing: 8) {
                    HStack {
                        Text("Tank:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(name.isEmpty ? "Unnamed" : name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Type:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(gasType.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(gasType == .oxygen ? .green : .purple)
                    }

                    HStack {
                        Text("Capacity:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.0f L @ %.0f bar", tankVolume, maxPressure))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Current Fill:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%% (%.0f bar)", percentageFilled, currentPressure))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(fillLevelColor)
                    }

                    if purity < 100 {
                        HStack {
                            Text("Purity:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f%%", purity))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(12)
                .background(Color(uiColor: .tertiarySystemFill))
                .cornerRadius(8)
            } else {
                Text("Fill in all fields to see summary")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
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
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        tankVolume > 0 &&
        maxPressure > 0 &&
        currentPressure >= 0 &&
        currentPressure <= maxPressure &&
        purity > 0 && purity <= 100
    }

    private var percentageFilled: Double {
        guard maxPressure > 0 else { return 0 }
        return (currentPressure / maxPressure) * 100.0
    }

    private var fillLevelColor: Color {
        let percentage = percentageFilled
        if percentage > 50 {
            return .green
        } else if percentage > 20 {
            return .orange
        } else {
            return .red
        }
    }

    private func addTank() {
        let tank = StorageTank(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            gasType: gasType,
            currentPressure: currentPressure,
            maxPressure: maxPressure,
            tankVolume: tankVolume,
            purity: purity
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
    @State private var tankVolume: Double = 0
    @State private var maxPressure: Double = 0
    @State private var currentPressure: Double = 0
    @State private var purity: Double = 100.0

    var body: some View {
        NavigationView {
            ZStack {
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        tankInfoCard
                        specificationsCard
                        summaryCard
                        Spacer().frame(height: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
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
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadTankData()
            }
        }
    }

    private var backgroundView: some View {
        Group {
            if #available(iOS 16.0, *) {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
            } else {
                Color(uiColor: .systemBackground)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }

    private var tankInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tank Information")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            // Tank Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Tank Name")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                TextField("Tank name", text: $name)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .cornerRadius(8)
                    .autocapitalization(.words)
                    .submitLabel(.next)
            }

            // Gas Type (read-only)
            VStack(alignment: .leading, spacing: 6) {
                Text("Gas Type")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack {
                    Text(tank.gasTypeLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("Cannot be changed")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(10)
                .background(Color(uiColor: .quaternarySystemFill))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private var specificationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tank Specifications")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                AppleInputField(label: "Volume", value: $tankVolume, unit: "L")
                AppleInputField(label: "Max Pressure", value: $maxPressure, unit: "bar")
            }

            HStack(spacing: 12) {
                AppleInputField(label: "Current Pressure", value: $currentPressure, unit: "bar")
                AppleInputField(label: "Purity", value: $purity, unit: "%")
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Status")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            VStack(spacing: 8) {
                HStack {
                    Text("Fill Level:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.0f%%", percentageFilled))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(fillLevelColor)
                }

                HStack {
                    Text("Available Gas:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.0f L", currentPressure * tankVolume))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemFill))
            .cornerRadius(8)
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        tankVolume > 0 &&
        maxPressure > 0 &&
        currentPressure >= 0 &&
        currentPressure <= maxPressure &&
        purity > 0 && purity <= 100
    }

    private var percentageFilled: Double {
        guard maxPressure > 0 else { return 0 }
        return (currentPressure / maxPressure) * 100.0
    }

    private var fillLevelColor: Color {
        let percentage = percentageFilled
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
        tankVolume = tank.tankVolume
        maxPressure = tank.maxPressure
        currentPressure = tank.currentPressure
        purity = tank.purity
    }

    private func saveTank() {
        tank.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        tank.tankVolume = tankVolume
        tank.maxPressure = maxPressure
        tank.currentPressure = currentPressure
        tank.purity = purity

        dismiss()
    }
}

#Preview {
    AddStorageTankView()
}
