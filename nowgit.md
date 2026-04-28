# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | PrecondAI |
| **Git URL** | git@github.com:asunnyboy861/PrecondAI.git |
| **Repo URL** | https://github.com/asunnyboy861/PrecondAI |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/PrecondAI/ | ✅ Active |
| Support | https://asunnyboy861.github.io/PrecondAI/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/PrecondAI/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/PrecondAI/terms.html | ✅ Active |

**Note**: Terms of Use required for IAP subscription apps.

## Repository Structure

### Main App Repository
```
PrecondAI/
├── PrecondAI/                        # iOS App Source Code
│   ├── PrecondAI.xcodeproj/          # Xcode Project
│   ├── PrecondAI/                    # Swift Source Files
│   │   ├── Core/
│   │   │   ├── Algorithms/
│   │   │   ├── Auth/
│   │   │   ├── Models/
│   │   │   ├── Network/
│   │   │   └── Services/
│   │   ├── Features/
│   │   │   ├── Dashboard/
│   │   │   ├── Onboarding/
│   │   │   ├── Paywall/
│   │   │   ├── Schedule/
│   │   │   ├── Settings/
│   │   │   └── VehicleSetup/
│   │   ├── Shared/
│   │   │   ├── Components/
│   │   │   └── Extensions/
│   │   ├── Assets.xcassets/
│   │   ├── Config.xcconfig
│   │   ├── ContentView.swift
│   │   ├── Info.plist
│   │   ├── PrecondAI.entitlements
│   │   └── PrecondAIApp.swift
│   └── ...
├── docs/                             # Policy Pages for GitHub Pages
│   ├── index.html                    # Landing Page
│   ├── support.html                  # Support Page
│   ├── privacy.html                  # Privacy Policy
│   └── terms.html                    # Terms of Use
├── .github/workflows/                # GitHub Actions
│   └── deploy.yml                    # GitHub Pages deployment
├── us.md                             # English Development Guide
├── keytext.md                        # App Store Metadata
├── capabilities.md                   # Capabilities Configuration
├── icon.md                           # App Icon Details
├── price.md                          # Pricing Configuration
└── nowgit.md                         # This File
```

## Configuration

### App Information
| Item | Value |
|------|-------|
| **App Name** | PrecondAI |
| **Bundle ID** | com.zzoutuo.PrecondAI |
| **Minimum iOS** | 17.0 |
| **Contact Email** | iocompile67692@gmail.com |

### GitHub User
| Item | Value |
|------|-------|
| **Username** | asunnyboy861 |
| **Feedback Backend** | https://feedback-board.iocompile67692.workers.dev |

## Deployment Status

| Component | Status | Notes |
|-----------|--------|-------|
| iOS App Source | ✅ Pushed | On GitHub main branch |
| Policy Pages | ✅ Deployed | GitHub Pages from /docs |
| GitHub Pages | ✅ Enabled | Source: /docs folder |
| App Store Connect | ⏳ Not submitted | Pending screenshots |

## SettingsView Links

The following URLs are configured in the app's SettingsView:

```swift
// Support Page
let supportURL = "https://asunnyboy861.github.io/PrecondAI/support.html"

// Privacy Policy
let privacyURL = "https://asunnyboy861.github.io/PrecondAI/privacy.html"

// Terms of Use (Required for IAP)
let termsURL = "https://asunnyboy861.github.io/PrecondAI/terms.html"
```
