import '../models/price.dart';
import '../models/listing.dart';
import '../models/scheme.dart';
import '../models/news.dart';
import '../models/profile.dart';

class MockDataService {
  // Seeded Mandi APMC Benchmark Prices
  static List<MandiPrice> getMandiPrices() {
    return [
      MandiPrice(
        id: "p1",
        commodity: "Tomato",
        commodityIcon: "🍅",
        market: "Vashi APMC (Navi Mumbai)",
        district: "Thane",
        minPrice: 18.0,
        modalPrice: 24.0,
        maxPrice: 30.0,
        unit: "kg",
        date: "Today, 06:30 AM",
        source: "APMC Vashi Benchmark",
        trendPercent: 4.2,
      ),
      MandiPrice(
        id: "p2",
        commodity: "Onion",
        commodityIcon: "🧅",
        market: "Lasalgaon Mandi",
        district: "Nashik",
        minPrice: 22.0,
        modalPrice: 28.0,
        maxPrice: 34.0,
        unit: "kg",
        date: "Today, 07:00 AM",
        source: "Lasalgaon APMC",
        trendPercent: -1.8,
      ),
      MandiPrice(
        id: "p3",
        commodity: "Potato",
        commodityIcon: "🥔",
        market: "Gultekdi Market Yard",
        district: "Pune",
        minPrice: 16.0,
        modalPrice: 20.0,
        maxPrice: 25.0,
        unit: "kg",
        date: "Today, 06:15 AM",
        source: "Pune APMC",
        trendPercent: 0.5,
      ),
      MandiPrice(
        id: "p4",
        commodity: "Cotton",
        commodityIcon: "🌱",
        market: "Wardha Mandi",
        district: "Wardha",
        minPrice: 68.0,
        modalPrice: 74.0,
        maxPrice: 82.0,
        unit: "kg",
        date: "Yesterday",
        source: "Agmarknet Maharashtra",
        trendPercent: 2.1,
      ),
      MandiPrice(
        id: "p5",
        commodity: "Soybean",
        commodityIcon: "🫘",
        market: "Latur Mandi",
        district: "Latur",
        minPrice: 42.0,
        modalPrice: 46.0,
        maxPrice: 51.0,
        unit: "kg",
        date: "Today, 08:00 AM",
        source: "Latur Grain APMC",
        trendPercent: 1.2,
      ),
      MandiPrice(
        id: "p6",
        commodity: "Pomegranate",
        commodityIcon: "🍎",
        market: "Solapur APMC",
        district: "Solapur",
        minPrice: 80.0,
        modalPrice: 110.0,
        maxPrice: 140.0,
        unit: "kg",
        date: "Today, 06:45 AM",
        source: "Solapur Fruit Market",
        trendPercent: 5.0,
      ),
      MandiPrice(
        id: "p7",
        commodity: "Banana",
        commodityIcon: "🍌",
        market: "Jalgaon APMC",
        district: "Jalgaon",
        minPrice: 14.0,
        modalPrice: 18.0,
        maxPrice: 22.0,
        unit: "kg",
        date: "Today, 07:30 AM",
        source: "Jalgaon Agro Mandi",
        trendPercent: -0.8,
      ),
      MandiPrice(
        id: "p8",
        commodity: "Wheat (Sharbati)",
        commodityIcon: "🌾",
        market: "Akola Mandi",
        district: "Akola",
        minPrice: 28.0,
        modalPrice: 32.0,
        maxPrice: 38.0,
        unit: "kg",
        date: "Yesterday",
        source: "Akola APMC Yard",
        trendPercent: 0.0,
      ),
    ];
  }

