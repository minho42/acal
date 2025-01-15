//
//  main.swift
//  CalendarCLI
//
//  Created by Min ho Kim on 24/11/2024.
//

import Foundation
import EventKit

class CalendarReader {
    private let eventStore = EKEventStore()
    
    func requestAccess() async -> Bool {
        return await withCheckedContinuation { continuation in
            eventStore.requestFullAccessToEvents { granted, error in
                if let error = error {
                    print("Error requesting access: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                }
                continuation.resume(returning: granted)
            }
        }
    }
    
    func fetchEvents(days daysToFetch: Int) async -> [EKEvent] {
        let calendars = eventStore.calendars(for: .event)
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: daysToFetch - 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        
        return eventStore.events(matching: predicate)
    }

    func displayEvents(_ groupedEvents: [String: [EKEvent]]) {
        for (day, events) in groupedEvents.sorted(by: { $0.key < $1.key }) {
            print("\u{001B}[1;33m\(day):\u{001B}[0m")
            for event in events {
                print("· \u{001B}[32m\(event.title ?? "")\u{001B}[0m")
            }
            print("")
        }
    }
}


let reader = CalendarReader()
let daysToFetch = 2

Task {
    let granted = await reader.requestAccess()
    
    guard granted else {
        print("calendar access denied")
        exit(1)
    }
    
    let events = await reader.fetchEvents(days: daysToFetch)
    let groupedEvents = groupEventsByDay(events, days: daysToFetch)
    reader.displayEvents(groupedEvents)
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))

func groupEventsByDay(_ events: [EKEvent], days daysToFetch: Int) -> [String: [EKEvent]] {
    let cal = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd (EEE)"
    let today = cal.startOfDay(for: Date())

    var result: [String: [EKEvent]] = [:]
    
    for event in events {
        let eventStart = event.startDate!
        let eventEnd = event.endDate!
        
        for dayOffset in 0..<daysToFetch {
            let currentDay = cal.date(byAdding: .day, value: dayOffset, to: today)!
            let startOfDay = cal.startOfDay(for: currentDay)
            let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay)!
            
            
            if cal.isDate(eventStart, inSameDayAs: currentDay) ||
                cal.isDate(eventEnd, inSameDayAs: currentDay) ||
                (eventStart < startOfDay && eventEnd > endOfDay) {
                let dayKey = dateFormatter.string(from: currentDay)
                if result[dayKey] == nil {
                    result[dayKey] = []
                }
                result[dayKey]?.append(event)
            }
        }
    }
    return result
}
