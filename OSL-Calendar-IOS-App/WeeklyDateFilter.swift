//
//  WeeklyDateFilter.swift
//  OSL-Calendar-IOS-App
//
//  Created by Michael Wardach on 7/5/19.
//
//

import Foundation

class WeeklyDateFilter {
    var startDate: Date
    var endDate: Date
    var DATE_FORMAT = DateFormatter()
    
    init(currentDate: Date) {
        startDate = currentDate
        endDate = currentDate
        startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
        calculateWeekEndDate()
        DATE_FORMAT.dateFormat = "MMM dd"
    }
    
    func applyFilter(event: Event) -> Bool {
        return (event.getStartDate() > startDate && event.getStartDate() < endDate)
    }
    
    func calculateWeekEndDate() {
        var dateIncrease = 8 - Calendar.current.component(.weekday, from: startDate)
        if (Calendar.current.component(.weekday, from: startDate) == 0) {
            dateIncrease = 0
        }
        endDate = Calendar.current.date(byAdding: .day, value: dateIncrease, to: endDate)!
        endDate = Calendar.current.date(bySettingHour: 11, minute: 59, second: 59, of: endDate)!
    }
    
    func getCurrentWeekLabel() -> String {
        var beginDateLabel = DATE_FORMAT.string(from: startDate)
        let endDateLabel = DATE_FORMAT.string(from: endDate)
        if (isFilteringCurrentWeek()) {
            beginDateLabel = "Now"
        }
        return beginDateLabel + " - " + endDateLabel
    }
    
    func moveToNextWeek() {
        startDate = endDate
        startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
        startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        endDate = Calendar.current.date(byAdding: .day, value: 7, to: endDate)!
        print("START DATE: " + startDate.description(with: .current))
        print("END DATE: " + endDate.description(with: .current))
    }
    
    func moveToPreviousWeek() {
        var todayDate = Date()
        todayDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: todayDate)!
        startDate = Calendar.current.date(byAdding: .day, value: -7, to: startDate)!
        if (startDate <= todayDate) {
            startDate = todayDate
        }
        endDate = startDate
        calculateWeekEndDate()
        print("START DATE: " + startDate.description(with: .current))
        print("END DATE: " + endDate.description(with: .current))
    }
    
    func isFilteringCurrentWeek() -> Bool {
        let todayDate = Date()
        return (startDate < todayDate)
    }
}
