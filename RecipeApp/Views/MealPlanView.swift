import SwiftUI

struct MealPlanView: View {
    @ObservedObject var viewModel: MealPlanViewModel
    @State private var selectedDate = Date()
    @State private var showingRecipePicker = false
    @State private var selectedMealType: MealPlan.MealType = .dinner
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            .onChange(of: selectedDate) { newDate in
                viewModel.fetchMealPlans(for: newDate)
            }
            
            // Meal Type Selector
            Picker("Meal Type", selection: $selectedMealType) {
                ForEach(MealPlan.MealType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Meal Plans List
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                List {
                    if let plans = viewModel.mealPlans[Calendar.current.startOfDay(for: selectedDate)] {
                        ForEach(plans.filter { $0.mealType == selectedMealType }) { plan in
                            MealPlanRow(plan: plan)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteMealPlan(plan, at: selectedDate)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        
                        if plans.filter({ $0.mealType == selectedMealType }).isEmpty {
                            Text("No meals planned for \(selectedMealType.rawValue.lowercased())")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            // Add Meal Plan Button
            Button(action: { showingRecipePicker = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add \(selectedMealType.rawValue)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
        .navigationTitle("Meal Planner")
        .sheet(isPresented: $showingRecipePicker) {
            RecipePickerView(selectedDate: selectedDate, mealType: selectedMealType) { recipe in
                let mealPlan = MealPlan(
                    recipeId: recipe.id,
                    recipeName: recipe.name,
                    date: selectedDate,
                    mealType: selectedMealType
                )
                viewModel.addMealPlan(mealPlan)
                showingRecipePicker = false
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            viewModel.fetchMealPlans(for: selectedDate)
        }
    }
}

struct MealPlanRow: View {
    let plan: MealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(plan.recipeName)
                .font(.headline)
            
            if let notes = plan.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        MealPlanView(viewModel: MealPlanViewModel())
    }
}
