# 🔪 Fresh Chicken Butcher Shop — Flutter App

## Project Structure

```
chicken_flutter/
├── lib/
│   ├── main.dart                    ← App entry point
│   ├── constants.dart               ← Colors, theme, API URL
│   ├── models/
│   │   ├── product.dart             ← Product data model
│   │   └── order.dart               ← Order / CartItem models
│   ├── services/
│   │   ├── api_service.dart         ← PHP backend API calls
│   │   └── cart_provider.dart       ← Cart state management
│   ├── screens/
│   │   ├── home_screen.dart         ← Product listing
│   │   ├── cart_screen.dart         ← Cart view
│   │   ├── checkout_screen.dart     ← Address + payment form
│   │   └── confirmation_screen.dart ← Order success screen
│   └── widgets/
│       └── product_card.dart        ← Individual product card
├── android/
│   └── app/src/main/AndroidManifest.xml
└── pubspec.yaml                     ← Dependencies
```

---

## Setup Steps

### 1. Install Flutter
```bash
# Download from https://flutter.dev/docs/get-started/install
flutter --version   # should show 3.x.x
```

### 2. Install dependencies
```bash
cd chicken_flutter
flutter pub get
```

### 3. Configure your API
Edit `lib/constants.dart`:
```dart
const String kBaseUrl = 'https://yoursite.com/chicken_shop/php';
const String kKhaltiPublicKey = 'your_khalti_public_key';
const String kEsewaMerchantId = 'your_esewa_merchant_id';
```

### 4. Add provider dependency
In `pubspec.yaml`, make sure this is included:
```yaml
dependencies:
  provider: ^6.1.1
```

### 5. Run the app
```bash
# On Android emulator or real device
flutter run

# Build release APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## Payment Integration

### Khalti
1. Register at https://khalti.com/api/payment
2. Get Public Key → paste in `constants.dart`
3. Uncomment the `KhaltiScope` code in `checkout_screen.dart`
4. Wrap your `MaterialApp` with `KhaltiScope`:
```dart
KhaltiScope(
  publicKey: kKhaltiPublicKey,
  child: MaterialApp(...),
)
```

### eSewa
1. Register at https://esewa.com.np/epay
2. Get Merchant ID (SCD) → paste in `constants.dart`
3. Uncomment the `launchUrl` code in `checkout_screen.dart`
4. Add `url_launcher` to pubspec.yaml

---

## Backend
This Flutter app works with the PHP + MySQL backend.
Make sure your PHP files are uploaded and running at `kBaseUrl`.

---

## Build APK (for Android)
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
# Share this APK with customers or upload to Play Store
```

## Screens
1. **Home** — Browse all chicken cuts with price/kg
2. **Cart** — View selected items, quantities, total
3. **Checkout** — Enter name, phone, address, pick Khalti or eSewa
4. **Confirmation** — Order number, delivery info, total paid