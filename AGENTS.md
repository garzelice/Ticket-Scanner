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
| `Models/Medusa.swift` | Main @Observable state class, sync logic |
| `Models/Auth.swift` | Authentication state & token management |
| `Models/TicketRecord.swift` | SQLite table schema for offline tickets |
| `Services/APIService.swift` | HTTP client for Medusa API |
| `Services/Database.swift` | SQLite database initialization |
| `Services/NetworkMonitor.swift` | Network connectivity monitoring |

## Dependencies

- **CodeScanner** (twostraws) - QR code scanning view
- **keychain-swift** - Secure token storage
- **SQLiteData** - Local ticket persistence for offline mode
- **swift-dependencies** - Required by SQLiteData

## Building

1. Open `Ticket Scanner.xcodeproj` in Xcode
2. Wait for Swift Package Manager to resolve dependencies
3. Run on simulator/device

## Offline Mode

- Tickets are synced from Medusa API and stored locally in SQLite
- When offline, tickets are read from local SQLite database
- Scanned tickets are marked locally with `needsSync = true`
- When network becomes available, pending scans are synced to Medusa
- New endpoint required on backend: `POST /admin/tickets/{id}/scan`

## Testing

No test infrastructure currently configured.

## Notes

- PointOfSale views are commented out in `ContentView.swift` - leave them ignored
- QR scanning is implemented via `CodeScannerView` from the CodeScanner package
- Tickets are fetched via `apiService.getTickets()` and stored in `medusa.tickets`
- Use `medusa.syncTickets(auth:auth, isOnline:isOnline)` to sync from server
- Use `medusa.markTicketScanned(id:isOnline:)` to mark a ticket as scanned