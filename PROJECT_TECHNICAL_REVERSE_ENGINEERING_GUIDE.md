# 🌾 AGROMITRA: TECHNICAL REVERSE-ENGINEERING & ARCHITECTURAL AUDIT GUIDE

> **Document Status:** Comprehensive Technical Reference & Hackathon Defense Guide  
> **Target Audience:** Hackathon Presenters, Technical Judges, Software Architects & Student Developers  
> **Repository Name:** `Agromitra`  
> **Platform Targets:** Android (Native APK / Flutter), Web (Flutter Web SPA / Node.js static server)  
> **Theme:** Strengthening Market Linkages & Price Discovery for Farmers

---

## 1. EXECUTIVE PROJECT OVERVIEW

### 1.1 Non-Technical Summary (For Beginners & General Audience)
**AgroMitra** ("Farmer's Friend") is an agricultural technology platform engineered to eliminate price exploitation and information asymmetry for smallholder Indian farmers. In traditional agricultural supply chains, farmers often sell their produce to local brokers (*dalals* / middlemen) at a significant discount because they lack real-time market rate visibility and objective quality grading. 

AgroMitra solves this by providing:
1. **Real-time Mandi (APMC) Price Discovery:** Farmers and buyers can view live daily minimum, modal, and maximum benchmark prices from agricultural markets across Maharashtra (e.g., Vashi, Lasalgaon, Pune, Solapur, Nagpur).
2. **AI-Assisted Computer Vision Crop Grading:** Farmers can photograph their produce; the system uses Google Gemini Vision AI to classify produce into standard quality tiers (**Grade A**, **Grade B**, or **Grade C**) with confidence scores and descriptive freshness reasoning.
3. **Transparent Price Discovery Formula:** The application calculates a defensible suggested selling price based on Mandi modal rates and quality multipliers, protecting farmers from distress sales.
4. **Direct Farmer-to-Buyer Marketplace:** Farmers can list crops with photos, quantities, and pricing; buyers can browse listings, compare them against live APMC rates, and initiate direct contact via one-tap phone calls or WhatsApp.
5. **Multi-Lingual Accessibility:** Full native support for English, हिन्दी (Hindi), and मराठी (Marathi).
6. **Government Agricultural Schemes Portal:** Direct guidance on central and state schemes including PM-KISAN, PMFBY crop insurance, eNAM, KCC, and PM-KUSUM.

---

### 1.2 Technical Summary (For Judges & Senior Engineers)
Architecturally, AgroMitra is a **cross-platform client-server hybrid mobile and web application** powered by **Flutter (Dart 3)**, backed by **Supabase (PostgreSQL 15 with Row Level Security, Auth, and Storage)**, integrated with **Google Gemini 2.5 Flash Vision AI** for multimodal visual quality grading, and connected to **Data.gov.in (Agmarknet Open Data API)** for live commodity market rates.

The system is designed with a **3-tier fault-tolerant fallback architecture**:
- **Layer 1 (Live Third-Party API):** Live HTTP REST queries to the Data.gov.in Agmarknet API and Gemini Generative AI endpoints.
- **Layer 2 (Cloud Backend Cache & Sync):** Supabase PostgreSQL database tables (`profiles`, `listings`, `prices`, `schemes`, `news`) and Supabase Storage bucket (`produce-images`).
- **Layer 3 (Deterministic Offline-First Fallback):** In-memory mock datasets and rule-based heuristic algorithms that guarantee zero runtime crashes and 100% feature availability even during network loss or API rate limiting during live judging demonstrations.

---

## 2. PROJECT DIRECTORY STRUCTURE

```text
Hackathonready/
├── .idea/                                  # Android Studio / IntelliJ IDE workspace metadata
├── Agromitra/                              # Core Project Root
│   ├── .dart_tool/                         # Dart SDK build artifacts and package configs
│   ├── .github/                            # CI/CD workflows (if configured)
│   ├── .idea/                              # IDE configurations
│   ├── .stitch/                            # Design & UI asset generator metadata
│   ├── android/                            # Native Android project wrapper
│   │   ├── app/                            # Android Application Module
│   │   │   ├── src/main/
│   │   │   │   ├── AndroidManifest.xml     # App permissions, intents, activity entry
│   │   │   │   ├── kotlin/com/example/agromitra/MainActivity.kt  # FlutterActivity entry
│   │   │   │   └── res/                    # App icons, splash screens, launch themes
│   │   │   ├── build.gradle.kts            # App-level Gradle build script (SDK 21+, Java 17)
│   │   ├── build.gradle.kts                # Root project Gradle configuration
│   │   ├── settings.gradle.kts             # Gradle plugin repositories and subproject inclusions
│   │   └── gradle.properties               # JVM memory allocations and AndroidX flags
│   ├── build/                              # Compiled outputs (web SPA bundle, Android APK)
│   │   └── web/                            # Production Flutter Web SPA bundle
│   ├── lib/                                # Flutter / Dart Source Code
│   │   ├── config/                         # Application Credentials & Endpoint Configs
│   │   │   ├── api_keys.dart               # Google Gemini Generative AI API Key
│   │   │   └── supabase_config.dart        # Supabase Project URL & Anon Public Key
│   │   ├── models/                         # Strongly-Typed Data Transfer Objects (DTOs)
│   │   │   ├── ai_result.dart              # AI quality inspection output & fallback model
│   │   │   ├── listing.dart                # Produce listing entity (farmer, crop, price, status)
│   │   │   ├── news.dart                   # Agricultural advisory and news entity
│   │   │   ├── price.dart                  # APMC Mandi market price benchmark entity
│   │   │   ├── profile.dart                # User profile model (Farmer / Buyer / Admin)
│   │   │   └── scheme.dart                 # Government scheme model
│   │   ├── services/                       # Business Logic, Data Providers & API Integrations
│   │   │   ├── ai_service.dart             # Gemini 2.5 Flash Vision multimodal API client
│   │   │   ├── app_state.dart              # Central ChangeNotifier reactive state manager
│   │   │   ├── mock_data_service.dart      # Seeded Maharashtra agricultural datasets
│   │   │   ├── price_service.dart          # 3-Tier Mandi price discovery & Agmarknet API client
│   │   │   └── supabase_service.dart       # Supabase Auth, PostgreSQL CRUD, and Storage
│   │   ├── utils/                          # Styling, Localization & Arithmetic Logic
│   │   │   ├── app_strings.dart            # Tri-lingual dictionary (English, Hindi, Marathi)
│   │   │   ├── app_theme.dart              # Material Design 3 theme system & color palette
│   │   │   └── price_logic.dart            # Transparent unit conversions & price formulas
│   │   ├── widgets/                        # Reusable UI Components
│   │   │   ├── ai_grade_badge.dart         # Color-coded Grade A/B/C visual badge
│   │   │   ├── custom_text_field.dart      # Form input widget with validation styling
│   │   │   ├── listing_card.dart           # Marketplace crop card with price diff indicator
│   │   │   ├── price_card.dart             # APMC Mandi benchmark price card with min/modal/max
│   │   │   ├── primary_button.dart         # Themed full-width tactile action button
│   │   │   ├── produce_image_view.dart     # Robust image renderer (Network / Base64 / Local)
│   │   │   ├── scheme_card.dart            # Government scheme card with category tag
│   │   │   └── search_bar_widget.dart      # Real-time search and filtering input
│   │   ├── screens/                        # User Interface Views
│   │   │   ├── admin/                      # Admin Oversight Portal
│   │   │   │   ├── admin_dashboard_screen.dart # Listings moderation & system metrics
│   │   │   │   └── admin_login_screen.dart     # Admin authentication portal
│   │   │   ├── auth/                       # Role-Based Authentication Screens
│   │   │   │   ├── buyer_login_screen.dart     # Buyer phone + password sign in
│   │   │   │   ├── buyer_signup_screen.dart    # Buyer registration with location metadata
│   │   │   │   ├── farmer_login_screen.dart    # Farmer phone + password sign in
│   │   │   │   ├── farmer_signup_screen.dart   # Farmer registration (Village, Taluka, District)
│   │   │   │   └── forgot_password_dialog.dart # Password assistance modal
│   │   │   ├── buyer/                      # Buyer Interface Flow
│   │   │   │   ├── buyer_home_screen.dart      # Buyer dashboard with recent crops & Mandi feeds
│   │   │   │   ├── buyer_listing_details_screen.dart # Listing details, phone dialer & WhatsApp
│   │   │   │   ├── buyer_main_nav.dart         # Buyer bottom navigation bar controller
│   │   │   │   ├── buyer_profile_screen.dart   # Buyer account settings & logout
│   │   │   │   └── buyer_search_screen.dart    # Marketplace crop search & district filter
│   │   │   ├── farmer/                     # Farmer Interface Flow
│   │   │   │   ├── farmer_home_screen.dart     # Farmer dashboard, daily highlight & quick actions
│   │   │   │   ├── farmer_main_nav.dart        # Farmer bottom navigation bar controller
│   │   │   │   ├── farmer_profile_screen.dart  # Farmer profile, language switch & account delete
│   │   │   │   ├── mandi_prices_screen.dart    # Mandi price discovery & 7-day trend viewer
│   │   │   │   ├── my_listings_screen.dart     # Farmer active / sold inventory management
│   │   │   │   └── sell_produce_screen.dart    # 3-step crop listing wizard with AI analysis
│   │   │   ├── landing/                    # Welcome Screen
│   │   │   │   └── landing_screen.dart         # Role selection (Farmer / Buyer / Admin)
│   │   │   ├── language/                   # Language Selection Screen
│   │   │   │   └── language_screen.dart        # Entry point language picker (EN / HI / MR)
│   │   │   └── schemes/                    # Government Welfare Portals
│   │   │       ├── scheme_details_screen.dart  # Scheme eligibility, benefits & official links
│   │   │       └── schemes_list_screen.dart    # Categorized schemes list
│   │   └── main.dart                       # Application root entry point
│   ├── scripts/                            # Operational & DevOps Automation
│   │   └── sync_mandi_prices.js            # Automated Node.js cron script syncing Data.gov.in to Supabase
│   ├── test/                               # Unit & Widget Test Suite
│   ├── web/                                # Flutter Web HTML/JS host scaffolding
│   ├── pubspec.yaml                        # Flutter project manifest and dependencies
│   ├── server.js                           # Node.js static SPA server for local web deployment
│   ├── supabase_schema.sql                 # PostgreSQL DDL, RLS policies, buckets, and RPCs
│   └── README.md                           # Documentation and quick start guide
└── PROJECT_TECHNICAL_REVERSE_ENGINEERING_GUIDE.md # (This comprehensive guide)
```

