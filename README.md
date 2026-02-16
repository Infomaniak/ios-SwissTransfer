# 📦 Infomaniak SwissTransfer for iOS

Welcome to the official repository for **Infomaniak SwissTransfer**, a secure and easy file transfer app for iOS, iPadOS, and macOS (via Catalyst). 👋

<a href="https://apps.apple.com/app/infomaniak-swisstransfer/id6737686335"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1662076800"></a>

## 📖 About Infomaniak SwissTransfer

Infomaniak SwissTransfer is part of the <a href="https://www.infomaniak.com/">Infomaniak</a> ecosystem, providing a privacy-focused 🔒, Swiss-based 🇨🇭 file transfer solution with a beautiful native iOS experience. Built with Swift and SwiftUI, this app offers a fast, secure, and user-friendly way to send files up to 50 GB - free and without registration - and keep your transfers for up to 30 days.

## 🏗️ Architecture

The project follows a modular architecture with clear separation of concerns:

- **SwissTransfer**: Main app target containing SwiftUI views, scenes, and app lifecycle
- **SwissTransferCore**: Business logic framework with API layer, state managers, and data models
- **SwissTransferCoreUI**: Shared UI components and view modifiers
- **SwissTransferResources**: Assets, localized strings, and resources
- **SwissTransferFeatures**: Feature modules including
- **Extensions**: Share extension and App Clip

A <a href="https://github.com/Infomaniak/multiplatform-SwissTransfer">KMP library</a> is used to share code between the iOS and Android versions of the app.

## 🛠️ Technology Stack

- **Language**: Swift 5.10
- **UI Framework**: SwiftUI (primary) with UIKit integration
- **Shared Logic**: Kotlin Multiplatform (KMP) via <a href="https://github.com/Infomaniak/multiplatform-SwissTransfer">multiplatform-SwissTransfer</a>
- **Build System**: <a href="https://tuist.io/">Tuist</a> for project generation and SPM dependency management
- **Tool Management**: <a href="https://mise.jdx.dev/">Mise</a> for managing tool versions
- **Key Dependencies**:
  - Lottie for animations
  - Sentry for error tracking
  - Infomaniak Core libraries for common functionality
  - QRCode for QR code generation
- **Minimum iOS**: 16.6+

## 🚀 Getting Started

### Prerequisites

1. Install <a href="https://mise.jdx.dev/">Mise</a> for tool version management:
   ```bash
   curl https://mise.run | sh
   ```

2. Bootstrap the development environment:
   ```bash
   mise install
   # Activate mise for your shell:
   # For bash/zsh: eval "$(mise activate bash)"
   # For fish: mise activate fish | source
   # Or follow: https://mise.jdx.dev/getting-started.html#shells
   ```

3. Install dependencies and generate the Xcode project:
   ```bash
   tuist install
   tuist generate
   ```

### Building and Running

Open the generated `SwissTransfer.xcworkspace` in Xcode and build the project, or use:
```bash
xcodebuild -scheme "SwissTransfer"
```

## 🧪 Testing

You can run the tests using Xcode or Tuist. The project includes unit tests to ensure code quality and reliability.

## 🤝 Contributing

If you see a bug or an enhancement point, feel free to create an issue, so that we can discuss it. Once approved, we or you (depending on the priority of the bug/improvement) will take care of the issue and apply a merge request. Please, don't do a merge request before creating an issue.

## 📄 License

This project is under GPLv3 license. See the LICENSE file for more details.
