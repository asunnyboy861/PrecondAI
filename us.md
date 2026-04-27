# PrecondAI - iOS Development Guide

## Executive Summary

PrecondAI is a weather-aware EV cabin preconditioning scheduler for iOS. It solves the #1 complaint of EV owners: unreliable, inflexible, and "dumb" scheduled climate control in manufacturer apps. By combining real-time weather data with intelligent time calculation, PrecondAI automatically adjusts preconditioning start times based on outside temperature, weather conditions, battery level, and charging state.

**Target Audience**: US-based EV owners (4M+ vehicles) who want reliable, smart cabin preconditioning without manual daily adjustments.

**Key Differentiators**:
- Weather-aware smart scheduling (no competitor offers this)
- Multi-brand unified control via Smartcar API (37+ brands)
- Battery safety protection for unplugged preconditioning
- Calendar integration for automatic schedule generation
- Reliable background execution bypassing unreliable OEM schedulers

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Tesla App (Official) | Free, direct integration, basic preconditioning | Unreliable scheduling, no weather awareness, single brand, sync issues | Weather-aware, reliable background execution, multi-brand |
| Stats for Tesla ($5/mo) | Detailed analytics, climate scheduling, Siri Shortcuts, Apple Watch | Tesla-only, no weather-aware adjustment, analytics-focused not scheduling-focused | Weather intelligence, multi-brand, scheduling-first design |
| Elvee - Tesla Smart App | Remote controls, automation, Octopus Agile support | Tesla-only, UK-focused, no weather-based preconditioning | US market focus, weather-aware, multi-brand, battery protection |
| Remote for Tesla ($9.99) | One-time purchase, Siri integration, remote control | Tesla-only, no scheduling, no weather, outdated model | Subscription with continuous API support, smart scheduling, multi-brand |
| OVMS (Hardware) | Open-source, multi-brand, preconditioning scheduler | Requires $200+ hardware, complex setup, poor UX | Software-only, modern iOS UX, no hardware needed |

## Apple Design Guidelines Compliance

- **HIG 2026**: SwiftUI-first, minimal UI, large touch targets, dark mode primary
- **Privacy**: All tokens stored in Keychain (not UserDefaults), location access with purpose strings, minimal data collection
- **Background Execution**: BGTaskScheduler for scheduled preconditioning, UserNotifications for alerts
- **Energy Efficiency**: Batch API calls, cache weather data (30-min refresh), minimize background work
- **Accessibility**: VoiceOver labels on all controls, Dynamic Type support, high contrast colors
- **App Store Review**: No private API usage, official Tesla Fleet API + Smartcar SDK, clear subscription terms

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (ASWebAuthenticationSession only)
- **Data**: SwiftData for local persistence, Keychain for secure tokens
- **Networking**: async/await + URLSession, Codable JSON decoding
- **Vehicle API**: Tesla Fleet API (primary), Smartcar API (multi-brand Phase 2)
- **Weather API**: OpenWeatherMap (free tier: 1000 calls/day)
- **Calendar**: EventKit for Apple Calendar integration
- **Notifications**: UserNotifications + BGTaskScheduler
- **Location**: CoreLocation for vehicle position
- **Dependency Management**: Swift Package Manager
- **Architecture**: MVVM + Clean Architecture (Feature-based modules)

## Module Structure

