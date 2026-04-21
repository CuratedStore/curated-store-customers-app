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

### 5. Storefront and Product Discovery (Mobile)
- Home/catalog modules added for featured, new arrivals, sale, and best sellers.
- Product list with search, category filter, and sort (newest, low-high, high-low).
- Product detail page with description, tags, variants, and image.

### 6. Cart and Checkout (Mobile)
- Cart list with line totals and quantity controls.
- Stock guard enforced in cart quantity and add-to-cart actions.
- Checkout supports payment method options (COD, UPI, Card).
- Create order from cart includes selected payment method and default shipping address.

### 7. Orders and Post-Order (Mobile)
- Orders list and detailed order screen.
- Order detail includes items, shipping address, total, status, and timeline events.
- Invoice action added (mobile trigger).
- Cancel and return request flows with reason capture and pending request guard.

### 8. Account and Preferences (Mobile)
- Profile view/update (name, email, phone).
- Address book list/add/delete and default address handling.
- Preferences management (currency, language, email notifications, SMS notifications).

### 9. Wishlist (Mobile)
- Wishlist tab with list/add/remove behavior.
- Move wishlist items directly to cart.

## Pending

### 1. Backend Completion
- Replace scaffolded API endpoints with production implementations for all customer modules.
- Add dedicated OTP request/verify endpoints with expiry and retry limit logic.
- Add Google OAuth token verification endpoint.

### 2. Production Hardening
- Persist auth token securely and add refresh/session lifecycle handling.
- Map backend validation codes to field-specific UI errors.
- Connect invoice action to actual downloadable file endpoint.

## API Notes
- Current customers API has multiple scaffolded endpoints returning placeholder responses.
- Mobile app is intentionally wired to remote URLs and shows status when scaffold responses are returned.