  // Seeded Produce Listings
  static List<ProduceListing> getProduceListings() {
    return [
      ProduceListing(
        id: "lst-01",
        farmerId: "f-101",
        farmerName: "Shweta Patil",
        farmerPhone: "+91 98765 43210",
        commodity: "Tomato (Abhinav)",
        photoUrls: [
          "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80",
          "https://images.unsplash.com/photo-1546470427-e26264be0b11?w=500&q=80",
        ],
        qualityGrade: "Grade A",
        aiSuggestion: "Grade A",
        qualityConfidence: 0.92,
        aiReason: "Uniform vibrant crimson color, firm texture, defect-free skin",
        mandiBenchmarkPrice: 24.0,
        suggestedPrice: 26.40,
        finalPrice: 26.00,
        quantity: 25.0,
        unit: "Quintal",
        description: "Freshly harvested Grade-A farm fresh Abhinav tomatoes. Picked this morning from drip-irrigated field.",
        village: "Bhiwandi",
        taluka: "Bhiwandi",
        district: "Thane",
        status: ListingStatus.active,
        isFarmerVerified: true,
      ),
      ProduceListing(
        id: "lst-02",
        farmerId: "f-102",
        farmerName: "Ramesh Deshmukh",
        farmerPhone: "+91 98231 12345",
        commodity: "Red Onion (Nashik Special)",
        photoUrls: [
          "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=500&q=80",
        ],
        qualityGrade: "Grade A",
        aiSuggestion: "Grade A",
        qualityConfidence: 0.90,
        aiReason: "Dry outer scales, heavy density, consistent 50mm+ diameter",
        mandiBenchmarkPrice: 28.0,
        suggestedPrice: 30.80,
        finalPrice: 30.00,
        quantity: 50.0,
        unit: "Quintal",
        description: "Naturally cured export-grade Nashik red onions. Ready for bulk dispatch in 50kg mesh bags.",
        village: "Lasalgaon",
        taluka: "Niphad",
        district: "Nashik",
        status: ListingStatus.active,
        isFarmerVerified: true,
      ),
      ProduceListing(
        id: "lst-03",
        farmerId: "f-103",
        farmerName: "Santosh Jadhav",
        farmerPhone: "+91 97654 98765",
        commodity: "Potato (Kufri Jyoti)",
        photoUrls: [
          "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&q=80",
        ],
        qualityGrade: "Grade B",
        aiSuggestion: "Grade B",
        qualityConfidence: 0.88,
        aiReason: "Good size uniformity, clean skin with minor soil residue",
        mandiBenchmarkPrice: 20.0,
        suggestedPrice: 20.00,
        finalPrice: 21.00,
        quantity: 40.0,
        unit: "Quintal",
        description: "Table potato standard size, harvested 3 days ago. No cuts or sprouts.",
        village: "Manchar",
        taluka: "Ambegaon",
        district: "Pune",
        status: ListingStatus.active,
        isFarmerVerified: true,
      ),
      ProduceListing(
        id: "lst-04",
        farmerId: "f-104",
        farmerName: "Ananda Shinde",
        farmerPhone: "+91 94220 54321",
        commodity: "Pomegranate (Bhagwa)",
        photoUrls: [
          "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500&q=80",
        ],
        qualityGrade: "Grade A",
        aiSuggestion: "Grade A",
        qualityConfidence: 0.95,
        aiReason: "Deep ruby red arils, sweet flavor index, premium 250g+ weight",
        mandiBenchmarkPrice: 110.0,
        suggestedPrice: 121.00,
        finalPrice: 120.00,
        quantity: 15.0,
        unit: "Quintal",
        description: "Export quality Solapur Bhagwa Anar. Hand-picked, sorted and crated carefully.",
        village: "Sangola",
        taluka: "Sangola",
        district: "Solapur",
        status: ListingStatus.active,
        isFarmerVerified: true,
      ),
      ProduceListing(
        id: "lst-05",
        farmerId: "f-105",
        farmerName: "Kavita Gaikwad",
        farmerPhone: "+91 98900 87654",
        commodity: "Soybean (JS 335)",
        photoUrls: [
          "https://images.unsplash.com/photo-1588644525273-f37b60d78512?w=500&q=80",
        ],
        qualityGrade: "Grade B",
        aiSuggestion: "Grade B",
        qualityConfidence: 0.89,
        aiReason: "Moisture content ~11%, low breakage, good luster",
        mandiBenchmarkPrice: 46.0,
        suggestedPrice: 46.00,
        finalPrice: 47.00,
        quantity: 60.0,
        unit: "Quintal",
        description: "Dry and machine cleaned soybean lot. Suitable for oil mills and seed processing.",
        village: "Ausa",
        taluka: "Ausa",
        district: "Latur",
        status: ListingStatus.active,
        isFarmerVerified: false,
      ),
    ];
  }

