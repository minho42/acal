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

Copy and paste from `CalendarCLI/Info.plist` to `Info.plist`

## Code (main.swift)

Copy and paste from `CalendarCLI/main.swift` to `main.swift`

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
