# Curated Store Customers App: Progress Tracker

This file now tracks what is completed versus pending in the Flutter customers app.

## Confirmed Scope Update
- Authentication should include Splash, Login, and Sign Up only.
- Forgot password and reset password are not required.
- Login must support password + OTP and include a Login with Google button.

## Completed

### 1. Core App and Theme
- Brand-consistent theme applied using Curated Store colors.
- Navigation shell created for Shop, Cart, Orders, and Account.
- App wired to remote API URL only.

### 2. Assets
- Web image assets copied into Flutter assets.
- Brand and product SVG assets configured and used in UI.

### 3. Authentication UX (Current)
- Splash screen implemented.
- Login screen implemented.
- Sign up screen implemented.
- Login with password + OTP flow UI implemented.
- Login with Google button added to login screen.
- Sign out action implemented.

### 4. API Wiring (Current)
- Health endpoint call integrated.
- Register and login endpoints integrated.
- Products, cart, and orders endpoints integrated in app state.
- Graceful fallback messaging added where backend endpoints are scaffolded.

## Pending

### 1. Backend Completion for Auth
- Dedicated OTP request/verify behavior must be finalized server-side.
- Google OAuth token verification endpoint must be finalized server-side.

### 2. Authentication Hardening
- OTP expiry timer and retry/attempt-limit UX.
- Proper secure token persistence and refresh behavior.
- Auth error mapping per backend validation codes.

### 3. Storefront and Commerce Depth
- Advanced home modules (featured/new/sale/best sellers) from real API data.
- Search, category filter, and sort behavior in catalog.
- Full product detail (variants/tags/media).

### 4. Account and Profile
- Profile read/update screens with real API payload mapping.
- Address book full CRUD and default address handling.
- Preferences module (currency/language/notification toggles).

### 5. Orders and Post-Order
- Full order detail and timeline events.
- Cancel/return request flows with reason capture and conflict guards.
- Invoice download flow.

### 6. Wishlist
- Wishlist list/add/remove implementation.

## API Notes
- Current customers API has multiple scaffolded endpoints returning placeholder responses.
- Mobile app is intentionally wired to remote URLs and shows status when scaffold responses are returned.
