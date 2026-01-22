import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    @Environment(\.modelContext)
    private var modelContext

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

    private var backgroundView: some View {
        Color(UIColor.systemGroupedBackground)
            .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            backgroundView

            List {
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
                    }
                }
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Appearance", isPresented: $showingAppearancePicker) {
            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                Button(mode.displayName) {
                    appSettings.appearanceMode = mode
                }
            }
        }
    }
}
