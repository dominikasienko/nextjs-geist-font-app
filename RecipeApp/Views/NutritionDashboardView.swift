import SwiftUI

struct NutritionDashboardView: View {
    @ObservedObject var viewModel: NutritionViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Daily Calorie Limit: \(Int(viewModel.dailyCalorieLimit)) kcal")
                .font(.headline)
            Text("Consumed Calories: \(Int(viewModel.consumedCalories)) kcal")
                .font(.subheadline)
                .foregroundColor(viewModel.isWithinCalorieLimit() ? .green : .red)
            ProgressView(value: viewModel.consumedCalories, total: viewModel.dailyCalorieLimit)
                .progressViewStyle(LinearProgressViewStyle(tint: viewModel.isWithinCalorieLimit() ? .green : .red))
                .padding()
            if !viewModel.isWithinCalorieLimit() {
                Text("You have exceeded your daily calorie limit!")
                    .foregroundColor(.red)
                    .bold()
            }
        }
        .padding()
        .navigationTitle("Nutrition Dashboard")
    }
}
