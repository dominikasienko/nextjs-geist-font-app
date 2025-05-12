import SwiftUI

struct DatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDates: Set<Date>
    @State private var tempSelectedDates: Set<Date>
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    init(selectedDates: Binding<Set<Date>>) {
        self._selectedDates = selectedDates
        self._tempSelectedDates = State(initialValue: selectedDates.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Month Navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: currentMonth))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // Days of Week
                HStack {
                    ForEach(daysInWeek, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            DayCell(
                                date: date,
                                isSelected: tempSelectedDates.contains(date),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                toggleDate(date)
                            }
                        } else {
                            Color.clear
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedDates = tempSelectedDates
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: interval.start))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = firstWeekday - 1
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        let remainingDays = 42 - days.count
        days.append(contentsOf: Array(repeating: nil, count: remainingDays))
        
        return days
    }
    
    private func toggleDate(_ date: Date) {
        if tempSelectedDates.contains(date) {
            tempSelectedDates.remove(date)
        } else {
            tempSelectedDates.insert(date)
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
    }
}

#Preview {
    DatePickerView(selectedDates: .constant([]))
}
