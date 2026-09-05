# AgroMitra — Site & Project Constitution

## 1. Project Vision
AgroMitra strengthens agricultural market linkages and empowers Indian farmers through transparent Mandi/APMC price discovery, AI-assisted produce quality grading suggestions, and direct farmer-to-buyer connections without middlemen manipulation.

## 2. Core User Flows
- **Farmer Flow:**
  Language Selection → Landing Screen → Farmer Signup/Login → Farmer Home → Mandi Benchmark Prices → Sell Produce (4 Steps: Commodity details, 3 Produce Photos, AI-assisted visual grading suggestion, Transparent price formula calculation `Modal x Multiplier`) → Publish Listing → My Listings.
- **Buyer Flow:**
  Language Selection → Landing Screen → Buyer Signup/Login → Buyer Home → Search & Filter Produce (Commodity, District, Grade) → View Listing with Mandi comparison badge → Contact Farmer via Phone Dialer Intent.
- **Government Schemes Flow:**
  Dedicated Schemes Tab → Search & Category Filter (Subsidy, Insurance, Loan, Women, Organic) → Comprehensive Details → Official Government Portal Redirection.
- **Admin Flow:**
  Separate Admin Login → Dashboard with Metrics → Seller Status Verification Moderation → Content & Seed Data Oversight.

## 3. Technology Stack
- **Frontend:** Flutter (Dart 3.x), Material Design 3
- **Styling & Theme:** Deep Green (`#2E7D32`), Leaf Green (`#66BB6A`), Golden Yellow (`#F9A825`), Soft White (`#F8FAF8`), 18–22px rounded cards, pill-shaped buttons
- **Localization:** English (EN), Hindi (HI), Marathi (MR) with centralized `app_strings.dart`
- **Future Backend Ready:** Supabase (Auth, Postgres, Storage, RLS)

## 4. Sitemap & Screen Registry
- [x] **Language Selection Screen** (`screens/language/language_screen.dart`)
- [x] **Landing / Role Selection Screen** (`screens/landing/landing_screen.dart`)
- [x] **Farmer Authentication** (`screens/auth/farmer_login_screen.dart`, `farmer_signup_screen.dart`)
- [x] **Buyer Authentication** (`screens/auth/buyer_login_screen.dart`, `buyer_signup_screen.dart`)
- [x] **Farmer Home Dashboard** (`screens/farmer/farmer_home_screen.dart`)
- [x] **Mandi Price Benchmark Screen** (`screens/farmer/mandi_prices_screen.dart`)
- [x] **Sell Produce 4-Step Wizard** (`screens/farmer/sell_produce_screen.dart`)
- [x] **My Listings & Records Screen** (`screens/farmer/my_listings_screen.dart`)
- [x] **Government Schemes Hub** (`screens/schemes/schemes_list_screen.dart`)
- [x] **Scheme Details Screen** (`screens/schemes/scheme_details_screen.dart`)
- [x] **Farmer Profile Screen** (`screens/farmer/farmer_profile_screen.dart`)
- [x] **Buyer Home Screen** (`screens/buyer/buyer_home_screen.dart`)
- [x] **Buyer Produce Search Screen** (`screens/buyer/buyer_search_screen.dart`)
- [x] **Buyer Listing Details Screen** (`screens/buyer/buyer_listing_details_screen.dart`)
- [x] **Buyer Profile Screen** (`screens/buyer/buyer_profile_screen.dart`)
- [x] **Admin Login & Dashboard** (`screens/admin/admin_login_screen.dart`, `admin_dashboard_screen.dart`)

## 5. Roadmap & Future Scope
1. Supabase Auth (phone + password) & Postgres database integration
2. Live APMC API data syncing with local caching
3. Real Vision AI model deployment for visual inspection
4. Offline SQLite sync for rural low-connectivity areas
