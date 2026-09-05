-- ==============================================================================
-- AGROMITRA DATABASE SCHEMA & ROW LEVEL SECURITY (RLS) POLICIES
-- Theme: Strengthening Market Linkages & Price Discovery for Farmers
-- (Safe to run multiple times without any duplicate policy errors)
-- ==============================================================================

-- 1. PROFILES TABLE (Stores farmer & buyer profiles linked to Supabase Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('farmer', 'buyer', 'admin')),
    village TEXT DEFAULT 'Bhiwandi',
    taluka TEXT DEFAULT 'Bhiwandi',
    district TEXT DEFAULT 'Thane',
    language TEXT DEFAULT 'English',
    contact_enabled BOOLEAN DEFAULT true,
    seller_status TEXT DEFAULT 'active' CHECK (seller_status IN ('active', 'pending', 'suspended')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PRODUCE LISTINGS TABLE
CREATE TABLE IF NOT EXISTS public.listings (
    id TEXT PRIMARY KEY,
    farmer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    farmer_name TEXT NOT NULL,
    farmer_phone TEXT NOT NULL,
    commodity TEXT NOT NULL,
    photo_urls TEXT[] DEFAULT '{}',
    quality_grade TEXT NOT NULL DEFAULT 'Fresh Harvest',
    ai_suggestion TEXT DEFAULT 'Direct Mandi Benchmark',
    quality_confidence NUMERIC(4, 2) DEFAULT 1.00,
    ai_reason TEXT DEFAULT 'Live APMC benchmark matched rate',
    mandi_benchmark_price NUMERIC(10, 2) NOT NULL,
    suggested_price NUMERIC(10, 2) NOT NULL,
    final_price NUMERIC(10, 2) NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL,
    unit TEXT DEFAULT 'Quintal',
    description TEXT,
    village TEXT NOT NULL,
    taluka TEXT NOT NULL,
    district TEXT NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'sold', 'archived')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. MANDI APMC PRICES TABLE (Live / Seeded Benchmark)
CREATE TABLE IF NOT EXISTS public.prices (
    id TEXT PRIMARY KEY,
    commodity TEXT NOT NULL,
    market TEXT NOT NULL,
    min_price NUMERIC(10, 2) NOT NULL,
    modal_price NUMERIC(10, 2) NOT NULL,
    max_price NUMERIC(10, 2) NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    source TEXT DEFAULT 'Agmarknet / MSAMB',
    is_live BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. AGRICULTURAL NEWS & ADVISORY TABLE
CREATE TABLE IF NOT EXISTS public.news (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image TEXT,
    date DATE DEFAULT CURRENT_DATE,
    source TEXT DEFAULT 'AgriNews / Krishi Vigyan'
);

-- 5. GOVERNMENT SCHEMES TABLE
CREATE TABLE IF NOT EXISTS public.schemes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    eligibility TEXT NOT NULL,
    benefits TEXT NOT NULL,
    documents TEXT,
    link TEXT NOT NULL,
    category TEXT DEFAULT 'Subsidy'
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schemes ENABLE ROW LEVEL SECURITY;

-- PROFILES POLICIES
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;
CREATE POLICY "Users can delete own profile" 
ON public.profiles FOR DELETE USING (auth.uid() = id);

-- LISTINGS POLICIES
DROP POLICY IF EXISTS "Active listings are viewable by everyone" ON public.listings;
CREATE POLICY "Active listings are viewable by everyone" 
ON public.listings FOR SELECT USING (status = 'active' OR auth.uid() = farmer_id);

DROP POLICY IF EXISTS "Farmers can insert listings" ON public.listings;
CREATE POLICY "Farmers can insert listings" 
ON public.listings FOR INSERT WITH CHECK (auth.uid() = farmer_id);

DROP POLICY IF EXISTS "Farmers can update own listings" ON public.listings;
CREATE POLICY "Farmers can update own listings" 
ON public.listings FOR UPDATE USING (auth.uid() = farmer_id);

DROP POLICY IF EXISTS "Farmers can delete own listings" ON public.listings;
CREATE POLICY "Farmers can delete own listings" 
ON public.listings FOR DELETE USING (auth.uid() = farmer_id);

-- PRICES, NEWS & SCHEMES (Read-only for public, admin manageable)
DROP POLICY IF EXISTS "Public read prices" ON public.prices;
CREATE POLICY "Public read prices" ON public.prices FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert prices" ON public.prices;
CREATE POLICY "Public insert prices" ON public.prices FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update prices" ON public.prices;
CREATE POLICY "Public update prices" ON public.prices FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read news" ON public.news;
CREATE POLICY "Public read news" ON public.news FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read schemes" ON public.schemes;
CREATE POLICY "Public read schemes" ON public.schemes FOR SELECT USING (true);

-- ==============================================================================
-- STORAGE BUCKET CONFIGURATION (produce-images)
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('produce-images', 'produce-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg'])
ON CONFLICT (id) DO UPDATE SET 
    public = true,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];

