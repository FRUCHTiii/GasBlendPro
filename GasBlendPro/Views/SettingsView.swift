import SwiftUI
import SwiftData

struct SettingsView: View {
    private var disclaimerFooter: some View {
        Text(
            "Gas Blend Pro is provided for informational purposes only. " +
            "The calculations are intended to assist with gas blending, " +
            "but you are solely responsible for verifying all calculations " +
            "and ensuring the safety of your gas mixes. " +
            "Always follow proper diving safety procedures."
        )
        .font(.system(size: 13))
        .foregroundColor(.secondary)
    }

    private var backgroundView: some View {
        Color(UIColor.systemGroupedBackground)
            .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            backgroundView

            List {
                NavigationLink(destination: GeneralSettingsView()) {
                    SettingsCategoryRow(
                        icon: "gearshape",
                        title: "General",
                        color: .blue
                    )
                }

                NavigationLink(destination: BlenderSettingsView()) {
                    SettingsCategoryRow(
                        icon: "cylinder.fill",
                        title: "Blender",
                        color: .green
                    )
                }

                NavigationLink(destination: AdvancedSettingsView()) {
                    SettingsCategoryRow(
                        icon: "slider.horizontal.3",
                        title: "Advanced",
                        color: .orange
                    )
                }

                NavigationLink(destination: AboutView()) {
                    SettingsCategoryRow(
                        icon: "info.circle",
                        title: "About",
                        color: .purple
                    )
                }

                Section(footer: disclaimerFooter) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Settings Category Row
struct SettingsCategoryRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)

            Text(title)
                .font(.system(size: 18, weight: .medium))

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