---

## 3. TECHNOLOGY STACK

| Layer | Technology | Purpose | Where Used |
| :--- | :--- | :--- | :--- |
| **Mobile & Frontend** | **Flutter (v3.13.2+)** | Cross-platform declarative UI framework compiled to native ARM / JavaScript | `lib/` directory, entire UI layer |
| **Language** | **Dart (v3.13.2+)** | Strongly-typed, object-oriented language for client business logic | All files inside `lib/` |
| **Styling & Design** | **Material Design 3** | Agricultural color schemes, typography, cards, and modal components | `lib/utils/app_theme.dart` |
| **State Management** | **ChangeNotifier / Provider Pattern** | Centralized reactive state propagation with zero bloated dependencies | `lib/services/app_state.dart` |
| **Backend as a Service** | **Supabase** | Cloud infrastructure providing PostgreSQL DB, Auth, and Storage | `lib/services/supabase_service.dart`, `lib/config/supabase_config.dart` |
| **Database** | **PostgreSQL 15+** | Relational database engine with Row Level Security (RLS) policies | Hosted on Supabase Cloud, defined in `supabase_schema.sql` |
| **Authentication** | **Supabase Auth / Phone Adapter** | Secure credential management, token sessions, and role checks | `supabase_service.dart`, `farmer_login_screen.dart`, etc. |
| **Cloud Storage** | **Supabase Storage (`produce-images`)** | Object storage for high-resolution crop photos uploaded by farmers | `supabase_schema.sql`, `supabase_service.dart` |
| **Artificial Intelligence** | **Google Gemini 2.5 Flash Vision** | Multimodal LLM for visual inspection, quality grading, and reason generation | `lib/services/ai_service.dart`, `lib/config/api_keys.dart` |
| **External Open API** | **Data.gov.in (Agmarknet)** | Live daily APMC Mandi commodity market arrivals and price records | `lib/services/price_service.dart`, `scripts/sync_mandi_prices.js` |
| **Native Android** | **Android SDK 34 / Kotlin 1.9** | Native container, camera access, hardware acceleration, telephony intent queries | `android/app/` directory |
| **Local Web Server** | **Node.js HTTP Server** | Multi-port SPA static file server for local judging demonstrations | `Agromitra/server.js` |

---

## 4. PROGRAMMING LANGUAGES

### 4.1 Dart
- **Role:** Primary client-side application language.
- **Where Used:** 100% of the Flutter application code in `lib/` (30+ source files).
- **Key Concepts Used:**
  - Null-safety (`String?`, `double?`).
  - Asynchronous concurrency (`Future<T>`, `async`/`await`).
  - Streams and Listeners (`ChangeNotifier`, `addListener()`, `notifyListeners()`).
  - Factory constructors for JSON deserialization (`AIResult.fromJson()`).

### 4.2 JavaScript (Node.js)
- **Role:** Web server delivery and background data synchronization.
- **Where Used:**
  1. `Agromitra/server.js`: Zero-dependency static HTTP server listening on ports 5000, 8080, and 3000 with SPA fallback routing to `build/web/index.html`.
  2. `Agromitra/scripts/sync_mandi_prices.js`: Automated Node.js pipeline fetching data from Data.gov.in and upserting into Supabase PostgREST endpoints.

### 4.3 SQL (PL/pgSQL)
- **Role:** Relational schema definition, database triggers, Row Level Security (RLS) policies, and stored procedures.
- **Where Used:** `Agromitra/supabase_schema.sql`.
- **Key Concepts Used:** `CREATE TABLE IF NOT EXISTS`, `REFERENCES auth.users(id) ON DELETE CASCADE`, `CREATE POLICY ... USING (auth.uid() = id)`, and `SECURITY DEFINER` stored procedure `delete_user_account()`.

### 4.4 Kotlin
- **Role:** Native Android bridge and application initialization.
- **Where Used:** `Agromitra/android/app/src/main/kotlin/com/example/agromitra/MainActivity.kt`.
- **Key Concepts Used:** Inherits from `io.flutter.embedding.android.FlutterActivity`.

### 4.5 Kotlin DSL (Gradle)
- **Role:** Android project compilation and dependency resolution configuration.
- **Where Used:** `android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/settings.gradle.kts`.

---

## 5. FRAMEWORKS AND LIBRARIES

### 5.1 Core & UI Libraries
- **`flutter` (SDK):** Provides the rendering engine (Impeller / Skia), Material 3 widget tree, and gesture system.
- **`cupertino_icons: ^1.0.8`:** iOS style icon assets fallback.
- **`intl: ^0.19.0`:** Date and currency formatting utilities.

### 5.2 Networking & API Clients
- **`http: ^1.2.2`:** High-performance HTTP client for communicating with Google Gemini AI endpoints (`generativelanguage.googleapis.com`) and Data.gov.in Agmarknet endpoints.
- **`supabase_flutter: ^2.8.0`:** Official Supabase client for Flutter, wrapping PostgREST (database queries), GoTrue (authentication), and Storage API.

### 5.3 Hardware & Native Integration
- **`image_picker: ^1.1.2`:** Allows farmers to capture live photographs using the device Camera (`ImageSource.camera`) or select photos from the Gallery (`ImageSource.gallery`).
- **`url_launcher: ^6.3.0`:** Triggers native OS intents to open the device phone dialer (`tel:+919876543210`), WhatsApp chat (`https://wa.me/...`), or external browser URLs for government schemes.

---

## 6. COMPLETE ARCHITECTURE

The application implements a **Layered Client-Server Architecture** with **Multimodal AI & Open-Data Integration** and **Local-First Fallback Resilience**.

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT TIER                                     │
│                     (Flutter Cross-Platform Engine)                          │
│                                                                              │
│   ┌──────────────────────────────────────────────────────────────────────┐   │
│   │                             UI LAYER                                 │   │
│   │  [LanguageScreen]  →  [LandingScreen]  →  [FarmerMainNav/BuyerMainNav]  │   │
│   │  [SellProduceWizard]  [MandiPricesScreen]  [BuyerDetailsScreen]      │   │
│   └──────────────────────────────────┬───────────────────────────────────┘   │
│                                      │ Reactive State Binding                 │
│   ┌──────────────────────────────────▼───────────────────────────────────┐   │
│   │                        STATE MANAGEMENT LAYER                        │   │
│   │             AppState (ChangeNotifier / Observer Pattern)             │   │
│   │     • User Session   • Listings List   • Mandi Prices   • Languages  │   │
│   └───────────────┬──────────────────────────────────────┬───────────────┘   │
│                   │                                      │                   │
│   ┌───────────────▼──────────────┐      ┌────────────────▼───────────────┐   │
│   │     DATA & SERVICE LAYER     │      │        AI & LOGIC LAYER        │   │
│   │  • SupabaseService           │      │  • AIService (Gemini 2.5)      │   │
│   │  • PriceService              │      │  • PriceLogic (APMC Formula)   │   │
│   │  • MockDataService (Fallback)│      │  • AppStrings (Localization)   │   │
│   └───────────────┬──────────────┘      └────────────────┬───────────────┘   │
└───────────────────┼──────────────────────────────────────┼───────────────────┘
                    │ HTTPS / REST                         │ HTTPS / REST
                    ▼                                      ▼
┌──────────────────────────────────────┐ ┌─────────────────────────────────────┐
│             BACKEND TIER             │ │            EXTERNAL AI TIER         │
│          (Supabase Cloud)            │ │       (Google Generative AI)        │
│                                      │ │                                     │
│  • GoTrue Auth (Session / Users)     │ │  • Gemini 2.5 Flash Vision Endpoint │
│  • PostgREST (Profiles, Listings)    │ │  • Multimodal Base64 Image Analysis │
│  • Storage Bucket (produce-images)   │ │  • JSON Structured Quality Output   │
│  • PostgreSQL RLS Security Policies  │ │                                     │
└──────────────────┬───────────────────┘ └─────────────────────────────────────┘
                   │
                   │ Automated Cron / Live Ingestion
                   ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                          GOVERNMENT OPEN DATA TIER                           │
│              (Data.gov.in / Agmarknet APMC Commodity Records)                │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. COMPLETE DATA FLOW

