import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query private var settings: [AppSettings]
    @State private var showDisclaimer = false

    private var appSettings: AppSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    private var colorScheme: ColorScheme? {
        switch appSettings.appearanceMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    private var disclaimerMessage: String {
        """
        Gas Blend Pro performs safety-critical calculations for diving gas blending. \
        Incorrect gas mixes can result in serious injury or death.

        By using this app, you acknowledge that:

        • You are solely responsible for verifying all calculations
        • You will follow proper diving safety procedures
        • The developer assumes no liability for errors or miscalculations
        • You use this app at your own risk

        If you do not accept these terms, please decline and do not use this app.
        """
    }

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .preferredColorScheme(colorScheme)
        .alert("Safety Disclaimer", isPresented: $showDisclaimer) {
            Button("Decline", role: .cancel) {
                // User declined - exit the app
                exit(0)
            }
            Button("Accept") {
                appSettings.hasAcceptedDisclaimer = true
                showDisclaimer = false
            }
        } message: {
            Text(disclaimerMessage)
        }
        .onAppear {
            // Show disclaimer on first launch or if user wants to view it again
            if !appSettings.hasAcceptedDisclaimer {
                showDisclaimer = true
            }
        }
        .onChange(of: appSettings.hasAcceptedDisclaimer) { _, newValue in
            // If disclaimer acceptance is reset (from Settings), show it again
            if !newValue {
                showDisclaimer = true
            }
        }
    }
}

#Preview {
    ContentView()
}