```
PrecondAI/
├── PrecondAIApp.swift
├── Core/
│   ├── Network/
│   │   ├── TeslaAPIClient.swift
│   │   ├── SmartcarAPIClient.swift
│   │   ├── WeatherAPIClient.swift
│   │   └── APIError.swift
│   ├── Models/
│   │   ├── Vehicle.swift
│   │   ├── PreconditionSchedule.swift
│   │   ├── WeatherData.swift
│   │   └── ActivePrecondition.swift
│   ├── Algorithms/
│   │   └── SmartPreconditionCalculator.swift
│   └── Services/
│       ├── VehicleService.swift
│       ├── WeatherService.swift
│       ├── ScheduleService.swift
│       ├── NotificationService.swift
│       ├── BackgroundTaskManager.swift
│       └── PurchaseManager.swift
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── BrandSelectionView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── DashboardViewModel.swift
│   ├── Schedule/
│   │   ├── ScheduleListView.swift
│   │   ├── ScheduleListViewModel.swift
│   │   ├── AddScheduleView.swift
│   │   └── AddScheduleViewModel.swift
│   ├── VehicleSetup/
│   │   ├── VehicleAuthView.swift
│   │   └── VehicleAuthViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Paywall/
│       ├── PaywallView.swift
│       └── PaywallViewModel.swift
├── Shared/
│   ├── Components/
│   │   ├── TemperatureDial.swift
│   │   ├── VehicleCard.swift
│   │   ├── ScheduleCard.swift
│   │   ├── DayOfWeekPicker.swift
│   │   └── WeatherPreviewCard.swift
│   └── Extensions/
│       ├── Date+Extensions.swift
│       ├── Color+Extensions.swift
│       └── Double+Extensions.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings
```

## Implementation Flow

1. Create Xcode project with SwiftUI, iOS 17.0+, SwiftData
2. Implement data models (Vehicle, PreconditionSchedule, WeatherData) with SwiftData
3. Build TeslaAPIClient with OAuth2 PKCE authentication
4. Build WeatherAPIClient with OpenWeatherMap integration
5. Implement SmartPreconditionCalculator algorithm
6. Build ScheduleService for CRUD + background execution
7. Build BackgroundTaskManager with BGTaskScheduler
8. Build NotificationService with UserNotifications
9. Create Onboarding flow (brand selection + vehicle auth)
10. Create Dashboard view with vehicle status + quick actions
11. Create Schedule management views (list + add/edit)
12. Create Settings view with preferences
13. Implement PurchaseManager with StoreKit 2
14. Create Paywall view for subscription conversion
15. Add Contact Support page
16. Generate app icon and configure assets
17. Test on iPhone + iPad simulators
18. Push to GitHub and deploy policy pages

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: #007AFF (Apple Blue - trust/tech)
  - Warm: #FF9500 (Orange - heat indicator)
  - Cool: #5AC8FA (Light Blue - cool indicator)
  - Hot: #FF3B30 (Red - high temp/alert)
  - Success: #34C759 (Green - ready/complete)
  - Background: #000000 to #1C1C1E (dark mode gradient)
- **Typography**: SF Pro Display Bold 28pt (headers), SF Pro Text Regular 16pt (body), SF Pro Rounded Medium 20pt (data)
- **Layout**: Large cards with rounded corners (16pt radius), generous padding (16pt), max content width 720pt on iPad
- **Animations**: Spring transitions for state changes, pulse effect for active preconditioning, fluid temperature dial
- **Dark Mode**: Primary design target, all colors optimized for dark backgrounds
- **iPad**: Adaptive layout with .frame(maxWidth: 720), no sidebar restrictions

## Code Generation Rules

- Swift API Design Guidelines naming conventions
- English camelCase naming, avoid abbreviations
- No comments in code unless explicitly requested
- Minimum deployment: iOS 17.0
- Prefer async/await over completion handlers
- Pure SwiftUI, no UIKit except ASWebAuthenticationSession
- Codable for JSON decoding
- Custom Error enum for error handling
- Tokens/keys in Keychain only, never UserDefaults
- SwiftData for persistence
- StoreKit 2 for IAP
- MVVM pattern with @Observable ViewModels

## Build & Deployment Checklist

- [ ] Xcode project configured with bundle ID com.zzoutuo.PrecondAI
- [ ] Deployment target set to iOS 17.0
- [ ] App icon generated and added to Asset Catalog
- [ ] Capabilities configured (Push Notifications, Background Modes, Location)
- [ ] Build succeeds on iPhone simulator
- [ ] Build succeeds on iPad simulator
- [ ] App launches and onboarding works
- [ ] Dashboard displays vehicle status
- [ ] Schedule creation and management works
- [ ] Weather-aware time calculation verified
- [ ] Background task execution tested
- [ ] Push notifications work
- [ ] IAP subscription flow works
- [ ] Policy pages deployed to GitHub Pages
- [ ] App Store metadata prepared (keytext.md)
- [ ] Screenshots captured for App Store
