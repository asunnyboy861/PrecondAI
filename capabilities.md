# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "通知" / "提醒" / "alert" → Push Notifications
- "后台" / "background" / "刷新" → Background Modes (Background Processing, Background Fetch)
- "定位" / "位置" / "地图" → Location Services (When In Use)
- "订阅" / "月付" / "年付" / "会员" → In-App Purchase
- "日历" / "Calendar" → Calendar (EventKit)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | ✅ Configured | Xcode project |
| Background Modes (Processing, Fetch) | ✅ Configured | Xcode project |
| Location (When In Use) | ✅ Configured | Info.plist |
| In-App Purchase | ✅ Configured | StoreKit 2 |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Tesla Fleet API OAuth | ⏳ Pending | Register at developer.tesla.com, obtain client_id/secret |
| Smartcar API | ⏳ Pending | Register at smartcar.com, obtain client_id/secret |
| OpenWeatherMap API | ⏳ Pending | Register at openweathermap.org, obtain API key |

## No Configuration Needed
- HealthKit (not applicable)
- Camera/Photo Library (not applicable)
- Siri (Phase 2)
- Apple Watch (Phase 2)
- CarPlay (Phase 2)
- iCloud/CloudKit (local storage only for MVP)

## Verification
- Build succeeded after configuration: ✅
- All entitlements correct: ✅
