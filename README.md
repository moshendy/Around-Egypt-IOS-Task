# Around Egypt

A SwiftUI iOS app for exploring virtual tours of Egypt's most famous experiences. Built with MVVM architecture, offline caching, and robust unit/UI testing.

## Features
- Home screen with:
  - Horizontally scrolling recommended experiences
  - Vertically scrolling recent experiences
  - Search with IME action and clear
- Detail sheet for each experience
- Like functionality (one-like only, synced with API)
- Offline support (Core Data caching)
- Network status banners
- Pixel-perfect UI (Figma reference)
- Accessibility identifiers for UI testing

## Architecture
- **MVVM**: Clear separation of Views, ViewModels, and Models
- **Networking**: APIService with protocol abstraction for testability
- **Caching**: Core Data via ExperienceCacheManager
- **Dependency Injection**: For easy mocking in tests
- **SwiftUI**: Declarative, modern UI

## Design Patterns
- MVVM
- Protocol-Oriented Programming
- Singleton (APIService, NetworkMonitor)
- ObservableObject & @Published
- Dependency Injection

## Setup Instructions
1. **Clone the repo:**
   ```sh
   git clone <repo-url>
   cd AroundEgypt
   ```
2. **Open in Xcode:**
   Open `AroundEgypt.xcodeproj` in Xcode 14 or later.
3. **Install dependencies:**
   - Uses Swift Package Manager for Alamofire and Kingfisher (auto-resolves in Xcode)
4. **Build and run:**
   - Select a simulator or device and press ⌘R

## Testing
- **Unit Tests:**
  - Run with ⌘U
  - Tests cover ViewModel logic, error handling, and async flows
- **UI Tests:**
  - Run with ⌘U
  - Tests cover home screen, search, detail sheet, like button, loading, and offline states
- **Accessibility:**
  - Key UI elements have accessibility identifiers for robust UI testing

## API Endpoints
- `GET /api/v2/experiences?filter[recommended]=true` (Recommended)
- `GET /api/v2/experiences` (Recent)
- `GET /api/v2/experiences?filter[title]={search_text}` (Search)
- `GET /api/v2/experiences/{id}` (Single experience)
- `POST /api/v2/experiences/{id}/like` (Like)

## Offline Support
- Experiences are cached locally using Core Data
- App works offline with last-synced data

## Contact
- **Author:** Mohamed Shendy
- For questions or support, open an issue or contact via email

---

**Enjoy exploring Egypt virtually!** 