  // Seeded Government Schemes
  static List<GovernmentScheme> getGovernmentSchemes() {
    return [
      GovernmentScheme(
        id: "sch-01",
        title: "PM-KISAN Samman Nidhi",
        subtitle: "Direct income support of ₹6,000 per year in 3 equal installments",
        ministry: "Ministry of Agriculture & Farmers Welfare",
        category: "Subsidy",
        badgeText: "Direct DBT",
        overview: "Pradhan Mantri Kisan Samman Nidhi is a central sector scheme with 100% funding from Government of India. It provides income support to all landholding farmers' families in the country to supplement their financial needs for procuring various inputs related to agriculture and domestic requirements.",
        eligibility: [
          "All small and marginal landholder farmer families having cultivable landholding in their names.",
          "Farmer family defined as husband, wife, and minor children.",
          "Valid Aadhaar linked bank account is mandatory.",
          "Excludes institutional landholders, tax payers, and serving government employees."
        ],
        benefits: [
          "₹6,000 per year financial benefit transferred directly into bank accounts.",
          "Distributed in three equal installments of ₹2,000 every 4 months.",
          "Seamless DBT transfer with no intermediaries."
        ],
        requiredDocuments: [
          "Aadhaar Card",
          "Land Ownership Record (7/12 Extract / 8A in Maharashtra)",
          "Bank Account Passbook / Statement linked with Aadhaar",
          "Active Mobile Number"
        ],
        applicationProcess: "Farmers can register online at the official pmkisan.gov.in portal or visit their local Common Service Center (CSC) / Taluka Agriculture Officer with land papers.",
        importantDates: "Installment Cycles: April-July, August-November, December-March.",
        officialUrl: "https://pmkisan.gov.in/",
      ),
      GovernmentScheme(
        id: "sch-02",
        title: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
        subtitle: "Comprehensive crop insurance against drought, floods, pests & natural risks",
        ministry: "Ministry of Agriculture & Farmers Welfare",
        category: "Insurance",
        badgeText: "Crop Shield",
        overview: "PMFBY provides comprehensive insurance cover against failure of crops, thereby helping in stabilising the income of the farmers and encouraging them to adopt innovative agricultural practices.",
        eligibility: [
          "All farmers including sharecroppers and tenant farmers growing notified crops in notified areas.",
          "Both loanee and non-loanee farmers are eligible.",
          "Crop sowing proof / declaration verified by local Revenue/Agriculture Department."
        ],
        benefits: [
          "Very low premium rates: Only 2% for Kharif crops, 1.5% for Rabi crops, and 5% for annual commercial/horticulture crops.",
          "Remaining premium subsidized up to 90% equally by Central and State Governments.",
          "Post-harvest loss coverage up to 14 days after harvesting."
        ],
        requiredDocuments: [
          "Land record documents (7/12 & 8A extracts)",
          "Sowing Certificate / Crop Declaration",
          "Bank Passbook copy with IFSC",
          "Aadhaar Card"
        ],
        applicationProcess: "Apply online at pmfby.gov.in or visit local banks, primary agricultural credit societies (PACS), or CSC centers before the cut-off date.",
        importantDates: "Kharif application deadline: July 31 | Rabi deadline: December 31.",
        officialUrl: "https://pmfby.gov.in/",
      ),
      GovernmentScheme(
        id: "sch-03",
        title: "eNAM (National Agriculture Market)",
        subtitle: "Pan-India electronic trading portal uniting APMC mandis for transparent price bidding",
        ministry: "Ministry of Agriculture & Farmers Welfare",
        category: "Subsidy",
        badgeText: "Digital Mandi",
        overview: "National Agriculture Market (eNAM) is a pan-India electronic trading portal which networks the existing APMC mandis to create a unified national market for agricultural commodities.",
        eligibility: [
          "Any individual farmer or Farmer Producer Organisation (FPO) with agricultural produce.",
          "Registered in any connected APMC mandi yard."
        ],
        benefits: [
          "Access to competitive national buyer bids beyond local mandi boundaries.",
          "Transparent electronic auction system ensuring maximum price realization.",
          "Direct online payment settlement into farmer bank account within 24 hours."
        ],
        requiredDocuments: [
          "Farmer Registration / Mandi Gate Pass",
          "Aadhaar card",
          "Bank account passbook"
        ],
        applicationProcess: "Register at enam.gov.in or visit the eNAM helpdesk kiosk located at your nearest district APMC Mandi.",
        importantDates: "Active throughout the year for trading hours in registered APMCs.",
        officialUrl: "https://enam.gov.in/",
      ),
      GovernmentScheme(
        id: "sch-04",
        title: "Kisan Credit Card (KCC) Scheme",
        subtitle: "Concessional institutional crop credit with 4% effective interest rate",
        ministry: "Ministry of Finance & Agriculture",
        category: "Loan",
        badgeText: "Low Interest Credit",
        overview: "KCC aims at providing adequate and timely credit support from the banking system under a single window with flexible and simplified procedure to the farmers for their cultivation and other needs.",
        eligibility: [
          "All farmers – individuals / joint borrowers who are owner cultivators.",
          "Tenant farmers, oral lessees & sharecroppers.",
          "SHGs or Joint Liability Groups of farmers including tenant farmers."
        ],
        benefits: [
          "Revolving credit limit up to ₹3,00,000 at 7% basic interest.",
          "3% prompt repayment incentive, reducing effective interest rate to just 4% per annum.",
          "Flexible repayment schedule aligned with crop harvesting cycles."
        ],
        requiredDocuments: [
          "Duly filled application form",
          "Two passport size photos",
          "Identity proof (Aadhaar / Voter ID)",
          "Land record (7/12 Extract, Khatauni)",
          "Crop cropping pattern details"
        ],
        applicationProcess: "Apply at any rural bank branch, commercial bank, or download the KCC form from the official website and submit to your bank.",
        importantDates: "Available throughout the year.",
        officialUrl: "https://www.myscheme.gov.in/schemes/kcc",
      ),
      GovernmentScheme(
        id: "sch-05",
        title: "PM-KUSUM (Solar Pump Scheme)",
        subtitle: "Up to 90% subsidy on installation of stand-alone solar agricultural pumps",
        ministry: "Ministry of New and Renewable Energy",
        category: "Subsidy",
        badgeText: "Solar Subsidy",
        overview: "PM-KUSUM scheme aims to provide energy security to farmers and increase the share of clean energy in the agricultural sector through solar pumps and grid-connected solar power plants.",
        eligibility: [
          "Individual farmers, groups of farmers, cooperatives, and FPOs.",
          "Land with irrigation source but lacking regular electricity connection or replacing diesel pumps."
        ],
        benefits: [
          "60% financial assistance (30% Centre + 30% State in Maharashtra).",
          "30% bank loan facility, farmer only pays 10% upfront.",
          "Uninterrupted daytime solar power for irrigation and zero diesel fuel expenses."
        ],
        requiredDocuments: [
          "Aadhaar Card",
          "Land records (7/12, 8A)",
          "Bank passbook copy",
          "Source of water proof (Well/Borewell NOC)"
        ],
        applicationProcess: "Register online on state renewable energy portals (e.g. MahaUrja in Maharashtra or pmkusum.mnre.gov.in).",
        importantDates: "State portal application windows announced seasonally.",
        officialUrl: "https://pmkusum.mnre.gov.in/",
      ),
      GovernmentScheme(
        id: "sch-06",
        title: "Mahila Kisan Sashaktikaran Pariyojana (MKSP)",
        subtitle: "Dedicated empowerment and organic training for women farmers and SHGs",
        ministry: "Ministry of Rural Development",
        category: "Women",
        badgeText: "Women Support",
        overview: "A sub-component of Deendayal Antyodaya Yojana-NRLM to improve the present status of women in agriculture and to enhance the opportunities for their empowerment.",
        eligibility: [
          "Women farmers and women Self Help Groups (SHGs) involved in agriculture and allied sectors."
        ],
        benefits: [
          "Capacity building and sustainable organic farming training.",
          "Financial grants for bio-input resource centers and small farm tools.",
          "Market linkage facilitation through Saras and rural haats."
        ],
        requiredDocuments: [
          "SHG Membership certificate",
          "Aadhaar Card",
          "Bank passbook"
        ],
        applicationProcess: "Apply through local Block Development Officer (BDO) or Village SHG Federation.",
        importantDates: "Ongoing registration.",
        officialUrl: "https://aajeevika.gov.in/en/content/mahila-kisan-sashaktikaran-pariyojana-mksp",
      ),
    ];
  }