### Flow 1: Farmer Signs Up & Creates Account
1. **User Action:** Farmer inputs Name, Phone number (`9876543210`), Password, Village, Taluka, and District on `FarmerSignupScreen`.
2. **Frontend Validation:** `AppState.signupFarmer()` checks `phone.length == 10` and `password.length >= 6`.
3. **Backend Transmission:** `SupabaseService.signUp()` converts phone to email format (`user_9876543210@agromitra.app`) and calls `supabase.auth.signUp()`.
4. **Database Insertion:** Inserts corresponding metadata record into `public.profiles` table:
   ```sql
   INSERT INTO public.profiles (id, name, phone, role, village, taluka, district, language)
   VALUES (auth.uid(), 'Shweta Patil', '9876543210', 'farmer', 'Bhiwandi', 'Bhiwandi', 'Thane', 'en');
   ```
5. **State Update:** User session is stored in `AppState._currentUser`, triggering `notifyListeners()`.
6. **UI Transition:** Router shifts user into `FarmerMainNav` (Home Screen).

---

### Flow 2: Farmer Captures Crop Photo & Receives AI Quality Inspection
1. **User Action:** In `SellProduceScreen`, farmer selects commodity "Tomato" and taps **Take Photo** or **Choose from Gallery**.
2. **Image Capture:** `image_picker` retrieves `XFile`, validates size (`<= 10MB`), and extracts raw `Uint8List` image bytes.
3. **AI Dispatch:** Farmer taps **Analyze with AI**, triggering `AIService.analyzeProduceQuality()`:
   - Encodes image bytes into Base64 inline data.
   - Attaches strict prompt demanding JSON output only.
   - Sends HTTP POST request to:
     `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=[REDACTED]`
4. **AI Processing:** Gemini 2.5 Flash evaluates visual skin uniformity, color saturation, blemishes, and grading standards.
5. **Response Extraction:** Gemini returns JSON:
   ```json
   {
     "grade": "Grade A",
     "confidence": 92,
     "reason": "Bright crimson color, uniform medium-large size, firm texture and minimal blemishes."
   }
   ```
6. **UI Feedback:** Grade badge updates instantly on screen with 92% confidence indicator and freshness breakdown.

---

### Flow 3: Mandi APMC Price Discovery & Transparent Calculation
1. **Lookup:** `PriceService.getPriceForCommodity("Tomato")` queries cache/APMC feed.
2. **Benchmark Retrieval:** Finds Vashi APMC Modal Price = `₹24.00/kg`.
3. **Formula Application:** `PriceLogic.calculateSuggestedPrice(24.00, "Grade A")` calculates fair asking price.
4. **Margin & Commission Calculation:** `PriceLogic.calculateMiddlemanSavings(26.0, 20.0, "Quintal")` computes:
   $$\text{Total Gross Revenue} = 20 \text{ Quintals} \times 100 \text{ kg} \times ₹26.00 = ₹52,000$$
   $$\text{Middleman Brokerage Saved (10\%)} = ₹52,000 \times 0.10 = ₹5,200 \text{ extra income}$$
5. **Publish Action:** Farmer submits listing. `SupabaseService.createListing()` posts record to `public.listings` table in Supabase.

---

### Flow 4: Buyer Browses & Connects with Farmer
1. **Discovery:** Buyer opens `BuyerHomeScreen` or `BuyerSearchScreen`.
2. **Query:** `AppState.refreshListings()` queries Supabase table `public.listings` ordered by `created_at DESC`.
3. **Card Display:** Shows crop image, Grade A badge, asking price (`₹26.00/kg`), and Mandi comparison (`+₹2.00 vs Mandi`).
4. **Dialer / WhatsApp Action:** Buyer taps **Contact Farmer** on `BuyerListingDetailsScreen`:
   - Calls `launchUrl(Uri(scheme: 'tel', path: '+919876543210'))` to open the native phone dialer.
   - Or opens WhatsApp direct chat with pre-filled message: `"Hello Shweta Patil, I saw your listing for Tomato on AgroMitra..."`.

---

## 8. API DOCUMENTATION

### 8.1 Internal REST & Cloud APIs (Supabase Backend)

| Method | Endpoint / Table | Purpose | Request Payload | Response Data | Auth Required | Source File |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/auth/v1/signup` | Register Farmer/Buyer | `{ email, password, data }` | Auth Session + User UUID | None (Public) | `supabase_service.dart:127` |
| `POST` | `/auth/v1/token` | Sign In User | `{ email, password }` | JWT Access Token + User | None (Public) | `supabase_service.dart:251` |
| `GET` | `/rest/v1/profiles` | Fetch User Profile | Query: `?id=eq.UUID` | Profile record JSON | Yes (Bearer JWT) | `supabase_service.dart:257` |
| `POST` | `/rest/v1/profiles` | Upsert Profile Metadata | Profile JSON object | Status 201 Created | Yes (Bearer JWT) | `supabase_service.dart:145` |
| `GET` | `/rest/v1/listings` | Fetch Marketplace Crops | Query: `?order=created_at.desc` | Array of listing objects | Public (Active listings) | `supabase_service.dart:356` |
| `POST` | `/rest/v1/listings` | Publish Produce Listing | Listing JSON object | Status 201 Created | Yes (Farmer UID matching) | `supabase_service.dart:430` |
| `DELETE` | `/rest/v1/listings` | Delete Crop Listing | Query: `?id=eq.LST_ID` | Status 204 No Content | Yes (Farmer UID matching) | `supabase_service.dart:493` |
| `GET` | `/rest/v1/prices` | Fetch Mandi Price Cache | Query: `?order=created_at.desc` | Array of Mandi prices | Public Read | `supabase_service.dart:580` |
| `POST` | `/rest/v1/prices` | Upsert APMC Live Rates | Array of Mandi price objects | Status 201 Created | Public / Service Key | `supabase_service.dart:641` |
| `POST` | `/storage/v1/object/produce-images` | Upload Produce Photo | Binary image bytes | Storage path / Public URL | Public / Authenticated | `supabase_service.dart:467` |
| `POST` | `/rest/v1/rpc/delete_user_account` | Complete Account Deletion | Stored procedure execution | Status 200 OK | Yes (Current User UID) | `supabase_service.dart:523` |

---

### 8.2 External Third-Party APIs

| Service | Endpoint | Purpose | Request Format | Response Format | Source File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Google Gemini AI** | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=[KEY]` | Visual Crop Quality Grading | JSON `{ contents: [{ parts: [ { text }, { inline_data: { mime_type, data: base64 } } ] }] }` | JSON `{ candidates: [{ content: { parts: [{ text: "{\"grade\":\"Grade A\",...}" }] } }] }` | `ai_service.dart:104` |
| **Data.gov.in (Agmarknet)** | `https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=[KEY]&format=json&limit=100` | Real-time APMC Mandi Market Feeds | HTTP GET with Query Params | JSON `{ records: [ { commodity, market, district, min_price, modal_price, max_price, arrival_date } ] }` | `price_service.dart:74`, `sync_mandi_prices.js:19` |

---

## 9. API KEYS AND CONFIGURATION VARIABLES

| Variable / Key Name | Stored In File | Frontend-Visible or Backend-Only | Purpose | Security Analysis & Best Practice |
| :--- | :--- | :--- | :--- | :--- |
| `geminiApiKey` | `lib/config/api_keys.dart` | Client-Side App Code | Authenticates requests to Google Gemini 2.5 Flash Vision AI | *Observation:* Configured directly in client code for hackathon demonstration speed. In enterprise production, this should be routed through a backend proxy or Cloud Function to prevent client extraction. |
| `supabaseUrl` | `lib/config/supabase_config.dart` | Client-Side App Code | Points client to the cloud Supabase PostgreSQL instance | Safe for client inclusion; database operations are protected by Row Level Security (RLS) policies. |
| `supabaseAnonKey` | `lib/config/supabase_config.dart` | Client-Side App Code | Public publishable API key for Supabase PostgREST | Safe for client inclusion; only grants permissions permitted by active RLS policies. |
| `_dataGovApiKey` | `lib/services/price_service.dart` | Client-Side App Code | Accesses Agmarknet open data portal on Data.gov.in | Public Open Data API key with rate limits; safe for read-only benchmark fetching. |

---

## 10. FRONTEND DEEP DIVE

### 10.1 UI Component Tree & Screen Hierarchy

