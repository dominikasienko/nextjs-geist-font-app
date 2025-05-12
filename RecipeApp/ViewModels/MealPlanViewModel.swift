import Foundation
import FirebaseFirestore
import FirebaseAuth

class MealPlanViewModel: ObservableObject {
    @Published var mealPlans: [Date: [MealPlan]] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    private let calendarSync = CalendarSyncService.shared
    
    func fetchMealPlans(for date: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("users").document(userId)
            .collection("mealPlans")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = error
                        return
                    }
                    
                    let plans = querySnapshot?.documents.compactMap { document -> MealPlan? in
                        try? document.data(as: MealPlan.self)
                    } ?? []
                    
                    self.mealPlans[date] = MealPlan.sortByMealType(plans)
                }
            }
    }
    
    func addMealPlan(_ plan: MealPlan) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let docRef = db.collection("users").document(userId)
                .collection("mealPlans")
                .document()
            
            var newPlan = plan
            newPlan.id = docRef.documentID
            
            try docRef.setData(from: newPlan) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.error = error
                    }
                    return
                }
                
                // Sync with calendar
                self?.calendarSync.syncMealPlan(newPlan) { result in
                    switch result {
                    case .success(let eventId):
                        // Store event ID for future reference
                        self?.updateMealPlanWithEventId(newPlan, eventId: eventId)
                    case .failure(let error):
                        print("Calendar sync error: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    private func updateMealPlanWithEventId(_ plan: MealPlan, eventId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
              let planId = plan.id else { return }
        
        db.collection("users").document(userId)
            .collection("mealPlans")
            .document(planId)
            .updateData(["calendarEventId": eventId])
    }
    
    func deleteMealPlan(_ plan: MealPlan, at date: Date) {
        guard let userId = Auth.auth().currentUser?.uid,
              let planId = plan.id else { return }
        
        db.collection("users").document(userId)
            .collection("mealPlans")
            .document(planId)
            .delete { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.error = error
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.mealPlans[date]?.removeAll { $0.id == plan.id }
                }
            }
    }
    
    func clearMealPlans() {
        mealPlans = [:]
        error = nil
    }
}
