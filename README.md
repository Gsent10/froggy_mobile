# Froggy Mobile — Flutter App

A mobile-first Flutter application built for the FroggyTalk take-home assessment. The app enables African diaspora users to manage multi-currency digital wallets — sign up, create wallets tied to their country's currency, top up via multiple payment methods, and transfer funds between their own wallets.

---

## Features

- **Authentication** — Registration with OTP verification, login, forgot/reset password, and automatic session handling (401 auto-logout)
- **Multi-currency wallets** — Create one or more wallets per user, each tied to a supported currency (NGN, GBP, USD, GHS, KES). Wallet cards display the country flag, balance toggle (show/hide), and scroll with a dot indicator when multiple wallets exist
- **Dashboard** — Personalised home screen with wallet card carousel, quick-action shortcuts, and a recent-transactions feed
- **Top-up** — Fund any wallet via Debit Card, Bank Transfer, or USSD with live success/failure result screens
- **Wallet-to-wallet transfer** — Send funds between your own wallets with real-time exchange-rate conversion displayed before confirming
- **Wallet details** — Per-wallet activity history with pull-to-refresh
- **Idempotency** — Every top-up and transfer generates a UUID idempotency key, preventing duplicate transactions on retry

---

## Tech Stack

| Concern | Choice |
|---|---|
| Framework | Flutter 3.x (Dart 3) |
| State management | `flutter_bloc` (BLoC pattern) |
| HTTP client | `dio` |
| Local storage | `shared_preferences` |
| Unique keys | `uuid` |
| Fonts | `google_fonts` (DM Sans) |
| Toasts | `fluttertoast` |
| OTP input | `pinput` |

---

## Architecture

```
lib/
├── core/
│   ├── network/          # ApiEndpoints — Dio client, auth headers, safeSendRequest
│   ├── utils/            # Colour/font constants, screen-size extensions, helpers
│   └── widgets/          # Shared widgets (Loading overlay, etc.)
└── features/
    ├── auth/             # Login, Register, OTP, Forgot/Reset password
    ├── dashboard/        # DashboardBloc, models, HomePage
    ├── wallet/           # WalletBloc, WalletListPage, WalletDetailsPage, AddWalletPage
    ├── topup/            # TopupBloc, TopupPage, TopupResultPage
    └── transfer/         # TransferBloc, TransferPage, TransferResultPage
```

Each feature follows the same structure: `bloc/` (event · state · bloc), `data/` (models, static data), and `presentation/` (pages · widgets).

All API calls go through `ApiEndpoints.safeSendRequest`, which centralises error parsing, toast display, and the global 401 redirect to `/login`.

---

## Prerequisites

- Flutter SDK `>=3.12.0` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.0.0` (bundled with Flutter)
- An Android emulator, iOS simulator, or physical device

---

## Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd froggy_mobile

# 2. Install dependencies
flutter pub get

# 3. (Optional) Point the app at your local backend
#    Open lib/core/network/api_endpoints.dart and update:
static const String API_DOMAIN = "http://127.0.0.1:8000/";

# 4. Run the app
flutter run
```

> **Flags** — country flag images (`GB.png`, `NG.png`, `US.png`, `GH.png`, `KE.png`) must be placed in `assets/flags/`. The `pubspec.yaml` already declares the `assets/flags/` directory.

---

## Supported Currencies

| Country | Currency |
|---|---|
| Nigeria | NGN (₦) |
| United Kingdom | GBP (£) |
| United States | USD ($) |
| Ghana | GHS (₵) |
| Kenya | KES (KSh) |

---

## Environment

The API base URL is defined in `lib/core/network/api_endpoints.dart`:

```dart
static const String API_DOMAIN = "https://sandybrown-gerbil-669577.hostingersite.com/";
```

Change this to `http://10.0.2.2:8000/` (Android emulator) or `http://127.0.0.1:8000/` (iOS simulator / physical device on the same network) when running against a local Laravel server.

---

## What I Would Improve With More Time

- Push notifications for incoming transfers and top-up confirmations
- Biometric authentication for app unlock and transaction confirmation
- Integrate a real payment gateway (Paystack or Flutterwave) to replace the mock
- Add real-time exchange rates from an external FX API instead of static rates
- Queue top-up processing via Laravel Jobs for better scalability
- Add rate limiting on auth endpoints to prevent brute-force attacks
- Full feature test coverage for all wallet operations