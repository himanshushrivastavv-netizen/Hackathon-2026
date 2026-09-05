# 🌾 AgroMitra — Smart Farmer-to-Buyer Marketplace

> **Theme:** Strengthening Market Linkages & Price Discovery for Farmers  
> **Platform:** Android (Flutter + Dart) & Web | **AI:** Google Gemini 2.5 Flash Vision | **Backend:** Supabase

---

## 📱 Project Overview

**AgroMitra** empowers farmers to make informed, profitable selling decisions by combining real-time Mandi (APMC) price benchmarks with AI-assisted visual quality grading and a direct farmer-to-buyer marketplace.

### ✨ Key Features:
- 🇮🇳 **Multi-Language Support:** English, हिन्दी (Hindi), मराठी (Marathi).
- 🍅 **Mandi APMC Benchmark Discovery:** Live modal, minimum, and maximum prices with trend indicators across Maharashtra mandis (Vashi, Lasalgaon, Pune, Solapur, etc.).
- 🤖 **Google Gemini 2.5 Flash Vision AI:** Instant visual crop quality grading (Grade A / B / C), confidence percentage, and freshness reasoning with offline fallback.
- ⚖️ **Transparent Pricing Formula:** Defensible suggested asking price calculated directly from APMC benchmarks:
  $$\text{Suggested Price} = \text{Mandi Modal} \times \text{Quality Factor}$$
  $$\text{Grade A: } 1.10\times \quad|\quad \text{Grade B: } 1.00\times \quad|\quad \text{Grade C: } 0.90\times$$
- 🔄 **Real-Time Farmer & Buyer Interconnection:** Listings published by farmers instantly sync to buyer dashboards, search screens, and produce comparison views.
- 📞 **Direct Contact via Phone Dialer:** Privacy-safe location display (*Village/Taluka/District*) and one-tap direct contact without middlemen.
- 🏛️ **Government Schemes Portal:** Curated guide to PM-KISAN, PMFBY, eNAM, KCC, and PM-KUSUM with direct links to official government portals.

---

## 🏗️ Architecture & Folder Structure

```text
Agromitra/
├── android/                   # Native Android configuration (API 21+, Camera, Internet, Dialer)
├── lib/
│   ├── config/
│   │   ├── api_keys.dart           # Centralized Google Gemini API Key configuration
│   │   └── supabase_config.dart   # Centralized Supabase URL & Anon Key configuration
│   ├── models/
│   │   ├── ai_result.dart          # Structured AI grading response & fallback model
│   │   ├── listing.dart            # Farmer crop listing model
│   │   ├── price.dart              # Mandi APMC price benchmark model
│   │   ├── profile.dart            # User profile (Farmer / Buyer / Admin)
│   │   ├── scheme.dart             # Government schemes model
│   │   └── news.dart               # Agricultural news model
│   ├── services/
│   │   ├── ai_service.dart         # Gemini 2.5 Flash Vision API integration with fallback
│   │   ├── supabase_service.dart   # Supabase Auth, DB sync, and local offline cache
│   │   ├── app_state.dart          # Central reactive state manager
│   │   ├── price_service.dart      # Mandi price discovery lookup
│   │   └── mock_data_service.dart  # Seeded Maharashtra agricultural demo datasets
│   ├── utils/
│   │   ├── price_logic.dart        # Transparent pricing formula calculations
│   │   ├── app_theme.dart          # Material 3 agricultural design system
│   │   └── app_strings.dart        # Complete EN / HI / MR translations
│   ├── widgets/                    # Reusable UI components (buttons, badges, cards)
│   ├── screens/
│   │   ├── language/               # Language selection screen
│   │   ├── landing/                # Farmer / Buyer role selection
│   │   ├── auth/                   # Phone + Password authentication
│   │   ├── farmer/                 # Farmer Dashboard, Mandi Prices, Sell Produce, My Listings
│   │   ├── buyer/                  # Buyer Home, Crop Search, Price Comparison, Details
│   │   ├── schemes/                # Government Schemes listing & detail screens
│   │   └── admin/                  # Admin control dashboard
│   └── main.dart                   # Application entry point
├── supabase_schema.sql             # Full PostgreSQL schema with RLS policies
├── server.js                       # Local HTTP preview server
└── pubspec.yaml                    # Flutter dependencies
```

---

## 🚀 How to Open in Android Studio & Build APK

### 1. Open the Project in Android Studio
1. Launch **Android Studio**.
2. Click **Open** (or `File` → `Open...`).
3. Select the `Agromitra` folder (`c:\Users\hp\OneDrive\Desktop\Hackathon\Agromitra`).
4. Wait for Android Studio to index and run `flutter pub get`.

### 2. Connect Device / Emulator & Run
- Connect your Android phone via USB (with **USB Debugging** enabled) or start an Android Virtual Device (AVD).
- Click the green **Run** (▶️) button or run in the terminal:
  ```bash
  flutter run -d android
  ```

### 3. Build Android APK
To generate the production APK:
```bash
flutter build apk --release
```
The output APK file will be generated at:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 How to Run Locally on Web

The app includes a built-in web distribution:

1. **Start the local server:**
   ```bash
   node server.js
   ```
2. **Open in your browser:**
   ```text
   http://localhost:8080
   ```

To recompile the web bundle after any changes:
```bash
flutter build web
```

---

## 🔑 Configuration

### 1. Google Gemini API Key
The Gemini 2.5 Flash Vision API key is configured in [`lib/config/api_keys.dart`](lib/config/api_keys.dart):
```dart
class ApiKeys {
  static const String geminiApiKey = "AQ.Ab8RN6K9hNNqP0FPATvrJNLfGfbSLSfNv4sUI8OkGGSAFjf40g";
}
```

### 2. Supabase Backend Configuration
To connect to your own Supabase project:
1. Open [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart) and add your Project URL and Anon Key:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = "https://your-project.supabase.co";
     static const String supabaseAnonKey = "your-anon-key";
   }
   ```
2. Open the **SQL Editor** in your Supabase dashboard and run the entire script in [`supabase_schema.sql`](supabase_schema.sql).

---

## 🧪 End-to-End Verification Flow

1. **Language & Role Selection:**
   - Select **English** → tap **Continue as Farmer** → tap **Login**.
2. **Sell Produce Flow (Farmer):**
   - Tap **Sell** (middle `+` tab).
   - Step 1: Select **Tomato**, set quantity to **25 Quintal**.
   - Step 2: Upload produce photos and tap **✨ Analyze with AI**.
   - Step 3: Observe **Grade A**, confidence score (92%), and reasoning.
   - Step 4: Review transparent price breakdown ($₹24 \times 1.10 = ₹26.40\text{/kg}$) and tap **Publish Listing**.
3. **Buyer Discovery (Buyer):**
   - Log out from Farmer profile and log in as **Buyer**.
   - The newly published Tomato listing immediately appears on the **Buyer Home** and **Search** screens.
   - Open listing details to compare prices with Mandi rates and tap **Contact Farmer** to dial.
