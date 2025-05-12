import SwiftUI

struct MealPlanView: View {
    @ObservedObject var viewModel: MealPlanViewModel
    private let calendarSyncService = CalendarSyncService()
    @State private var showSyncAlert = false
    @State private var syncMessage = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.mealPlans) { mealPlan in
                    Section(header: Text(dateFormatter.string(from: mealPlan.date))) {
                        ForEach(mealPlan.recipes) { recipe in
                            Text(recipe.name)
                        }
                    }
                }
                .onDelete(perform: deleteMealPlan)
            }
            .navigationTitle("Meal Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: syncWithCalendar) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                        }
                        Button(action: addSampleMealPlan) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .alert(isPresented: $showSyncAlert) {
                Alert(title: Text("Calendar Sync"), message: Text(syncMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func deleteMealPlan(at offsets: IndexSet) {
        viewModel.deleteMealPlan(at: offsets)
    }

    private func addSampleMealPlan() {
        // For MVP, add a sample meal plan for today
        let sampleRecipe = Recipe(name: "Sample Recipe", category: "Dinner", photoData: nil, description: "Sample description", ingredients: [], instructions: [])
        let mealPlan = MealPlan(date: Date(), recipes: [sampleRecipe])
        viewModel.addMealPlan(mealPlan)
    }

    private func syncWithCalendar() {
        calendarSyncService.syncMealPlansToCalendar(mealPlans: viewModel.mealPlans) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    syncMessage = "Meal plans successfully synced to your calendar."
                case .failure(let error):
                    syncMessage = "Failed to sync: \(error.localizedDescription)"
                }
                showSyncAlert = true
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
