import SwiftUI
import Charts

struct NutritionDashboardView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedNutrient: NutrientType = .calories
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    enum NutrientType: String, CaseIterable {
        case calories = "Calories"
        case protein = "Protein"
        case carbs = "Carbs"
        case fat = "Fat"
        case fiber = "Fiber"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Nutrient Type Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NutrientType.allCases, id: \.self) { type in
                                NutrientButton(
                                    title: type.rawValue,
                                    isSelected: selectedNutrient == type,
                                    value: averageValue(for: type)
                                ) {
                                    selectedNutrient = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Chart
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        NutritionChart(
                            data: chartData,
                            nutrientType: selectedNutrient
                        )
                        .frame(height: 250)
                        .padding()
                    }
                    
                    // Daily Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.dailyNutrition.prefix(7)) { daily in
                            DailyNutritionRow(daily: daily)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Nutrition")
            .onAppear {
                viewModel.fetchNutritionData(for: selectedTimeRange)
            }
            .onChange(of: selectedTimeRange) { newValue in
                viewModel.fetchNutritionData(for: newValue)
            }
        }
    }
    
    private func averageValue(for type: NutrientType) -> Double {
        let values = viewModel.dailyNutrition.map { daily -> Double in
            switch type {
            case .calories: return daily.calories
            case .protein: return daily.protein
            case .carbs: return daily.carbs
            case .fat: return daily.fat
            case .fiber: return daily.fiber
            }
        }
        return values.reduce(0, +) / Double(max(values.count, 1))
    }
    
    private var chartData: [(Date, Double)] {
        viewModel.dailyNutrition.map { daily in
            (daily.date, valueForSelectedNutrient(daily))
        }
    }
    
    private func valueForSelectedNutrient(_ daily: DailyNutrition) -> Double {
        switch selectedNutrient {
        case .calories: return daily.calories
        case .protein: return daily.protein
        case .carbs: return daily.carbs
        case .fat: return daily.fat
        case .fiber: return daily.fiber
        }
    }
}

struct NutrientButton: View {
    let title: String
    let isSelected: Bool
    let value: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .fontWeight(isSelected ? .bold : .regular)
                Text(String(format: "%.1f", value))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct NutritionChart: View {
    let data: [(Date, Double)]
    let nutrientType: NutritionDashboardView.NutrientType
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { item in
                LineMark(
                    x: .value("Date", item.0),
                    y: .value(nutrientType.rawValue, item.1)
                )
            }
        }
    }
}

struct DailyNutritionRow: View {
    let daily: DailyNutrition
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(formatDate(daily.date))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(daily.calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                NutrientLabel(name: "Protein", value: daily.protein, unit: "g")
                NutrientLabel(name: "Carbs", value: daily.carbs, unit: "g")
                NutrientLabel(name: "Fat", value: daily.fat, unit: "g")
                NutrientLabel(name: "Fiber", value: daily.fiber, unit: "g")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct NutrientLabel: View {
    let name: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(Int(value))\(unit)")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct DailyNutrition: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
}

#Preview {
    NutritionDashboardView(viewModel: NutritionViewModel())
}
