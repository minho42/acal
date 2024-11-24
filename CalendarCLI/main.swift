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
    
    func displayEvents(_ events: [EKEvent]) {
        if events.isEmpty {
            print("empty")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd (EEE)"
        
        var currentDate = ""
        for event in events.sorted(by: { $0.startDate < $1.startDate }) {
            let eventDate = dateFormatter.string(from: event.startDate)
            
            if currentDate != eventDate {
                if !currentDate.isEmpty {
                    print("")
                }
                // 1: bold, 33: yellow
                currentDate = eventDate
                let currentDateStyled =
                "\u{001B}[1;33m\(currentDate)\u{001B}[0m"
                print(currentDateStyled)
            }
            // 32: green
            let titleStyled =
            "\u{001B}[32m\(event.title ?? "")\u{001B}[0m"
            print("· \(titleStyled)")
        }
        
        if !events.isEmpty {
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
    reader.displayEvents(events)
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
