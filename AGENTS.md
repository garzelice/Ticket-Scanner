# AGENTS.md - Ticket Scanner

## Project Overview

SwiftUI iOS app for scanning QR code tickets. Connects to a Medusa e-commerce backend API.

## Focus Area

**QR Code ticket scanning** - ignore PointOfSale code for new work.

## Key Files

| File | Purpose |
|------|---------|
| `Ticket_ScannerApp.swift` | App entry point, auth init |
| `Views/ScanView.swift` | QR scanner UI using CodeScanner lib |
| `Models/Medusa.swift` | Main @Observable state class |
| `Models/Auth.swift` | Authentication state & token management |
| `Services/APIService.swift` | HTTP client for Medusa API |

## Dependencies

- **CodeScanner** (twostraws) - QR code scanning view
- **keychain-swift** - Secure token storage

## Building

Open `Ticket Scanner.xcodeproj` in Xcode and run on simulator/device.

## Testing

No test infrastructure currently configured.

## Notes

- PointOfSale views are commented out in `ContentView.swift` - leave them ignored
- QR scanning is implemented via `CodeScannerView` from the CodeScanner package
- Tickets are fetched via `apiService.getTickets()` and stored in `medusa.tickets`