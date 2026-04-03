import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \ExpenseCategory.sortOrder) private var categories:
        [ExpenseCategory]

    @AppStorage(
        SettingsStorage.isSpendingLimitEnabledKey,
        store: SharedSettings.userDefaults
    )
    private var isSpendingLimitEnabled = false

    @AppStorage(
        SettingsStorage.spendingLimitAmountKey,
        store: SharedSettings.userDefaults
    )
    private var spendingLimitAmount = 0.0

    @AppStorage(
        SettingsStorage.spendingLimitPeriodKey,
        store: SharedSettings.userDefaults
    )
    private var spendingLimitPeriodRawValue = SpendingLimitPeriod.monthly.rawValue

    @State private var limitAmountText = ""
    @State private var isShowingDeleteAllConfirmation = false
    @State private var isShowingFinalDeleteAllConfirmation = false
    @State private var exportDocument: Data?
    @State private var isShowingShareSheet = false

    private var spendingLimitPeriodBinding: Binding<SpendingLimitPeriod> {
        Binding(
            get: {
                SpendingLimitPeriod(rawValue: spendingLimitPeriodRawValue)
                    ?? .monthly
            },
            set: { newValue in
                spendingLimitPeriodRawValue = newValue.rawValue
            }
        )
    }

    var body: some View {
        AppScreen(title: "Settings") {
            spendingLimitSection
            supportSection
            dataSection
        }
        .onAppear {
            if spendingLimitAmount > 0 {
                limitAmountText = ExpenseFormSupport.formattedAmountString(
                    for: spendingLimitAmount
                )
            }
        }
        .onChange(of: isSpendingLimitEnabled) { _, _ in
                AppWidgetReloader.reloadAll()
            }
            .onChange(of: spendingLimitAmount) { _, _ in
                AppWidgetReloader.reloadAll()
            }
            .onChange(of: spendingLimitPeriodRawValue) { _, _ in
                AppWidgetReloader.reloadAll()
            }
        .alert("Clear all data?", isPresented: $isShowingDeleteAllConfirmation) {
            Button("Continue", role: .destructive) {
                isShowingFinalDeleteAllConfirmation = true
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all expenses and custom category changes.")
        }
        .alert(
            "Are you absolutely sure?",
            isPresented: $isShowingFinalDeleteAllConfirmation
        ) {
            Button("Delete Everything", role: .destructive) {
                clearAllData()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let exportDocument {
                ShareSheet(items: [exportDocument])
            }
        }
    }

    private var spendingLimitSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Spending Limit")

            SettingsSectionCard {
                Toggle(isOn: $isSpendingLimitEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable spending limit")
                            .font(.appCardTitle)

                        Text("Set a daily, weekly, or monthly limit.")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
                .padding(AppSpacing.md)

                if isSpendingLimitEnabled {
                    Divider()
                        .padding(.horizontal, AppSpacing.md)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Limit Period")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.secondaryText)

                        Picker("Limit Period", selection: spendingLimitPeriodBinding) {
                            ForEach(SpendingLimitPeriod.allCases) { period in
                                Text(period.title).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text("Limit Amount")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.secondaryText)

                        TextField("0.00", text: $limitAmountText)
                            .keyboardType(.decimalPad)
                            .appInputFieldStyle()
                            .onChange(of: limitAmountText) { _, newValue in
                                let parsed = ExpenseFormSupport.parseAmount(
                                    from: newValue
                                ) ?? 0
                                spendingLimitAmount = parsed
                            }
                    }
                    .padding(AppSpacing.md)
                }
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Support")

            SettingsSectionCard {
                SettingsRowButton(
                    title: "Report a bug or request a feature",
                    subtitle: "Open our feedback page"
                ) {
                    openFeedbackPage()
                }
            }
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title: "Data")

            SettingsSectionCard {
                SettingsRowButton(
                    title: "Export data",
                    subtitle: "Download your expenses and categories"
                ) {
                    exportData()
                }

                Divider()
                    .padding(.horizontal, AppSpacing.md)

                SettingsRowButton(
                    title: "Clear all data",
                    subtitle: "Delete all expenses and categories",
                    role: .destructive
                ) {
                    isShowingDeleteAllConfirmation = true
                }
            }
        }
    }

    private var exportFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "ExpenseTracker-Export-\(formatter.string(from: Date())).json"
    }

    private func openFeedbackPage() {
        guard let url = URL(string: "https://insigh.to/b/spento") else {
            return
        }

        openURL(url)
    }

    private func exportData() {
        do {
            exportDocument = try DataExportService.makeExportData(
                expenses: expenses,
                categories: categories
            )
            isShowingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func clearAllData() {
        for expense in expenses {
            modelContext.delete(expense)
        }

        for category in categories where !category.isFallback {
            modelContext.delete(category)
        }

        try? modelContext.save()
        AppWidgetReloader.reloadAll()
    }
}