```text
AgroMitraApp (main.dart)
 └── MaterialApp
      └── LanguageScreen (Entry: Select English / Hindi / Marathi)
           └── LandingScreen (Role Selector)
                ├── [Farmer Path]
                │    ├── FarmerLoginScreen / FarmerSignupScreen
                │    └── FarmerMainNav (BottomNavigationBar with 5 Tabs)
                │         ├── Tab 0: FarmerHomeScreen
                │         │    ├── MandiHighlightHeroCard (Live rate banner)
                │         │    ├── QuickActionsGrid (Sell, Prices, Schemes, Listings)
                │         │    ├── RecentListingsCarousel
                │         │    └── NewsAndAdvisorySection
                │         ├── Tab 1: MandiPricesScreen
                │         │    ├── SearchBarWidget & District Filter Chips
                │         │    ├── MandiPriceCard (Min, Modal, Max rates)
                │         │    └── 7-Day Trend Modal
                │         ├── Tab 2: SellProduceScreen (3-Step Wizard)
                │         │    ├── Step 1: Commodity Selection & Quantity
                │         │    ├── Step 2: ImagePicker (Camera/Gallery) + Gemini AI Grading
                │         │    └── Step 3: APMC Formula Pricing & Middleman Savings Calculation
                │         ├── Tab 3: SchemesListScreen
                │         │    └── SchemeDetailsScreen (PM-KISAN, PMFBY, etc.)
                │         └── Tab 4: FarmerProfileScreen
                │              ├── Profile Info & Language Switcher
                │              ├── MyListingsScreen (Inventory & Mark as Sold)
                │              └── DeleteAccountDialog (RPC Account Cleanup)
                │
                ├── [Buyer Path]
                │    ├── BuyerLoginScreen / BuyerSignupScreen
                │    └── BuyerMainNav (BottomNavigationBar with 4 Tabs)
                │         ├── Tab 0: BuyerHomeScreen
                │         │    ├── Live Mandi Ticker
                │         │    ├── Category Filter Chips (Vegetables, Fruits, Grains)
                │         │    └── Fresh Listings Feed
                │         ├── Tab 1: BuyerSearchScreen
                │         │    ├── Real-time search query filter
                │         │    └── ListingCard Grid
                │         ├── Tab 2: SchemesListScreen
                │         └── Tab 3: BuyerProfileScreen
                │
                └── [Admin Path]
                     ├── AdminLoginScreen (Pass: admin123 / agromitra2026)
                     └── AdminDashboardScreen (System health metrics & listings moderation)
```

---

### 10.2 State Management: The `AppState` Reactive Core
The application avoids third-party state bloat (e.g., Redux, Bloc, Riverpod) by utilizing Flutter's built-in **`ChangeNotifier`** pattern in `lib/services/app_state.dart`.

- **Singleton / Top-Level Instance:** `_AgroMitraAppState` creates a single `AppState` instance passed down the widget tree.
- **Subscriptions:** Screens attach `_appState.addListener(_onAppStateChanged)` in `initState()` and detach in `dispose()`.
- **Reactive Mutations:** Whenever a listing is created, deleted, or prices refresh, `AppState` executes `notifyListeners()`, which forces all active screens to re-render with fresh data without requiring page reloads.

---

## 11. BACKEND DEEP DIVE (SUPABASE ARCHITECTURE)

### 11.1 Backend Service Layer (`supabase_service.dart`)
`SupabaseService` is a static service abstraction layer acting as the single gateway between the Flutter client and the Supabase Cloud backend.

```text
Flutter Screen / Widget
       ↓
AppState Action (e.g., addListing)
       ↓
SupabaseService (Static API Interface)
       ↓ Check SupabaseConfig.isConfigured
   ┌───┴───────────────────────────────┐
   │ (If Online & Connected)           │ (If Offline / Fallback)
   ▼                                   ▼
Supabase Client (PostgREST / Auth)   Local In-Memory DB (_localUsersDb / _localListings)
   │ HTTPS REST / Bearer JWT           │ Instant Synchronous Response
   ▼                                   ▼
Supabase Cloud (PostgreSQL 15)       AppState Updates UI
```

---

## 12. DATABASE DEEP DIVE (POSTGRESQL SCHEMA & RLS)

The complete relational schema is defined in `Agromitra/supabase_schema.sql`.

### 12.1 Tables & Schema Breakdown

```text
┌───────────────────────────────┐         ┌───────────────────────────────┐
│       auth.users (System)     │         │       public.prices           │
├───────────────────────────────┤         ├───────────────────────────────┤
│ id (UUID, PK)                 │         │ id (TEXT, PK)                 │
│ email (TEXT)                  │         │ commodity (TEXT)              │
│ encrypted_password            │         │ market (TEXT)                 │
└───────────────┬───────────────┘         │ min_price (NUMERIC)           │
                │ 1:1                     │ modal_price (NUMERIC)         │
                ▼                         │ max_price (NUMERIC)           │
┌───────────────────────────────┐         │ date (DATE)                   │
│       public.profiles         │         │ source (TEXT)                 │
├───────────────────────────────┤         │ is_live (BOOLEAN)             │
│ id (UUID, PK, FK auth.users)  │         └───────────────────────────────┘
│ name (TEXT)                   │
│ phone (TEXT)                  │         ┌───────────────────────────────┐
│ role (TEXT: farmer/buyer/admin│         │       public.schemes          │
│ village (TEXT)                │         ├───────────────────────────────┤
│ taluka (TEXT)                 │         │ id (TEXT, PK)                 │
│ district (TEXT)               │         │ name (TEXT)                   │
│ language (TEXT)               │         │ description (TEXT)            │
│ contact_enabled (BOOLEAN)     │         │ eligibility (TEXT)            │
│ seller_status (TEXT)          │         │ benefits (TEXT)               │
└───────────────┬───────────────┘         │ documents (TEXT)              │
                │ 1:N                     │ link (TEXT)                   │
                ▼                         │ category (TEXT)               │
┌───────────────────────────────┐         └───────────────────────────────┘
│       public.listings         │
├───────────────────────────────┤         ┌───────────────────────────────┐
│ id (TEXT, PK)                 │         │       public.news             │
│ farmer_id (UUID, FK profiles) │         ├───────────────────────────────┤
│ farmer_name (TEXT)            │         │ id (TEXT, PK)                 │
│ farmer_phone (TEXT)           │         │ title (TEXT)                  │
│ commodity (TEXT)              │         │ description (TEXT)            │
│ photo_urls (TEXT[])           │         │ date (DATE)                   │
│ quality_grade (TEXT)          │         │ source (TEXT)                 │
│ ai_suggestion (TEXT)          │         └───────────────────────────────┘
│ quality_confidence (NUMERIC)  │
│ ai_reason (TEXT)              │
│ mandi_benchmark_price (NUMERIC│
│ suggested_price (NUMERIC)     │
│ final_price (NUMERIC)         │
│ quantity (NUMERIC)            │
│ unit (TEXT)                   │
│ village, taluka, district     │
│ status (active/sold/archived) │
│ created_at (TIMESTAMPTZ)      │
└───────────────────────────────┘
```

---

### 12.2 Row Level Security (RLS) Policies
PostgreSQL Row Level Security ensures that database access rules are enforced at the database kernel level:
- **`public.profiles`:**
  - `SELECT`: Publicly readable (`USING (true)`).
  - `INSERT` / `UPDATE` / `DELETE`: Restricted to record owner (`auth.uid() = id`).
- **`public.listings`:**
  - `SELECT`: Active listings are readable by everyone (`USING (status = 'active' OR auth.uid() = farmer_id)`).
  - `INSERT` / `UPDATE` / `DELETE`: Only the farmer who created the listing can modify or remove it (`WITH CHECK (auth.uid() = farmer_id)`).
- **`storage.objects` (`produce-images` bucket):**
  - Public read access for crop photos.
  - Insert / Delete permissions for authenticated farmers.

---

### 12.3 Account Deletion RPC Procedure
To support privacy rights and clean data removal, `supabase_schema.sql` defines a `SECURITY DEFINER` function:
```sql
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.listings WHERE farmer_id = auth.uid();
    DELETE FROM public.profiles WHERE id = auth.uid();
    DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;
```

---

## 13. AUTHENTICATION AND AUTHORIZATION

### 13.1 Phone-Based Authentication Pattern
Indian farmers and rural traders primarily use 10-digit mobile numbers rather than email addresses. 

Because Supabase Auth natively enforces email-based identity structures, AgroMitra utilizes a **Deterministic Phone-to-Email Translation Adapter**:
```dart
// lib/services/supabase_service.dart:99
static String _phoneToEmail(String phone) {
  final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return 'user_$cleanPhone@agromitra.app';
}
```
When a user logs in with phone `9876543210` and password `kisan123`:
1. The frontend transforms the identifier to `user_9876543210@agromitra.app`.
2. Sends standard credentials to Supabase GoTrue Auth.
3. Supabase validates the hashed password and returns a JWT session.
4. The frontend fetches the profile from `public.profiles` and verifies the assigned role (`farmer` vs `buyer`).

---

## 14. ANDROID APPLICATION ARCHITECTURE

### 14.1 Native Container & Lifecycle
The Android application wrapper is configured inside `Agromitra/android/`:
- **`namespace`:** `com.example.agromitra`
- **Minimum SDK (`minSdk`):** API Level 21 (Android 5.0 Lollipop - covers >99% of active Android devices globally).
- **Target SDK (`targetSdk`):** API Level 34 (Android 14).
- **Java Compatibility:** Java Version 17 (`JavaVersion.VERSION_17`).
- **Activity Entry:** `com.example.agromitra.MainActivity` extending `FlutterActivity`.

```text
[Android OS Launcher]
       ↓
[AndroidManifest.xml]
       ↓
[MainActivity (FlutterActivity)]
       ↓ Loads Flutter Engine & Dart VM
[main.dart -> WidgetsFlutterBinding.ensureInitialized()]
       ↓
[SupabaseService.initialize()]
       ↓
[AgroMitraApp -> MaterialApp -> LanguageScreen]
```

---

## 15. ANDROID PERMISSIONS & PACKAGE VISIBILITY

All Android permissions are declared in `android/app/src/main/AndroidManifest.xml`:

| Permission / Query | Purpose | Feature Using It | Denied Fallback Behavior |
| :--- | :--- | :--- | :--- |
| `android.permission.INTERNET` | Grants socket access to communicate over the web | Gemini AI API, Supabase Cloud, Data.gov.in REST API | App activates offline cache mode |
| `android.permission.ACCESS_NETWORK_STATE` | Checks network connectivity status | Network auto-detection and graceful degradation | App defaults to cached data |
| `android.permission.CAMERA` | Access to device camera hardware | Taking live crop photographs in `SellProduceScreen` | Farmer can choose existing photos from Gallery |
| `android.permission.READ_EXTERNAL_STORAGE` | Access to device photo storage (Android <= 12) | Uploading crop photos from Gallery | Farmer can use default crop photos |
| `android.permission.READ_MEDIA_IMAGES` | Access to device photo media (Android 13+) | Uploading crop photos from Gallery on modern Android | Farmer can use default crop photos |
| `<queries> <intent android:name="android.intent.action.DIAL" />` | Package visibility for telephone dialer app | One-tap **Contact Farmer** phone dialing | Displays contact phone number directly in UI |
| `<queries> <intent android:name="android.intent.action.VIEW" />` | Package visibility for web browser & WhatsApp | Opening official government portals & WhatsApp chat | Displays URL text for user copy |

---

## 16. BUILD SYSTEM & COMPILATION

### 16.1 Development Execution
- **Run on Android Emulator / Physical Device:**
  ```bash
  flutter run -d android
  ```
- **Run in Chrome / Edge Web Browser:**
  ```bash
  flutter run -d chrome
  ```

### 16.2 Production Compilation
- **Generate Android Release APK:**
  ```bash
  flutter build apk --release
  ```
  *Output Artifact:* `build/app/outputs/flutter-apk/app-release.apk`
- **Generate Optimized Web SPA Bundle:**
  ```bash
  flutter build web --release
  ```
  *Output Artifact:* `build/web/` directory (served via `node server.js`).

---

## 17. CONFIGURATION FILES AUDIT

| File Path | Purpose | Key Configurations |
| :--- | :--- | :--- |
| `Agromitra/pubspec.yaml` | Flutter package manifest | Dart SDK `^3.13.2`, dependencies (`supabase_flutter`, `http`, `image_picker`, `url_launcher`), asset definitions |
| `Agromitra/lib/config/api_keys.dart` | Gemini AI Key configuration | `ApiKeys.geminiApiKey` string constant |
| `Agromitra/lib/config/supabase_config.dart` | Supabase endpoint configuration | `supabaseUrl`, `supabaseAnonKey`, `isConfigured` validation getter |
| `Agromitra/android/app/build.gradle.kts` | Android build configuration | `applicationId = "com.example.agromitra"`, `compileSdk = 34`, `minSdk = 21`, `JavaVersion.VERSION_17` |
| `Agromitra/android/app/src/main/AndroidManifest.xml` | Android OS manifest | App label `"AgroMitra"`, permissions, launcher intent filter, query filters |
| `Agromitra/supabase_schema.sql` | PostgreSQL database script | 5 core tables, RLS policies, storage bucket config, and seed data |
| `Agromitra/server.js` | Web preview static server | Ports `[5000, 8080, 3000]`, SPA HTML fallback, MIME type dictionary |

---

## 18. IMPORTANT FILES WE MUST STUDY

