import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                headerView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        NavigationLink(destination: BlendingCalculatorView()) {
                            MenuCard(
                                title: "Gas Blender",
                                subtitle: "Calculate your gas mix",
                                icon: "cylinder.fill",
                                color: .blue
                            )
                        }

                        NavigationLink(destination: StorageTanksView()) {
                            MenuCard(
                                title: "Storage Tanks",
                                subtitle: "Manage O₂ and He inventory",
                                icon: "square.stack.3d.up.fill",
                                color: .orange
                            )
                        }

                        NavigationLink(destination: SettingsView()) {
                            MenuCard(
                                title: "Settings",
                                subtitle: "Manage presets and preferences",
                                icon: "gearshape.fill",
                                color: .gray
                            )
                        }

                        Spacer().frame(height: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                Spacer()
            }
        }
    }

    private var backgroundView: some View {
        Group {
            if #available(iOS 16.0, *) {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.98, green: 0.98, blue: 1.0)
                    .ignoresSafeArea()
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gas Blend Pro")
                .font(.system(size: 32, weight: .bold, design: .default))
                .tracking(-0.5)

            Text("by Werk4")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .cardBackground()
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
