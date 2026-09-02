# PocketLedger

**Developer:** Ayesha Zafar
**Project:** Week 3 Mobile App Prototype
**Tech Stack:** Flutter, Dart, SharedPreferencesAsync

## Business Problem
Small teams and individuals need a lightweight mobile app for specific productivity tasks, such as tracking expenses. Setting up heavy SaaS products is often overkill. This app provides a localized, privacy-first, zero-onboarding utility that can be used independently or serve as an internal utility for SafeX.

## Solution
A cross-platform mobile app prototype (expense tracker) built with Flutter. It consists of 4 core screens emphasizing minimalist UX, fast interactions, and offline persistence.

## Tools & Technologies
- **Framework**: Flutter
- **Persistence**: `shared_preferences` (specifically `SharedPreferencesAsync` for thread-safe modern fetching)
- **State Management**: Ephemeral state (Stateful Widgets) for lightweight footprint

## Key Features
- **Dashboard**: High-level expense summary card with total spending and a scrollable list of recent transactions.
- **Add Expense**: Strict form validation requiring positive numbers and titles. Rejects illegal values gracefully.
- **Expense Details**: Comprehensive breakdown of a specific expense with delete functionality.
- **Settings**: Developer-friendly 'Clear All Data' reset feature.
- **Offline First**: All data is securely persisted on the local device, surviving application restarts.

## Challenges Faced & Solutions
1. **State Refresh Across Navigation**: When pushing and popping screens (like returning from Add Expense to Dashboard), the underlying list wouldn't update. 
   *Solution*: Implemented an asynchronous refresh `_loadExpenses()` returning on `Navigator.pushNamed(...)` resolutions to trigger a visual state refresh.
2. **Type Safety with Local Storage**: `SharedPreferences` saves elements natively, but custom `Expense` models needed translation. 
   *Solution*: Added standard `toJson` and `fromJson` serialization bindings to precisely restore the data model.
3. **Keyboard Overflows**: Entering text shifted UI elements which overflowed rendering constraints on small emulator footprints.
   *Solution*: Wrapped form contents in a `SingleChildScrollView` allowing safe dynamic scrolling beneath keyboard planes.

## Future Improvements
- Implement categorized pie charts for visual expense breakdown.
- Introduce Dark Mode theme toggling.
- Implement data export functionality (CSV/PDF) for accounting teams.