  // Seeded News & Updates
  static List<AgriculturalNews> getNews() {
    return [
      AgriculturalNews(
        id: "n1",
        title: "Maharashtra Mandis Report Surge in Tomato & Onion Arrivals",
        description: "APMC Vashi and Lasalgaon recorded 15% increase in vegetable arrivals. Modal prices remain steady across key western districts.",
        date: "Today, 08:30 AM",
        source: "Maharashtra Agro Bulletin",
        tag: "Mandi Trend",
      ),
      AgriculturalNews(
        id: "n2",
        title: "IMD Weather Advisory: Favorable Conditions for Rabi Sowing",
        description: "Optimal soil moisture levels reported in Nashik, Pune, and Ahmednagar. Farmers advised to ensure certified seed treatment.",
        date: "Yesterday",
        source: "IMD Agromet Advisory",
        tag: "Weather Alert",
      ),
      AgriculturalNews(
        id: "n3",
        title: "Government Announces Fast-Track DBT for PM-KISAN Installments",
        description: "Central government begins direct Aadhaar-enabled disbursements to over 9.5 crore registered farmers across India.",
        date: "2 days ago",
        source: "Ministry of Agriculture",
        tag: "Govt Update",
      ),
    ];
  }

  // Demo Default Profiles
  static UserProfile getDemoFarmer() {
    return UserProfile(
      id: "f-101",
      name: "Shweta Patil",
      phone: "+91 98765 43210",
      role: UserRole.farmer,
      village: "Bhiwandi",
      taluka: "Bhiwandi",
      district: "Thane",
      language: "en",
      contactEnabled: true,
      isVerifiedSeller: true,
    );
  }

  static UserProfile getDemoBuyer() {
    return UserProfile(
      id: "b-201",
      name: "Amit Gupta",
      phone: "+91 98200 98200",
      role: UserRole.buyer,
      village: "Vashi",
      taluka: "Navi Mumbai",
      district: "Thane",
      language: "en",
      contactEnabled: true,
      isVerifiedSeller: true,
    );
  }
}
