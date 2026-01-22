import SwiftUI
import SwiftData

struct AdvancedSettingsView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query private var settings: [AppSettings]

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
        List {
            Section(
                header: Text("Real Gas Corrections"),
                footer: Text(
                    "Gas temperature affects real gas corrections. " +
                    "Colder gas requires more volume from storage tanks. " +
                    "Default: 20°C (standard dive shop conditions)."
                )
            ) {
                HStack {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                        .frame(width: 28)

                    Text("Gas Temperature")
                        .font(.system(size: 17))

                    Spacer()

                    TextField(
                        "20",
                        value: Binding(
                            get: { appSettings.gasTemperature },
                            set: { newValue in
                                appSettings.gasTemperature = newValue
                                appSettings.lastModified = Date()
                                try? modelContext.save()
                            }
                        ),
                        format: .number.precision(.fractionLength(0))
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .onSubmit {
                        let selector = #selector(UIResponder.resignFirstResponder)
                        UIApplication.shared.sendAction(selector, to: nil, from: nil, for: nil)
                    }

                    Text("°C")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}
