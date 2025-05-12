import Foundation
import EventKit

class CalendarSyncService {
    private let eventStore = EKEventStore()
    static let shared = CalendarSyncService()
    
    private init() {}
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func syncMealPlan(_ mealPlan: MealPlan, completion: @escaping (Result<String, Error>) -> Void) {
        let event = EKEvent(eventStore: eventStore)
        event.title = "\(mealPlan.mealType.rawValue): \(mealPlan.recipeName)"
        event.notes = "Meal planned from Recipe App"
        
        // Set event time based on meal type
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: mealPlan.date)
        
        switch mealPlan.mealType {
        case .breakfast:
            dateComponents.hour = 8
        case .lunch:
            dateComponents.hour = 12
        case .dinner:
            dateComponents.hour = 18
        case .snack:
            dateComponents.hour = 15
        }
        
        guard let startDate = calendar.date(from: dateComponents) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date"])))
            return
        }
        
        event.startDate = startDate
        event.endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(.success(event.eventIdentifier))
        } catch {
            completion(.failure(error))
        }
    }
    
    func removeMealPlan(eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let event = eventStore.event(withIdentifier: eventId) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Event not found"])))
            return
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
