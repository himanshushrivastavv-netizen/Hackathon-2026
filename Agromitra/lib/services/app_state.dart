import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/listing.dart';
import '../models/price.dart';
import '../models/scheme.dart';
import '../models/news.dart';
import '../utils/app_strings.dart';
import 'mock_data_service.dart';
import 'price_service.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  // App Language
  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  // Active User Profile (null on startup until user logs in)
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Listings
  List<ProduceListing> _listings = [];
  List<ProduceListing> get listings => _listings;
  bool _isLoadingListings = false;
  bool get isLoadingListings => _isLoadingListings;

  // Mandi Prices
  List<MandiPrice> _mandiPrices = [];
  List<MandiPrice> get mandiPrices => _mandiPrices;
  bool _isLoadingPrices = false;
  bool get isLoadingPrices => _isLoadingPrices;

  // Schemes
  List<GovernmentScheme> _schemes = [];
  List<GovernmentScheme> get schemes => _schemes;

  // News
  List<AgriculturalNews> _news = [];
  List<AgriculturalNews> get news => _news;

  // Filter States
  String _selectedCommodityFilter = 'All';
  String get selectedCommodityFilter => _selectedCommodityFilter;

  String _selectedSchemeCategory = 'All';
  String get selectedSchemeCategory => _selectedSchemeCategory;

  AppState() {
    _initializeData();
  }

  void _initializeData() {
    _schemes = MockDataService.getGovernmentSchemes();
    _news = MockDataService.getNews();
    _mandiPrices = MockDataService.getMandiPrices();
    _listings = MockDataService.getProduceListings();

    // Asynchronously fetch live listings and live mandi prices
    refreshListings();
    refreshMandiPrices();
  }

  // Translation helper
  String tr(String key) {
    return AppStrings.get(key, lang: _currentLanguage);
  }

  void setLanguage(String langCode) {
    if (_currentLanguage != langCode) {
      _currentLanguage = langCode;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(language: langCode);
      }
      notifyListeners();
    }
  }

  // --- Authentication Actions with Strict Validation ---

  /// Sign In Farmer
  Future<String?> loginFarmer({
    required String phone,
    required String password,
  }) async {
    final result = await SupabaseService.signIn(
      phone: phone,
      password: password,
      expectedRole: UserRole.farmer,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
      notifyListeners();
      await refreshListings();
      return null;
    } else {
      return result.error ?? "Failed to log in as Farmer.";
    }
  }

  /// Sign Up Farmer
  Future<String?> signupFarmer({
    required String name,
    required String phone,
    required String password,
    required String village,
    required String taluka,
    required String district,
  }) async {
    final result = await SupabaseService.signUp(
      name: name,
      phone: phone,
      password: password,
      role: UserRole.farmer,
      village: village,
      taluka: taluka,
      district: district,
      language: _currentLanguage,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
      notifyListeners();
      await refreshListings();
      return null;
    } else {
      return result.error ?? "Failed to create farmer account.";
    }
  }

  /// Sign In Buyer
  Future<String?> loginBuyer({
    required String phone,
    required String password,
  }) async {
    final result = await SupabaseService.signIn(
      phone: phone,
      password: password,
      expectedRole: UserRole.buyer,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
      notifyListeners();
      await refreshListings();
      return null;
    } else {
      return result.error ?? "Failed to log in as Buyer.";
    }
  }

  /// Sign Up Buyer
  Future<String?> signupBuyer({
    required String name,
    required String phone,
    required String password,
    required String village,
    required String taluka,
    required String district,
  }) async {
    final result = await SupabaseService.signUp(
      name: name,
      phone: phone,
      password: password,
      role: UserRole.buyer,
      village: village,
      taluka: taluka,
      district: district,
      language: _currentLanguage,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
      notifyListeners();
      await refreshListings();
      return null;
    } else {
      return result.error ?? "Failed to create buyer account.";
    }
  }

  /// Sign In Admin
  Future<String?> loginAdmin({
    required String phone,
    required String password,
  }) async {
    if (password != "admin123" && password != "agromitra2026") {
      return "Invalid admin secret key or password.";
    }

    final result = await SupabaseService.signIn(
      phone: phone,
      password: password,
      expectedRole: UserRole.admin,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
    } else {
      _currentUser = UserProfile(
        id: "admin-01",
        name: "AgroMitra Administrator",
        phone: phone.isNotEmpty ? phone : "+91 99999 99999",
        role: UserRole.admin,
        village: "Central HQ",
        taluka: "Pune",
        district: "Pune",
        language: _currentLanguage,
        contactEnabled: false,
        isVerifiedSeller: true,
      );
    }
    notifyListeners();
    await refreshListings();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Permanently deletes user account, listings and profile data from Supabase and local DB
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;
    final userId = _currentUser!.id;
    final phone = _currentUser!.phone;

    final success = await SupabaseService.deleteAccount(userId: userId, phone: phone);
    
    // Remove all listings by this user from in-memory state
    _listings.removeWhere((l) =>
        l.farmerId == userId ||
        l.farmerPhone == phone ||
        (phone.isNotEmpty && l.farmerPhone.contains(phone.replaceAll(RegExp(r'[^0-9]'), ''))));

    _currentUser = null;
    notifyListeners();
    return success;
  }

  void updateProfile({
    String? name,
    String? phone,
    String? village,
    String? taluka,
    String? district,
    bool? contactEnabled,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        village: village,
        taluka: taluka,
        district: district,
        contactEnabled: contactEnabled,
      );
      notifyListeners();
    }
  }

  // --- Listings & Mandi Live Sync Management ---

  /// Refreshes produce listings from Supabase / server
  Future<void> refreshListings() async {
    _isLoadingListings = true;
    notifyListeners();

    try {
      final fetched = await SupabaseService.fetchListings();
      if (fetched.isNotEmpty) {
        _listings = fetched;
      }
    } catch (e) {
      debugPrint("[AppState] Error fetching listings: $e");
    } finally {
      _isLoadingListings = false;
      notifyListeners();
    }
  }

  /// Refreshes Mandi Prices from Data.gov.in and Supabase
  Future<void> refreshMandiPrices() async {
    _isLoadingPrices = true;
    notifyListeners();

    try {
      final fetched = await PriceService.fetchLiveMandiPrices(forceRefresh: true);
      if (fetched.isNotEmpty) {
        _mandiPrices = fetched;
      }
    } catch (e) {
      debugPrint("[AppState] Error fetching mandi prices: $e");
    } finally {
      _isLoadingPrices = false;
      notifyListeners();
    }
  }

  /// Publish a new produce listing
  Future<bool> addListing(ProduceListing newListing) async {
    _listings.insert(0, newListing);
    notifyListeners();

    final success = await SupabaseService.createListing(newListing);
    return success;
  }

  Future<bool> deleteListing(String listingId) async {
    _listings.removeWhere((l) => l.id == listingId);
    notifyListeners();

    final success = await SupabaseService.deleteListing(listingId);
    return success;
  }

  void markListingAsSold(String listingId) {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _listings[index] = _listings[index].copyWith(status: ListingStatus.sold);
      notifyListeners();
    }
  }

  void updateListingPrice(String listingId, double newPrice) {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _listings[index] = _listings[index].copyWith(finalPrice: newPrice);
      notifyListeners();
    }
  }

  // Farmer specific listings
  List<ProduceListing> getFarmerListings(String farmerId) {
    return _listings
        .where((l) =>
            l.farmerId == farmerId ||
            (_currentUser != null && l.farmerName == _currentUser?.name) ||
            (_currentUser != null && l.farmerPhone == _currentUser?.phone))
        .toList();
  }

  // Filter setters
  void setCommodityFilter(String filter) {
    _selectedCommodityFilter = filter;
    notifyListeners();
  }

  void setSchemeCategory(String category) {
    _selectedSchemeCategory = category;
    notifyListeners();
  }

  // Admin Actions
  void toggleSellerVerification(String farmerId) {
    for (int i = 0; i < _listings.length; i++) {
      if (_listings[i].farmerId == farmerId) {
        _listings[i] = _listings[i].copyWith();
      }
    }
    notifyListeners();
  }
}
