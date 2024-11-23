# Check Apple calendar events from terminal on MacOS using Swift

## Create a new Xcode project

Xcode -> Create New Project...
macOs -> **Command Line Tool**

Product Name: CalendarCLI

Select project in the navigator -> Targets: CalendarCLI -> Sining & Capabilities -> Signing

Bundle Identifier: [com.yoursite.CalendarCLI]

## Make Info.plist

File -> New -> File from Template... [⌘ N]
Search: "Property List"
Save As: Info.plist

Select `Info` from navigator -> Open As > Source Code

Paste below to the `Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSCalendarsFullAccessUsageDescription</key>
	<string>This app needs calendar access to display your events</string>

    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.personal-information.calendars</key>
    <true/>
</dict>
</plist>
```

## Code (main.swift)

Paste below to `main.swift`

```swift
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
                currentDate = eventDate
                let currentDateStyled =
                "\u{001B}[1;33m\(currentDate)\u{001B}[0m"
                print(currentDateStyled)
            }

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
```

## Build

Product -> Build [⌘ B]

The executable goes to something like:

> ~/Library/Developer/Xcode/DerivedData/**CalendarCLI-epaeyjhibywlyqbuuhetpwnjddow**/Build/Products/Debug/CalendarCLI

## Run

Run the app
$(find ~/Library/Developer/Xcode/DerivedData -name "CalendarCLI" -type f -path "_/Build/Products/Debug/_" -print -quit)

## Run with alias

Make an alias in `~/.zshrc` (for Z shell)

```shell
alias acal='$(find ~/Library/Developer/Xcode/DerivedData -name "CalendarCLI" -type f -path "_/Build/Products/Debug/_" -print -quit)'
```

## Output

```shell
❯ acal
2024-11-24 (Sun)
· return books

2024-11-25 (Mon)
· 💰rent
```
