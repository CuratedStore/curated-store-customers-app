# Curated Store Customers App: Required Modules and Features

This list is derived from the current web application implementation in CuratedStore (routes + controllers + customer views).

## 1. Authentication and Account Access
- Login with email + OTP flow
- OTP verification with expiry and attempt limits
- Register (email + password)
- Email verification with code
- Resend verification code
- Forgot password flow (email)
- Reset password via token link
- Logout
- Auth session refresh endpoint behavior

## 2. Storefront and Product Discovery
- Home screen modules:
  - Featured products
  - New arrivals
  - Sale products
  - Best sellers
  - Category strips/sections
- Shop catalog listing
- Shop search (name/short description/description)
- Shop category filter
- Shop sort:
  - Newest
  - Price low to high
  - Price high to low
- Product detail page:
  - Name, description, short description
  - Price
  - Tags
  - Variants
  - Image

## 3. Customer Profile and Preferences
- Account profile view
- Update profile (name/display name, email, phone)
- Address book:
  - List addresses
  - Add address
  - Delete address
  - Default address handling
- Preferences:
  - Currency (INR/USD/EUR)
  - Language (en/hi)
  - Email notifications toggle
  - SMS notifications toggle

## 4. Cart and Checkout
- Cart listing with line totals
- Add to cart
- Remove from cart
- Quantity + stock guard (cannot exceed stock)
- Checkout screen with cart summary
- Create order from cart
- Payment method options:
  - COD
  - UPI
  - Card

## 5. Orders and Post-Order
- Orders list
- Order detail:
  - Items
  - Shipping address
  - Total
  - Status
  - Timeline/status events
- Download invoice
- Order confirmation screen
- Order action requests:
  - Cancel request
  - Return request
  - Request reason capture
  - Pending request conflict guard

## 6. Wishlist
- Wishlist listing
- Add to wishlist
- Remove from wishlist

## 7. API-Level Endpoints Present for Customer Domain
- Auth: register/login/logout
- Products: list/detail
- Categories: list
- Cart: add/list/remove
- Orders: create/list/detail
- Account: profile, update profile, addresses

## Notes for Flutter Implementation
- Build modules above as first-class features (no placeholders).
- Keep status-driven logic for order requests and stock validation consistent with web behavior.
- Ensure OTP and verification UX supports retry, expiry, and error states.
