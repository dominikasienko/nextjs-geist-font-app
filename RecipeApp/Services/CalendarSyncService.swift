import Foundation
import EventKit

class CalendarSyncService {
    private let eventStore = EKEventStore()

    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event, completion: completion)
    }

    func syncMealPlansToCalendar(mealPlans: [MealPlan], completion: @escaping (Result<Void, Error>) -> Void) {
        requestAccess { [weak self] granted, error in
            guard granted, error == nil else {
                completion(.failure(error ?? NSError(domain: "CalendarAccess", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access to calendar denied"])))
                return
            }
            guard let self = self else { return }
            do {
                for mealPlan in mealPlans {
                    try self.addMealPlanEvent(mealPlan)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func addMealPlanEvent(_ mealPlan: MealPlan) throws {
        let calendar = eventStore.defaultCalendarForNewEvents
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = "Meal Plan"
        event.startDate = mealPlan.date
        event.endDate = mealPlan.date.addingTimeInterval(60 * 60) // 1 hour duration
        event.notes = mealPlan.recipes.map { $0.name }.joined(separator: ", ")
        try eventStore.save(event, span: .thisEvent)
    }
}
