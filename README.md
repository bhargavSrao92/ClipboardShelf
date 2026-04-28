# ClipShelf

ClipShelf is a polished SwiftUI clipboard companion for iPhone and iPad, designed around privacy-safe paste flows, beautiful organization, and fast recall for both text and images.

## Product highlights

- Onboarding flow that explains the iOS paste model clearly
- Home dashboard with quick paste, stats, pinned essentials, and recent activity
- Searchable library with detail views for every saved clip
- Light Mode and Dark Mode support using semantic system styling
- Accessibility-friendly typography, contrast, and VoiceOver labels

## Key iOS behavior

ClipShelf uses Apple's system paste control instead of background pasteboard reads. That keeps the app aligned with iOS privacy expectations and reduces repeated paste prompts compared with direct clipboard polling.

## Project structure

- `ClipShelf/DesignSystem`: theme tokens and shared styling
- `ClipShelf/Components`: reusable UI building blocks
- `ClipShelf/Views`: onboarding, home, detail, library, and settings flows
- `ClipShelf/ViewModels`: clipboard import and persistence logic

## Open the project

1. Open `ClipShelf.xcodeproj` in Xcode.
2. Select your Apple development team and update the bundle identifier if needed.
3. Run on an iPhone simulator or device.