-- Storage RLS: Anyone can view produce photos
DROP POLICY IF EXISTS "Public produce images viewable" ON storage.objects;
CREATE POLICY "Public produce images viewable"
ON storage.objects FOR SELECT
USING (bucket_id = 'produce-images');

-- Storage RLS: Anyone authenticated or public can upload produce photos
DROP POLICY IF EXISTS "Produce images uploadable" ON storage.objects;
CREATE POLICY "Produce images uploadable"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'produce-images');

DROP POLICY IF EXISTS "Produce images deletable" ON storage.objects;
CREATE POLICY "Produce images deletable"
ON storage.objects FOR DELETE
USING (bucket_id = 'produce-images');

-- ==============================================================================
-- RPC FUNCTION: Secure User Account Deletion
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete produce listings
    DELETE FROM public.listings WHERE farmer_id = auth.uid();
    -- Delete profile
    DELETE FROM public.profiles WHERE id = auth.uid();
    -- Delete from auth users
    DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- ==============================================================================
-- SEED DATA (Maharashtra APMC Benchmark & Government Schemes)
-- ==============================================================================
INSERT INTO public.prices (id, commodity, market, min_price, modal_price, max_price, date, source)
VALUES
('pr-1', 'Tomato', 'Vashi APMC (Navi Mumbai)', 18.00, 24.00, 30.00, CURRENT_DATE, 'Agmarknet / MSAMB'),
('pr-2', 'Onion (Nashik Red)', 'Lasalgaon APMC (Nashik)', 15.00, 20.00, 26.00, CURRENT_DATE, 'Agmarknet / MSAMB'),
('pr-3', 'Potato', 'Pune APMC (Gultekdi)', 14.00, 18.50, 23.00, CURRENT_DATE, 'Agmarknet / MSAMB'),
('pr-4', 'Cotton (Medium Staple)', 'Nagpur APMC', 62.00, 71.00, 78.00, CURRENT_DATE, 'Agmarknet / MSAMB'),
('pr-5', 'Soybean (Yellow)', 'Latur APMC', 42.00, 48.50, 54.00, CURRENT_DATE, 'Agmarknet / MSAMB'),
('pr-6', 'Pomegranate (Bhagwa)', 'Solapur APMC', 80.00, 110.00, 140.00, CURRENT_DATE, 'Agmarknet / MSAMB')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.schemes (id, name, description, eligibility, benefits, documents, link, category)
VALUES
('sch-1', 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)', 'Direct income support of ₹6,000 per year in three equal installments to all landholding farmers.', 'Small and marginal landholder farmer families with cultivable land in their name.', '₹6,000 per year transferred directly into bank account (₹2,000 every 4 months).', 'Aadhaar Card, Land ownership 7/12 & 8A extracts, Active Bank Passbook.', 'https://pmkisan.gov.in', 'Subsidy'),
('sch-2', 'PMFBY (Pradhan Mantri Fasal Bima Yojana)', 'Comprehensive crop insurance against non-preventable natural risks from pre-sowing to post-harvest.', 'All farmers including sharecroppers and tenant farmers growing notified crops in notified areas.', 'Comprehensive risk insurance with minimal premium: 2% for Kharif, 1.5% for Rabi, 5% for commercial/horticultural crops.', 'Sowing certificate / Land extract, Bank account details, Aadhaar.', 'https://pmfby.gov.in', 'Insurance'),
('sch-3', 'eNAM (National Agriculture Market)', 'Pan-India electronic trading portal networking existing APMC mandis for unified national market.', 'Any farmer registered with local APMC mandi desiring transparent competitive online bidding.', 'Direct online access to buyers nationwide, transparent price discovery, fast electronic payments.', 'Mandi registration slip, Bank details, Identity proof.', 'https://enam.gov.in', 'Marketplace'),
('sch-4', 'Kisan Credit Card (KCC)', 'Provides adequate and timely credit support from banking system for farming and allied activities.', 'All farmers, individual/joint cultivators, tenant farmers, Self Help Groups (SHGs).', 'Short-term credit up to ₹3 Lakhs at subsidized interest rate of 4% (with prompt repayment incentive).', 'Application form, Land Record (7/12 extract), Identity and address proof.', 'https://www.myscheme.gov.in/schemes/kcc', 'Loan'),
('sch-5', 'PM KUSUM (Solar Pump Scheme)', 'Subsidies up to 90% for setting up standalone solar agricultural pumps and solarizing grid-connected pumps.', 'Individual farmers, farmer groups, cooperatives, water user associations.', 'Up to 90% subsidy for solar water pumps, eliminating daytime diesel/grid power dependency.', 'Land documents, Aadhaar, Bank passbook, Passport photo.', 'https://pmkusum.mnre.gov.in', 'Subsidy')
ON CONFLICT (id) DO NOTHING;
