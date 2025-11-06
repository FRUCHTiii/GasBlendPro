import SwiftUI
import SwiftData

struct ContentView: View {
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

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
}
