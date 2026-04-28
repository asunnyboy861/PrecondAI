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
| Landing Page | https://asunnyboy861.github.io/PrecondAI/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/PrecondAI/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/PrecondAI/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/PrecondAI/terms.html | ⏳ Pending |

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
| iOS App Source | ⏳ Not pushed | Ready for GitHub |
| Policy Pages | ⏳ Not deployed | Will deploy to /docs |
| GitHub Pages | ⏳ Not enabled | Will enable via API |
| App Store Connect | ⏳ Not submitted | Pending screenshots |
