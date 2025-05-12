import Foundation
import Combine

class APIService {
    private let baseURL = "https://api.edamam.com/api/nutrition-data"
    private let appId = "YOUR_EDAMAM_APP_ID"
    private let appKey = "YOUR_EDAMAM_APP_KEY"
    
    func fetchNutritionInfo(ingredient: String, quantity: Double) -> AnyPublisher<NutritionalInfo, Error> {
        // Format ingredient for API query
        guard let encodedIngredient = "\(quantity) \(ingredient)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Fail(error: NutritionError.invalidIngredient).eraseToAnyPublisher()
        }
        
        // Construct URL with query parameters
        let urlString = "\(baseURL)?app_id=\(appId)&app_key=\(appKey)&ingr=\(encodedIngredient)"
        guard let url = URL(string: urlString) else {
            return Fail(error: NutritionError.invalidIngredient).eraseToAnyPublisher()
        }
        
        // Make API request
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NutritionError.networkError
                }
                return data
            }
            .decode(type: NutritionAPIResponse.self, decoder: JSONDecoder())
            .map { response in
                // Convert API response to NutritionalInfo
                NutritionalInfo(
                    calories: response.calories,
                    protein: response.protein,
                    carbs: response.carbs,
                    fat: response.fat,
                    fiber: response.fiber
                )
            }
            .mapError { error -> Error in
                if let error = error as? NutritionError {
                    return error
                }
                return NutritionError.apiError(error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Mock function for testing without API key
    func mockFetchNutritionInfo(ingredient: String, quantity: Double) -> AnyPublisher<NutritionalInfo, Error> {
        // Return mock data based on ingredient type
        let mockNutrition: NutritionalInfo
        
        switch ingredient.lowercased() {
        case _ where ingredient.contains("chicken"):
            mockNutrition = NutritionalInfo(
                calories: 165 * quantity,
                protein: 31 * quantity,
                carbs: 0 * quantity,
                fat: 3.6 * quantity,
                fiber: 0 * quantity
            )
        case _ where ingredient.contains("rice"):
            mockNutrition = NutritionalInfo(
                calories: 130 * quantity,
                protein: 2.7 * quantity,
                carbs: 28 * quantity,
                fat: 0.3 * quantity,
                fiber: 0.4 * quantity
            )
        case _ where ingredient.contains("broccoli"):
            mockNutrition = NutritionalInfo(
                calories: 55 * quantity,
                protein: 3.7 * quantity,
                carbs: 11.2 * quantity,
                fat: 0.6 * quantity,
                fiber: 5.1 * quantity
            )
        default:
            // Default values for unknown ingredients
            mockNutrition = NutritionalInfo(
                calories: 100 * quantity,
                protein: 5 * quantity,
                carbs: 15 * quantity,
                fat: 2 * quantity,
                fiber: 2 * quantity
            )
        }
        
        return Just(mockNutrition)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension APIService {
    // Helper method to parse ingredient strings
    func parseIngredientQuantity(_ quantityString: String) -> Double {
        // Remove any non-numeric characters except decimal points
        let numericString = quantityString.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()
        return Double(numericString) ?? 0
    }
    
    // Helper method to standardize measurements
    func standardizeMeasurement(_ quantity: Double, from unit: String) -> Double {
        switch unit.lowercased() {
        case "g", "gram", "grams":
            return quantity
        case "kg", "kilogram", "kilograms":
            return quantity * 1000
        case "oz", "ounce", "ounces":
            return quantity * 28.35
        case "lb", "pound", "pounds":
            return quantity * 453.592
        default:
            return quantity
        }
    }
}
