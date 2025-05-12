import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class NutritionViewModel: ObservableObject {
    @Published var dailyNutrition: [DailyNutrition] = []
    @Published var nutritionInfo: NutritionalInfo?
    @Published var ingredientNutrition: [String: NutritionalInfo] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchNutritionData(for timeRange: NutritionDashboardView.TimeRange) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        db.collection("users").document(userId)
            .collection("nutrition")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: now))
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = error
                        return
                    }
                    
                    self.dailyNutrition = snapshot?.documents.compactMap { document -> DailyNutrition? in
                        guard let date = (document.get("date") as? Timestamp)?.dateValue(),
                              let calories = document.get("calories") as? Double,
                              let protein = document.get("protein") as? Double,
                              let carbs = document.get("carbs") as? Double,
                              let fat = document.get("fat") as? Double,
                              let fiber = document.get("fiber") as? Double else {
                            return nil
                        }
                        
                        return DailyNutrition(
                            date: date,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                            fiber: fiber
                        )
                    } ?? []
                }
            }
    }
    
    func calculateNutrition(for recipe: Recipe, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        
        // Reset previous calculations
        nutritionInfo = nil
        ingredientNutrition = [:]
        
        let group = DispatchGroup()
        var totalNutrition = NutritionalInfo(
            id: UUID().uuidString,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            fiber: 0
        )
        
        for ingredient in recipe.ingredients {
            group.enter()
            
            fetchNutritionInfo(for: ingredient) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let nutrition):
                    DispatchQueue.main.async {
                        self?.ingredientNutrition[ingredient.name] = nutrition
                        totalNutrition.calories += nutrition.calories
                        totalNutrition.protein += nutrition.protein
                        totalNutrition.carbs += nutrition.carbs
                        totalNutrition.fat += nutrition.fat
                        totalNutrition.fiber += nutrition.fiber
                    }
                case .failure(let error):
                    print("Error calculating nutrition for \(ingredient.name): \(error.localizedDescription)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.nutritionInfo = totalNutrition
            completion(.success(()))
        }
    }
    
    private func fetchNutritionInfo(for ingredient: Ingredient, completion: @escaping (Result<NutritionalInfo, Error>) -> Void) {
        // In a real app, this would call a nutrition API
        // For now, we'll use mock data
        let mockNutrition = NutritionalInfo(
            id: UUID().uuidString,
            calories: Double.random(in: 50...300),
            protein: Double.random(in: 0...20),
            carbs: Double.random(in: 0...30),
            fat: Double.random(in: 0...15),
            fiber: Double.random(in: 0...5)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(mockNutrition))
        }
    }
    
    func clearError() {
        error = nil
    }
}