### Tier 1 — MUST KNOW (Core Presentation & Judging Defense)
1. **[`lib/services/app_state.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/services/app_state.dart):** Central nervous system of the app. Manages user authentication state, produces reactive UI updates, orchestrates listing publishing, and handles mandi price refresh.
2. **[`lib/services/ai_service.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/services/ai_service.dart):** Multimodal Gemini 2.5 Flash Vision integration. Judges will ask how AI grading works, how Base64 images are sent, and what happens if API quota runs out.
3. **[`lib/services/price_service.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/services/price_service.dart):** 3-tier Mandi price discovery engine. Implements Data.gov.in Agmarknet API integration, Supabase syncing, and offline caching.
4. **[`lib/services/supabase_service.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/services/supabase_service.dart):** Cloud backend service layer handling Supabase Auth, PostgreSQL CRUD queries, image storage uploads, and offline memory caching.
5. **[`lib/screens/farmer/sell_produce_screen.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/screens/farmer/sell_produce_screen.dart):** The primary user workflow demonstrating camera capture, AI analysis, APMC formula pricing, and listing creation.
6. **[`Agromitra/supabase_schema.sql`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/supabase_schema.sql):** Database architecture, Row Level Security policies, foreign keys, and stored procedures.

### Tier 2 — SHOULD KNOW (Supporting Architecture)
1. **[`lib/utils/price_logic.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/utils/price_logic.dart):** Transparent pricing formulas, unit conversions (Quintal/Ton/Crate to Kg), and middleman commission savings calculation.
2. **[`lib/screens/buyer/buyer_listing_details_screen.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/screens/buyer/buyer_listing_details_screen.dart):** Demonstrates buyer price comparison against Mandi rates and one-tap telephony dialing (`url_launcher`).
3. **[`lib/utils/app_strings.dart`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/utils/app_strings.dart):** Trilingual localization dictionary (English, Hindi, Marathi).
4. **[`scripts/sync_mandi_prices.js`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/scripts/sync_mandi_prices.js):** Background cron script automating daily Agmarknet data ingestion into Supabase.

### Tier 3 — LOW PRIORITY (Boilerplate & Standard UI)
1. `lib/widgets/*`: Reusable cards, text fields, and buttons.
2. `lib/models/*`: Standard Dart DTO class definitions.
3. `android/app/src/main/kotlin/.../MainActivity.kt`: Standard FlutterActivity wrapper.

---

## 19. IMPORTANT CODE WE MUST STUDY

### 1. Gemini AI Multimodal Vision Request
- **File:** `lib/services/ai_service.dart`
- **Function:** `AIService.analyzeProduceQuality()`
- **Input:** `String commodity`, `List<String> photoUrls`, `List<Uint8List> imageBytesList`
- **Processing:** Encodes image bytes to Base64, crafts strict JSON-only agricultural prompt, and dispatches HTTP POST to Gemini 2.5 Flash.
- **Output:** `Future<AIResult>` containing `grade`, `confidence` (0-100), and `reason`.
- **Why Judges Will Ask:** Judges want to verify whether the AI is real or mocked, and how multimodal image payloads are constructed.

---

### 2. 3-Tier Price Discovery Fallback Algorithm
- **File:** `lib/services/price_service.dart`
- **Function:** `PriceService.fetchLiveMandiPrices()`
- **Input:** `bool forceRefresh`
- **Processing:**
  1. Attempts HTTP GET to Data.gov.in Agmarknet API (3-second timeout).
  2. If failed, queries Supabase `public.prices` PostgreSQL table.
  3. If failed, loads local Maharashtra APMC benchmark cache from `MockDataService`.
- **Output:** `List<MandiPrice>`
- **Why Judges Will Ask:** Demonstrates production-grade resilience against third-party API downtime.

---

### 3. Transparent Middleman Commission Savings Logic
- **File:** `lib/utils/price_logic.dart`
- **Function:** `PriceLogic.calculateMiddlemanSavings()`
- **Input:** `double pricePerKg`, `double quantity`, `String unit`
- **Processing:** Normalizes quantity to kilograms, calculates gross transaction revenue, and computes standard 10% APMC broker commission avoided through direct trade.
- **Output:** `double` (savings amount in Indian Rupees ₹).

---

## 20. CODE EXPLANATION FOR BEGINNERS

### How a Farmer Sells Produce: Step-by-Step
```text
1. Farmer selects "Tomato" & enters "20 Quintal"
        ↓
2. Farmer takes a photo with camera
   (image_picker captures bytes)
        ↓
3. Farmer taps "Analyze with AI"
   (ai_service.dart sends image to Gemini)
        ↓
4. Gemini replies: "Grade A, 92% confidence"
   (Screen displays Green Grade A Badge)
        ↓
5. App fetches Mandi Price for Tomato (₹24.00/kg)
   (price_service.dart looks up APMC rate)
        ↓
6. App suggests fair price ₹24.00 - ₹26.40/kg
   (Farmer sets asking price: ₹26.00/kg)
        ↓
7. Farmer taps "Publish Listing"
   (supabase_service.dart uploads image & writes to PostgreSQL database)
        ↓
8. Listing immediately appears on Buyer's screen across India!
```

---

## 21. AI / ML IMPLEMENTATION DEEP DIVE

- **Provider:** Google AI Studio / Google Generative Language API.
- **Model:** `gemini-2.5-flash` (with automated fallback to `gemini-1.5-flash`).
- **Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`.
- **Prompt Architecture:**
  ```text
  You are an expert Indian agricultural produce quality inspector.
  Analyze the provided produce images and return ONLY valid JSON.
  Evaluate only visible quality.
  Return this exact JSON format:
  {
    "grade": "Grade A",
    "confidence": 92,
    "reason": "Bright uniform color, firm texture, minimal skin blemishes."
  }
  Grade options:
  - "Grade A": Excellent visual quality, premium market price
  - "Grade B": Good average visual quality, standard market price
  - "Grade C": Fair quality / minor defects, discount market price
  No markdown ticks. No other text. JSON only.
  ```
- **Temperature:** `0.2` (Low temperature enforces deterministic, factual, and strictly formatted outputs).
- **Graceful Degradation:** If the device is offline or the API key hits rate limits, `AIResult.fallbackForCommodity(commodity)` provides realistic commodity-specific quality parameters so the user flow is never interrupted.

---

## 22. EXTERNAL SERVICES AUDIT

| External Service | Provider | Purpose | Where Configured | Data Sent | Data Received |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Google Gemini API** | Google Cloud | Multimodal Crop Grading | `lib/config/api_keys.dart` | Commodity name + Base64 image bytes | Grade (A/B/C), Confidence %, Freshness description |
| **Supabase Cloud** | Supabase Inc. / AWS | Auth, PostgreSQL DB, File Storage | `lib/config/supabase_config.dart` | User credentials, listings data, crop photos | JWT session tokens, listing records, image URLs |
| **Data.gov.in API** | Govt of India / NIC | Daily APMC Mandi commodity rates | `lib/services/price_service.dart` | API Key + Resource ID | Real-time APMC commodity price records |
| **WhatsApp Web / App** | Meta | Farmer-Buyer Direct Communication | `buyer_listing_details_screen.dart` | Pre-formatted crop purchase message | Opens native WhatsApp chat |
| **Govt Scheme Portals** | Ministry of Agriculture | Official farmer welfare applications | `schemes_list_screen.dart` | None (Direct URL navigation) | Opens official `.gov.in` websites in browser |

---

## 23. SECURITY ARCHITECTURE AUDIT

### 23.1 Implemented Security Features
1. **Row Level Security (RLS):** Database access is restricted at the PostgreSQL engine level; farmers can only mutate their own listings.
2. **Password Security:** Passwords are never stored in plaintext; Supabase GoTrue utilizes `bcrypt` hashing with salt rounds.
3. **Database Input Validation:** PostgreSQL constraints enforce role validation (`CHECK (role IN ('farmer', 'buyer', 'admin'))`) and status validation (`CHECK (status IN ('active', 'sold', 'archived'))`).
4. **Client Image Size Capping:** Strict 10 MB payload limit enforced in `SellProduceScreen` before memory buffering or network dispatch.
5. **Secure Account Purge:** Stored procedure `delete_user_account()` executes under `SECURITY DEFINER` privileges to cleanly remove user data across tables.

### 23.2 Identified Weaknesses & Production Recommendations (For Hackathon Honesty)
1. **Client-Side API Key Storage:** The Gemini API key and Data.gov.in key are declared in Dart constants. *Production Recommendation:* Route through Supabase Edge Functions.
2. **Demo Admin Password:** Admin login allows predefined bypass credentials (`admin123`). *Production Recommendation:* Enforce dedicated multi-factor authentication (MFA) for administrative roles.

---

## 24. ERROR HANDLING & RESILIENCE MATRIX

| Failure Scenario | Where Handled | System Response & User Experience |
| :--- | :--- | :--- |
| **Gemini AI API Fails / Offline** | `lib/services/ai_service.dart:135` | Catches timeout/exception, logs diagnostic notice, and triggers `AIResult.fallbackForCommodity()`. Farmer receives realistic grading without blocking. |
| **Data.gov.in API Down** | `lib/services/price_service.dart:134` | Catches timeout after 3 seconds and seamlessly falls back to Supabase `prices` table, then to local APMC benchmark cache. |
| **Supabase Cloud Disconnected** | `lib/services/supabase_service.dart:67` | Operates in validated local mode using `_localUsersDb` and `_localListings`. Enforces password matching in memory. |
| **Image Size Exceeds 10 MB** | `lib/screens/farmer/sell_produce_screen.dart:117` | Intercepts photo upload, displays Red SnackBar warning, and rejects oversized file. |
| **Network Loss on Submit** | `lib/screens/farmer/sell_produce_screen.dart:213` | Catches network exception, resets `_isPublishing = false`, and displays clear error message to farmer. |

---

## 25. PERFORMANCE & OPTIMIZATION

- **Image Compression:** `image_picker` automatically downsizes captured photos to `maxWidth: 1600`, `maxHeight: 1600`, `imageQuality: 85` prior to transmission.
- **Microsecond In-Memory Filtering:** Commodity and district searches filter cached arrays in memory using Dart's optimized `.where()` iterator.
- **Fast Image Rendering:** `ProduceImageView` checks whether an image URL is a web link, Base64 data URI, or asset path, preventing image decoding stutter.
- **Non-Blocking Background Tasks:** Mandi price synchronization runs asynchronously via `unawaited` futures so app startup is instantaneous.

---

## 26. DEPLOYMENT ARCHITECTURE

### 26.1 Local & Demo Deployment
- **Web App:** Compiles to static HTML/JS bundle in `build/web/` and served via Node.js server (`Agromitra/server.js`) on `http://localhost:8080`.
- **Android App:** Built via `flutter build apk --release` and installed directly onto physical Android devices or emulators via `adb install`.

### 26.2 Production Cloud Architecture (Target State)
- **Frontend Hosting:** Vercel / Firebase Hosting / Cloudflare Pages for Flutter Web SPA.
- **Mobile Distribution:** Google Play Store APK / Android App Bundle (AAB).
- **Backend & Database:** Managed Supabase Cloud (AWS Mumbai region `ap-south-1` for low-latency Indian edge access).
- **Background Cron:** GitHub Actions or Supabase Scheduled Edge Functions running `sync_mandi_prices.js` daily at 06:00 AM IST.

---

## 27. COMPLETE REQUEST-RESPONSE EXAMPLES

### Example 1: Gemini AI Multimodal Inspection Request & Response
**Request URL:**
```http
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=[REDACTED]
Content-Type: application/json
```
**Request Body:**
```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "Commodity: Tomato\n\nYou are an expert Indian agricultural produce quality inspector...\nReturn this exact JSON format:\n{\n  \"grade\": \"Grade A\",\n  \"confidence\": 92,\n  \"reason\": \"...\"\n}"
        },
        {
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": "/9j/4AAQSkZJRgABAQEASABIAAD/2wBD..."
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.2,
    "responseMimeType": "application/json"
  }
}
```
**Response Body (Status 200 OK):**
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "{\n  \"grade\": \"Grade A\",\n  \"confidence\": 94,\n  \"reason\": \"Uniform deep crimson hue, smooth skin with zero cracking, firm texture suitable for commercial long-distance transport.\"\n}"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

---

### Example 2: Data.gov.in Agmarknet Market Records
**Request URL:**
```http
GET https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=[REDACTED]&format=json&limit=2
```
**Response Body (Status 200 OK):**
```json
{
  "status": "ok",
  "total": 2,
  "records": [
    {
      "state": "Maharashtra",
      "district": "Thane",
      "market": "Vashi APMC (Navi Mumbai)",
      "commodity": "Tomato",
      "variety": "Hybrid",
      "arrival_date": "05/09/2026",
      "min_price": "1800",
      "max_price": "3000",
      "modal_price": "2400"
    }
  ]
}
```

---

## 28. HACKATHON JUDGE QUESTIONS & DEFENSE MATRIX

### 1. Basic & Problem Statement Questions
- **Q: What is the core problem AgroMitra solves?**  
  *Short Answer:* It solves price exploitation and lack of transparent quality grading for Indian farmers by connecting them directly with buyers using real-time APMC Mandi rates and AI vision grading.  
  *Technical Explanation:* Farmers typically sell to local middlemen without knowing that terminal mandis (e.g., Vashi APMC) are trading at higher rates. AgroMitra provides APMC price transparency, AI-assisted quality verification, and one-tap direct contact to eliminate the 8–12% broker commission.  
  *File Reference:* `README.md`, `lib/utils/price_logic.dart`.

- **Q: Who are the target users?**  
  *Short Answer:* Small and marginal farmers (*Kisans*), commercial produce buyers (*Vyaparis*, wholesalers, retailers), and agricultural cooperatives.  
  *File Reference:* `lib/models/profile.dart`.

---

### 2. Architecture & Technical Choices
- **Q: Why did you choose Flutter instead of React Native or native Kotlin?**  
  *Short Answer:* Flutter provides single-codebase compilation for native high-performance Android APKs and Web SPAs with consistent Material Design 3 UI and zero bridge serialization overhead.  
  *Technical Explanation:* Flutter compiles directly to native ARM machine code on Android and WebAssembly/CanvasKit on Web, giving smooth 60fps animations on budget Android devices used by farmers.  
  *File Reference:* `Agromitra/pubspec.yaml`, `Agromitra/android/`.

- **Q: Why Supabase instead of Firebase?**  
  *Short Answer:* Supabase provides a full PostgreSQL relational database with SQL constraints and Row Level Security (RLS), which is superior for structured relational data like crop listings, user profiles, and APMC market prices.  
  *Technical Explanation:* Agricultural marketplaces require relational integrity (e.g., foreign keys linking listings to farmer profiles with cascade deletion). Firebase Firestore NoSQL makes complex relational joins and ACID constraints difficult.  
  *File Reference:* `Agromitra/supabase_schema.sql`.

---

### 3. AI & Computer Vision Questions
- **Q: Is the AI visual grading real or hardcoded?**  
  *Short Answer:* It is a real integration with Google Gemini 2.5 Flash Vision that converts live camera photos into Base64 payloads and sends them to Gemini for JSON quality grading, with a deterministic offline fallback if the API key or internet fails.  
  *Technical Explanation:* `AIService.analyzeProduceQuality()` serializes image bytes into `inline_data` JPEG parts, passes a system prompt constraining the output to JSON, and parses the returned `grade`, `confidence`, and `reason`.  
  *File Reference:* `lib/services/ai_service.dart:18-137`.

- **Q: Why use Gemini Flash instead of training a custom YOLO or CNN model?**  
  *Short Answer:* Gemini 2.5 Flash has multimodal zero-shot reasoning capable of inspecting diverse produce types (Tomatoes, Onions, Cotton, Pomegranates) without requiring gigabytes of trained model weights stored on the farmer's mobile phone.  
  *Technical Explanation:* An on-device CNN model for 15+ agricultural commodities would increase APK size by 100MB+ and struggle with lighting variations in rural fields. Gemini Flash delivers sub-second inference with rich natural language reasoning.  
  *File Reference:* `lib/services/ai_service.dart`.

---

### 4. Database & Security Questions
- **Q: How do you prevent a malicious buyer from editing or deleting a farmer's listing?**  
  *Short Answer:* Through PostgreSQL Row Level Security (RLS) policies that verify `auth.uid() = farmer_id` at the database level.  
  *Technical Explanation:* Even if a malicious user crafts a direct REST API call to modify a listing, Supabase's PostgreSQL engine evaluates the active JWT token against the policy `CREATE POLICY ... FOR UPDATE USING (auth.uid() = farmer_id)` and rejects unauthorized requests with HTTP 403 Forbidden.  
  *File Reference:* `supabase_schema.sql:113-128`.

- **Q: How is user privacy protected regarding phone numbers and exact field locations?**  
  *Short Answer:* Only high-level administrative geography (Village, Taluka, District) is displayed on public listing cards. Precise GPS coordinates are never exposed, and contact is initiated through the user's native phone dialer with user confirmation.  
  *File Reference:* `lib/models/listing.dart:52`, `lib/screens/buyer/buyer_listing_details_screen.dart:77`.

---

### 5. Offline & Reliability Questions
- **Q: What happens if there is no internet connection in a rural village?**  
  *Short Answer:* The application employs an offline-first 3-tier architecture. It serves cached APMC benchmarks, executes rule-based quality estimations, and buffers listings locally in memory.  
  *Technical Explanation:* `PriceService` and `SupabaseService` encapsulate try-catch blocks with graceful fallbacks. If network sockets fail, the UI falls back seamlessly to `MockDataService` so the farmer is never faced with a crashed or frozen application.  
  *File Reference:* `lib/services/price_service.dart:66-149`, `lib/services/supabase_service.dart:199-230`.

---

## 29. RAPID-FIRE QUESTIONS & ANSWERS (30+ CHEAT SHEET)

1. **Q: What framework is used for the frontend?**  
   *A:* Flutter (Dart 3) with Material Design 3.
2. **Q: What is the primary backend?**  
   *A:* Supabase (PostgreSQL 15 with GoTrue Auth and Storage).
3. **Q: What AI model grades crop quality?**  
   *A:* Google Gemini 2.5 Flash Vision (`gemini-2.5-flash`).
4. **Q: Where does live Mandi market data come from?**  
   *A:* Data.gov.in Agmarknet Open Data API.
5. **Q: What languages are supported?**  
   *A:* English, हिन्दी (Hindi), and मराठी (Marathi).
6. **Q: How does the farmer contact a buyer?**  
   *A:* One-tap phone dialer (`tel:` intent) or WhatsApp direct message via `url_launcher`.
7. **Q: How is state managed?**  
   *A:* `ChangeNotifier` pattern inside `lib/services/app_state.dart`.
8. **Q: What is the formula for suggested crop price?**  
   *A:* $\text{Suggested Price} = \text{Mandi Modal Price} \times \text{Quality Factor}$.
9. **Q: What is the maximum allowed image size?**  
   *A:* 10 MB per photo (enforced in `SellProduceScreen`).
10. **Q: How many crop photos can be uploaded per listing?**  
    *A:* Up to 3 high-resolution photos.
11. **Q: How are passwords secured?**  
    *A:* Encrypted with `bcrypt` salt hashing by Supabase GoTrue Auth.
12. **Q: How are farmers authenticated without email?**  
    *A:* Using a phone-to-email adapter (`user_[phone]@agromitra.app`).
13. **Q: What database engine is used?**  
    *A:* PostgreSQL 15+.
14. **Q: What security mechanism protects database rows?**  
    *A:* PostgreSQL Row Level Security (RLS) policies.
15. **Q: What happens if the Gemini AI API key expires?**  
    *A:* Automatic fallback to `AIResult.fallbackForCommodity()`.
16. **Q: What happens if Data.gov.in is down?**  
    *A:* Automatic fallback to Supabase `prices` table and local APMC cache.
17. **Q: What is the minimum Android SDK version?**  
    *A:* API Level 21 (Android 5.0 Lollipop).
18. **Q: What is the target Android SDK version?**  
    *A:* API Level 34 (Android 14).
19. **Q: How is the web version served locally?**  
    *A:* Via `server.js` running on Node.js ports 5000, 8080, and 3000.
20. **Q: What is the purpose of `sync_mandi_prices.js`?**  
    *A:* Automated daily ingestion script pulling Agmarknet rates into Supabase.
21. **Q: Where is the Gemini API key stored?**  
    *A:* `lib/config/api_keys.dart`.
22. **Q: Where is Supabase configured?**  
    *A:* `lib/config/supabase_config.dart`.
23. **Q: What table stores crop listings?**  
    *A:* `public.listings`.
24. **Q: What table stores user profiles?**  
    *A:* `public.profiles`.
25. **Q: What storage bucket holds crop images?**  
    *A:* `produce-images` bucket on Supabase Storage.
26. **Q: How are listings sorted?**  
    *A:* Chronologically descending (`ORDER BY created_at DESC`).
27. **Q: What government schemes are included?**  
    *A:* PM-KISAN, PMFBY (Crop Insurance), eNAM, KCC, and PM-KUSUM (Solar Pumps).
28. **Q: Can a farmer mark produce as sold?**  
    *A:* Yes, via `MyListingsScreen` by updating `status` to `sold`.
29. **Q: How does the Admin portal work?**  
    *A:* Password-protected dashboard in `admin_dashboard_screen.dart` displaying analytics and listings moderation.
30. **Q: What are the middleman commission savings?**  
    *A:* An estimated 10% gross savings returned directly to the farmer's pocket.

---

## 30. "EXPLAIN OUR PROJECT IN 60 SECONDS" (ELEVATOR PITCH)

> *"Judges, smallholder farmers in India lose up to 15% of their hard-earned income to middlemen simply because they lack real-time market price visibility and objective quality grading. We built **AgroMitra** to solve this.*
>
> *AgroMitra is a cross-platform mobile and web application built on **Flutter**, backed by **Supabase PostgreSQL**, and powered by **Google Gemini 2.5 Flash Vision AI**.*
>
> *When a farmer harvests a crop, they take a photo. Gemini Vision AI inspects visual quality in real-time, assigning a Grade A, B, or C with a confidence score. AgroMitra matches this with live APMC Mandi rates from **Data.gov.in** to calculate a fair, transparent asking price. The farmer publishes the listing, and verified buyers can browse, compare prices with local Mandis, and connect directly via one-tap phone calls or WhatsApp.*
>
> *With full tri-lingual support in English, Hindi, and Marathi, and a resilient 3-tier offline architecture, AgroMitra empowers farmers to know their market and sell with confidence."*

---

## 31. "EXPLAIN OUR ARCHITECTURE ON A WHITEBOARD"

### Whiteboard Diagram to Draw:
```text
  [ FARMER / BUYER APP ]  ── (Flutter / Dart / Material 3)
           │
           ├─── Camera / Gallery  ──► [ Google Gemini 2.5 Flash Vision AI ]
           │                                 (Visual Grading: Grade A/B/C)
           │
           ├─── REST HTTPS        ──► [ Supabase Cloud Backend ]
           │                                 ├── GoTrue Auth (Phone-based)
           │                                 ├── PostgreSQL 15 (RLS Secured)
           │                                 └── Storage ('produce-images')
           │
           └─── Open Data API     ──► [ Data.gov.in / Agmarknet ]
                                             (Daily Mandi Benchmark Prices)
```

### Verbal Explanation (1-2 minutes):
1. **Client Layer:** Highlight that the user interacts with a single Flutter codebase that compiles to Android APK and Web.
2. **AI Inspection Branch:** Explain that crop photos are sent directly to Gemini Flash Vision for sub-second grading, returning structured quality grades.
3. **Backend & Security Branch:** Explain that Supabase provides PostgreSQL storage with kernel-level Row Level Security so farmers own and protect their listing data.
4. **Market Ingestion Branch:** Point to the Data.gov.in feed that provides real-time market grounding, ensuring prices reflect genuine Maharashtra APMC benchmarks.

---

## 32. "IF THE JUDGE POINTS AT THIS FILE..." CHEAT SHEET

- **`lib/main.dart`:** *"This is the application root. It initializes Flutter bindings, connects to Supabase, applies our Material 3 green agricultural theme, and launches the tri-lingual `LanguageScreen`."*
- **`lib/services/app_state.dart`:** *"This is our central reactive state manager using `ChangeNotifier`. It coordinates auth sessions, produce listings, mandi price caching, and notifies all UI screens when data changes."*
- **`lib/services/ai_service.dart`:** *"This integrates Google Gemini 2.5 Flash Vision. It converts camera image bytes to Base64, executes multimodal quality grading, and provides an offline fallback if internet drops."*
- **`lib/services/price_service.dart`:** *"This manages our 3-tier APMC price discovery system, querying Data.gov.in, Supabase, and local Maharashtra market caches."*
- **`lib/services/supabase_service.dart`:** *"This is our static backend client. It handles user signup/login with phone numbers, manages PostgreSQL queries, and uploads crop images to cloud storage."*
- **`Agromitra/supabase_schema.sql`:** *"This is our database DDL defining our 5 tables, Row Level Security policies, foreign keys with cascade deletions, and the `delete_user_account` stored procedure."*
- **`android/app/src/main/AndroidManifest.xml`:** *"This declares our native Android configuration, permissions for Camera, Storage, and Internet, and telephony intent queries for the one-tap dialer."*

---

## 33. TECHNICAL VOCABULARY GLOSSARY

- **APMC (Agricultural Produce Market Committee):** State-administered marketing boards in India operating agricultural wholesale markets (*mandis*).
- **Modal Price:** The most frequently occurring transaction price in a Mandi on a given trading day (more representative than simple average).
- **Multimodal AI:** An artificial intelligence model capable of processing multiple data modalities simultaneously (e.g., analyzing images alongside text prompts).
- **Row Level Security (RLS):** A database security mechanism in PostgreSQL where database access is restricted at the row level based on the executing user's authentication context.
- **DTO (Data Transfer Object):** An object that carries data between processes (e.g., `ProduceListing`, `MandiPrice`, `AIResult`).
- **ChangeNotifier:** A Flutter class that provides change notification to its listeners, forming the basis of lightweight reactive state management.
- **Package Visibility (`<queries>`):** Android 11+ security requirement where apps must declare external application intents (like `tel:` or `https:`) in their manifest before launching them.

---

## 34. "DO NOT SAY THIS TO THE JUDGE" (PITFALLS & CORRECTIONS)

| ❌ What NOT to Say | ✅ What You SHOULD Say | Why |
| :--- | :--- | :--- |
| *"The app automatically connects to every bank in India."* | *"We provide direct links and eligibility guidelines for official portals like PM-KISAN and KCC."* | Prevents overpromising fintech features that aren't in scope. |
| *"We trained our own deep learning neural network from scratch."* | *"We integrated Google Gemini 2.5 Flash Vision using custom system prompt constraints and multimodal Base64 image payloads."* | Accurately describes the implementation without exaggerating. |
| *"The database has no security because it's just a hackathon."* | *"We implemented PostgreSQL Row Level Security (RLS) policies ensuring users can only modify their own listings."* | Demonstrates genuine architectural competence. |
| *"It only works if you have 5G internet."* | *"The app is designed with a 3-tier offline-first architecture that gracefully degrades to cached data if connectivity is lost."* | Shows awareness of rural deployment realities. |

---

## 35. TECHNICAL WEAKNESSES & HONEST DEFENSE

If a judge identifies a technical limitation, acknowledge it professionally and explain the production roadmap:

1. **Weakness: API Keys in Client Source Code**
   - *Judge Critique:* *"Your Gemini API key is visible in `api_keys.dart`."*
   - *Defense:* *"Yes, for the hackathon prototype, we configured the key client-side for rapid development and demonstration reliability. For our production roadmap, all AI requests will route through a Supabase Edge Function to keep keys secure on the server."*

2. **Weakness: Phone Authentication Uses Pseudo-Email Adapter**
   - *Judge Critique:* *"You are converting phone numbers to `@agromitra.app` emails."*
   - *Defense:* *"Supabase GoTrue natively manages email identities. Rather than requiring rural farmers to create emails they don't have, our client adapter bridges phone numbers seamlessly. In production, we will enable Supabase SMS OTP verification via Twilio or MSG91."*

---

## 36. FUTURE SCALABILITY ROADMAP

- **100 Users (Current Prototype):** Current Supabase free tier handles 50,000 monthly active users and 500MB database storage with zero latency bottlenecks.
- **1,000 Users (District Pilot):** Enable Redis caching for APMC Mandi feeds to minimize redundant calls to Data.gov.in.
- **10,000 Users (State-wide Maharashtra):** Enable Supabase database connection pooling (PgBouncer) and distribute crop images over a Global Content Delivery Network (Cloudflare CDN).
- **100,000 Users (National Scale):** Transition Gemini inspection to asynchronous message queues (RabbitMQ / Kafka) with batch processing for bulk harvest seasons.

---

## 37. THE AGROMITRA STORY (FOR PRESENTATIONS)

```text
    THE PROBLEM                THE AGROMITRA SOLUTION              THE IMPACT
┌─────────────────────┐        ┌───────────────────────┐        ┌─────────────────────┐
│ • Farmers uninformed│        │ 1. APMC Mandi Rates   │        │ • Fair Pricing      │
│ • Middlemen cut 10% │  ───►  │ 2. Gemini AI Grading  │  ───►  │ • Zero Commission   │
│ • Unstandard quality│        │ 3. Direct Marketplace │        │ • Higher Farm Profit│
└─────────────────────┘        └───────────────────────┘        └─────────────────────┘
```

---

## 38. FINAL HACKATHON PREPARATION CHECKLIST

### MUST MEMORIZE
- [ ] Tech stack: Flutter, Dart 3, Supabase (PostgreSQL 15), Google Gemini 2.5 Flash Vision, Data.gov.in.
- [ ] The transparent pricing formula: $\text{Suggested Price} = \text{Mandi Modal} \times \text{Quality Factor}$.
- [ ] The 3-tier fallback hierarchy: Live API $\rightarrow$ Cloud DB $\rightarrow$ Offline Local Cache.

### MUST UNDERSTAND
- [ ] How `AIService.analyzeProduceQuality()` builds multimodal JSON requests to Gemini.
- [ ] How Row Level Security (RLS) policies protect `public.listings`.
- [ ] How `AppState` manages reactive state using `ChangeNotifier`.

### CAN IGNORE DURING PRESENTATION
- [ ] Exact Gradle script build details.
- [ ] Minor CSS/styling margin definitions.
- [ ] Third-party plugin registrant boilerplate.

---

## 39. FINAL ONE-PAGE CHEAT SHEET

```text
================================================================================
                           AGROMITRA CHEAT SHEET
================================================================================
CORE THEME:        Strengthening Market Linkages & Price Discovery for Farmers
FRONTEND / MOBILE: Flutter (Dart 3) | Material Design 3 | Android & Web
BACKEND:           Supabase Cloud (PostgreSQL 15, GoTrue Auth, Storage Buckets)
AI VISION MODEL:   Google Gemini 2.5 Flash Vision (Multimodal Base64 Image JSON)
OPEN DATA SOURCE:  Data.gov.in / Agmarknet APMC Mandi API
STATE MANAGEMENT:  AppState (ChangeNotifier / Observer Pattern)

KEY WORKFLOWS:
1. Sell Flow:      Photo Capture -> Gemini AI Grade -> APMC Formula Price -> Publish
2. Discovery Flow: Search Crops -> Compare with Mandi -> One-Tap Phone / WhatsApp Dial
3. Offline Flow:   Live API -> Supabase DB -> Local In-Memory Benchmark Cache

IMPORTANT FILES:
• lib/services/app_state.dart        -> Central reactive state
• lib/services/ai_service.dart        -> Gemini AI vision inspection
• lib/services/price_service.dart     -> Mandi APMC price discovery
• lib/services/supabase_service.dart  -> Supabase auth & PostgreSQL queries
• supabase_schema.sql                 -> Database schema & RLS security policies

BIGGEST STRENGTH:  Working AI Vision + Real APMC Data + Resilient 3-Tier Fallback
================================================================================
```

---

## 40. EVIDENCE & SOURCE CODE MAPPING

| Architectural Claim | Source File Evidence & Line Numbers | Verification Status |
| :--- | :--- | :--- |
| **Flutter 3 / Dart SDK** | [`Agromitra/pubspec.yaml:21-39`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/pubspec.yaml#L21-L39) | **Confirmed** |
| **Gemini 2.5 Flash Vision Endpoint** | [`lib/services/ai_service.dart:10-14`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/services/ai_service.dart#L10-L14) | **Confirmed** |
| **Data.gov.in Agmarknet Resource ID** | [`lib/services/price_service.dart:15-18`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/services/price_service.dart#L15-L18) | **Confirmed** |
| **Supabase PostgreSQL Schema & RLS** | [`Agromitra/supabase_schema.sql:8-144`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/supabase_schema.sql#L8-L144) | **Confirmed** |
| **Native Android Manifest Permissions** | [`android/app/src/main/AndroidManifest.xml:2-7`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/android/app/src/main/AndroidManifest.xml#L2-L7) | **Confirmed** |
| **Phone Dialer & WhatsApp URL Intents** | [`lib/screens/buyer/buyer_listing_details_screen.dart:19-75`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/lib/screens/buyer/buyer_listing_details_screen.dart#L19-L75) | **Confirmed** |
| **Node.js Local SPA Web Server** | [`Agromitra/server.js:5-74`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/server.js#L5-L74) | **Confirmed** |
| **Automated Mandi Sync Script** | [`Agromitra/scripts/sync_mandi_prices.js:10-116`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/scripts/sync_mandi_prices.js#L10-L116) | **Confirmed** |
| **Account Deletion Stored Procedure** | [`Agromitra/supabase_schema.sql:175-188`](file:///c:/Users/hp/OneDrive/Desktop/Hackathonready/Agromitra/supabase_schema.sql#L175-L188) | **Confirmed** |

---
*End of Technical Reverse-Engineering Guide. Ready for Hackathon Presentation and Technical Jury Defense.*
