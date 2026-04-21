# Curated Store Customers App

Customer-facing Flutter application for the Curated Store marketplace.

## Current Implementation Status

- The app now includes customer modules for catalog, cart, orders, and account.
- UI theme is aligned to Curated Store brand colors:
	- Primary: `#5F5381`
	- Secondary: `#E6E6FA`
- Image assets are synced from the web app `public/images` directory into Flutter `assets/images`.
- API integration is wired to the live Customers API base URL:
	- `https://customers-api.curatedstore.in`

## API Notes

- Health endpoint used by app bootstrap: `/api/health`
- Feature endpoints currently wired from backend scaffold routes:
	- `/api/api/auth/*`
	- `/api/api/products`
	- `/api/api/categories`
	- `/api/api/cart*`
	- `/api/api/orders*`
	- `/api/api/account/profile`

If backend returns scaffold responses (`501`), the app keeps working with local preview product data and displays the API response status.

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio or Xcode (for emulator/device testing)

### Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Project Structure

- `lib/` - Main application code
- `test/` - Unit and widget tests
- `pubspec.yaml` - Project dependencies and configuration

## Features

- Brand-themed catalog browsing
- Cart management with local order creation fallback
- Order history view
- Account login/register API actions
- API health/status visibility from app

## Contributing

Follow the project's coding standards and guidelines.
