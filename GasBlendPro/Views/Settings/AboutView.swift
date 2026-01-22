import SwiftUI
import SwiftData

struct AboutView: View {
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

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }

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

    var body: some View {
        List {
            Section(header: Text("App Information")) {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .frame(width: 28)

                    Text("Version")
                        .font(.system(size: 17))

                    Spacer()

                    Text(appVersion)
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                        .frame(width: 28)

                    Text("Developer")
                        .font(.system(size: 17))

                    Spacer()

                    Text("Johannes Six")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }

                // General Contact
                if let contactURL = URL(string: "https://tally.so/r/LZKrL1") {
                    Link(destination: contactURL) {
                        HStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 28)

                            Text("Contact & Feedback")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Button {
                    appSettings.hasAcceptedDisclaimer = false
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                            .frame(width: 28)

                        Text("View Disclaimer")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section(footer: disclaimerFooter) {
                EmptyView()
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
