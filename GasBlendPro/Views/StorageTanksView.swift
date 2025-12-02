import SwiftUI
import SwiftData

struct StorageTanksView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \StorageTank.createdAt, order: .reverse)
    private var tanks: [StorageTank]
    @State private var showingAddTank = false
    @State private var selectedTank: StorageTank?

    var body: some View {
        ZStack {
            backgroundView

            if tanks.isEmpty {
                emptyStateView
            } else {
                tankListView
            }
        }
        .navigationTitle("Storage Tanks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTank = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTank) {
            AddStorageTankView()
        }
        .sheet(item: $selectedTank) { tank in
            EditStorageTankView(tank: tank)
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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Storage Tanks")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your first O₂ or He storage tank to start tracking your inventory")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showingAddTank = true
            } label: {
                Label("Add Tank", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
    }

    private var tankListView: some View {
        List {
            ForEach(tanks) { tank in
                TankRow(tank: tank)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTank = tank
                    }
            }
            .onDelete(perform: deleteTanks)
        }
        .listStyle(.insetGrouped)
    }

    private func deleteTanks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tanks[index])
        }
    }
}

struct TankRow: View {
    let tank: StorageTank

    var body: some View {
        HStack(spacing: 12) {
            // Gas type icon with fill indicator
            ZStack {
                // Background circle
                Circle()
                    .fill(gasTypeColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                // Progress ring showing fill percentage
                Circle()
                    .trim(from: 0, to: tank.percentageFilled / 100.0)
                    .stroke(
                        fillLevelColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                // Gas type icon
                Image(systemName: gasTypeIcon)
                    .font(.system(size: 18))
                    .foregroundColor(gasTypeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tank.name)
                    .font(.system(size: 17, weight: .medium))

                HStack(spacing: 6) {
                    Text(tank.gasTypeLabel)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text("\(Int(tank.tankVolume))L")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    if tank.purity < 100 {
                        Text("•")
                            .foregroundColor(.secondary)

                        Text(String(format: "%.1f%% purity", tank.purity))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f%%", tank.percentageFilled))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(fillLevelColor)

                Text(String(format: "%.0f / %.0f bar", tank.currentPressure, tank.maxPressure))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var gasTypeColor: Color {
        switch tank.gasType {
        case .oxygen:
            return .green
        case .helium:
            return .purple
        case .air:
            return .blue
        }
    }

    private var gasTypeIcon: String {
        switch tank.gasType {
        case .oxygen:
            return "o.circle.fill"
        case .helium:
            return "h.circle.fill"
        case .air:
            return "wind"
        }
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
}

#Preview {
    NavigationStack {
        StorageTanksView()
    }
}
