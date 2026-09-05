import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/listing.dart';
import '../models/price.dart';
import '../models/profile.dart';
import 'mock_data_service.dart';
import 'price_service.dart';

class AuthResult {
  final UserProfile? user;
  final String? error;

  AuthResult({this.user, this.error});

  bool get isSuccess => user != null && error == null;
}

class SupabaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Local in-memory persistent database for offline / fallback mode
  // Pre-seeded with demo accounts so the user can test offline if needed,
  // but strict password validation is ENFORCED!
  static final Map<String, Map<String, dynamic>> _localUsersDb = {
    "9876543210": {
      "id": "f-101",
      "password": "kisan123",
      "name": "Shweta Patil",
      "phone": "9876543210",
      "role": UserRole.farmer,
      "village": "Bhiwandi",
      "taluka": "Bhiwandi",
      "district": "Thane",
      "language": "en",
    },
    "9820098200": {
      "id": "b-201",
      "password": "buyer123",
      "name": "Amit Gupta",
      "phone": "9820098200",
      "role": UserRole.buyer,
      "village": "Vashi Market",
      "taluka": "Navi Mumbai",
      "district": "Thane",
      "language": "en",
    },
    "9999999999": {
      "id": "admin-01",
      "password": "admin123",
      "name": "AgroMitra Administrator",
      "phone": "9999999999",
      "role": UserRole.admin,
      "village": "Central HQ",
      "taluka": "Pune",
      "district": "Pune",
      "language": "en",
    },
  };

  static final List<ProduceListing> _localListings = [];

  /// Initializes Supabase client if configured
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint("[Supabase] Credentials not set in supabase_config.dart. Running in local validated mode.");
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint("[Supabase] Connected successfully to ${SupabaseConfig.supabaseUrl}");
    } catch (e) {
      debugPrint("[Supabase] Initialization error: $e");
      _isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized && SupabaseConfig.isConfigured) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Converts phone to a safe email identifier for Supabase Auth
  static String _phoneToEmail(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return 'user_$cleanPhone@agromitra.app';
  }

  /// Sign Up with Phone + Password
  static Future<AuthResult> signUp({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
    required String village,
    required String taluka,
    required String district,
    String language = "English",
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length < 10) {
      return AuthResult(error: "Please enter a valid 10-digit phone number.");
    }
    if (password.length < 6) {
      return AuthResult(error: "Password must be at least 6 characters long.");
    }

    final supa = client;
    if (supa != null) {
      try {
        final email = _phoneToEmail(cleanPhone);
        final response = await supa.auth.signUp(
          email: email,
          password: password,
          data: {
            'name': name,
            'phone': cleanPhone,
            'role': role == UserRole.farmer ? 'farmer' : (role == UserRole.buyer ? 'buyer' : 'admin'),
            'village': village,
            'taluka': taluka,
            'district': district,
            'language': language,
          },
        );

        final user = response.user;
        if (user != null) {
          // Upsert profile in 'profiles' table
          try {
            await supa.from('profiles').upsert({
              'id': user.id,
              'name': name,
              'phone': cleanPhone,
              'role': role == UserRole.farmer ? 'farmer' : (role == UserRole.buyer ? 'buyer' : 'admin'),
              'village': village,
              'taluka': taluka,
              'district': district,
              'language': language,
              'contact_enabled': true,
              'seller_status': 'active',
            });
          } catch (pe) {
            debugPrint("[Supabase] Profile upsert notice: $pe");
          }

          final profile = UserProfile(
            id: user.id,
            name: name,
            phone: cleanPhone,
            role: role,
            village: village,
            taluka: taluka,
            district: district,
            language: language,
            isVerifiedSeller: true,
          );

          // Also register in local cache
          _localUsersDb[cleanPhone] = {
            "id": user.id,
            "password": password,
            "name": name,
            "phone": cleanPhone,
            "role": role,
            "village": village,
            "taluka": taluka,
            "district": district,
            "language": language,
          };

          return AuthResult(user: profile);
        } else {
          return AuthResult(error: "Signup failed. Please try again.");
        }
      } on AuthException catch (ae) {
        debugPrint("[Supabase] AuthException during signup: ${ae.message}");
        return AuthResult(error: ae.message);
      } catch (e) {
        debugPrint("[Supabase] SignUp error: $e");
        return AuthResult(error: "Network or server error during signup: $e");
      }
    }

    // Local / Offline fallback mode with strict validation
    if (_localUsersDb.containsKey(cleanPhone)) {
      return AuthResult(error: "An account with phone number +91 $cleanPhone already exists. Please log in.");
    }

    final newId = "usr-${DateTime.now().millisecondsSinceEpoch}";
    final newProfile = UserProfile(
      id: newId,
      name: name,
      phone: cleanPhone,
      role: role,
      village: village,
      taluka: taluka,
      district: district,
      language: language,
      isVerifiedSeller: true,
    );

    _localUsersDb[cleanPhone] = {
      "id": newId,
      "password": password,
      "name": name,
      "phone": cleanPhone,
      "role": role,
      "village": village,
      "taluka": taluka,
      "district": district,
      "language": language,
    };

    return AuthResult(user: newProfile);
  }

  /// Sign In with Phone + Password
  static Future<AuthResult> signIn({
    required String phone,
    required String password,
    required UserRole expectedRole,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) {
      return AuthResult(error: "Please enter your registered mobile number.");
    }
    if (password.isEmpty) {
      return AuthResult(error: "Please enter your password.");
    }

    final supa = client;
    if (supa != null) {
      try {
        final email = _phoneToEmail(cleanPhone);
        final response = await supa.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = response.user;
        if (user != null) {
          final profileData = await supa
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (profileData != null) {
            final roleStr = profileData['role'] as String? ?? 'farmer';
            final userRole = roleStr == 'farmer'
                ? UserRole.farmer
                : (roleStr == 'buyer' ? UserRole.buyer : UserRole.admin);

            if (expectedRole != UserRole.admin && userRole != expectedRole) {
              return AuthResult(
                error: "This account is registered as ${roleStr.toUpperCase()}. Please use the $roleStr login screen.",
              );
            }

            final profile = UserProfile(
              id: user.id,
              name: profileData['name'] ?? 'User',
              phone: profileData['phone'] ?? cleanPhone,
              role: userRole,
              village: profileData['village'] ?? 'Bhiwandi',
              taluka: profileData['taluka'] ?? 'Bhiwandi',
              district: profileData['district'] ?? 'Thane',
              language: profileData['language'] ?? 'en',
              isVerifiedSeller: profileData['seller_status'] == 'active',
            );

            return AuthResult(user: profile);
          } else {
            // Profile row missing in DB, construct from auth metadata
            final metadata = user.userMetadata ?? {};
            final profile = UserProfile(
              id: user.id,
              name: metadata['name'] ?? 'User',
              phone: cleanPhone,
              role: expectedRole,
              village: metadata['village'] ?? 'Bhiwandi',
              taluka: metadata['taluka'] ?? 'Bhiwandi',
              district: metadata['district'] ?? 'Thane',
              language: metadata['language'] ?? 'en',
              isVerifiedSeller: true,
            );
            return AuthResult(user: profile);
          }
        }
      } on AuthException catch (ae) {
        debugPrint("[Supabase] AuthException during signin: ${ae.message}");
        return AuthResult(error: "Invalid phone number or password. Please verify your credentials.");
      } catch (e) {
        debugPrint("[Supabase] SignIn error: $e");
      }
    }

    // Local / Offline fallback mode with strict credential validation
    final userRecord = _localUsersDb[cleanPhone];
    if (userRecord == null) {
      return AuthResult(
        error: "No account found with phone number +91 $cleanPhone. Please create an account first.",
      );
    }

    if (userRecord["password"] != password) {
      return AuthResult(
        error: "Incorrect password! Please enter the correct password or reset it.",
      );
    }

    final UserRole role = userRecord["role"] as UserRole;
    if (expectedRole != UserRole.admin && role != expectedRole) {
      final roleName = role == UserRole.farmer ? "Farmer" : "Buyer";
      return AuthResult(
        error: "This account is registered as a $roleName. Please use the $roleName login screen.",
      );
    }

    final profile = UserProfile(
      id: userRecord["id"] as String,
      name: userRecord["name"] as String,
      phone: cleanPhone,
      role: role,
      village: userRecord["village"] as String,
      taluka: userRecord["taluka"] as String,
      district: userRecord["district"] as String,
      language: userRecord["language"] as String? ?? "en",
      isVerifiedSeller: true,
    );

    return AuthResult(user: profile);
  }

  /// Fetch produce listings from Supabase (or fallback)
  static Future<List<ProduceListing>> fetchListings() async {
    final supa = client;
    if (supa != null) {
      try {
        final data = await supa
            .from('listings')
            .select()
            .order('created_at', ascending: false);

        if (data.isNotEmpty) {
          final List<ProduceListing> loaded = [];
          for (final item in data) {
            try {
              List<String> photos = [];
              if (item['photo_urls'] is List) {
                photos = List<String>.from(item['photo_urls']);
              } else if (item['photo_url'] != null) {
                photos = [item['photo_url'].toString()];
              }
              if (photos.isEmpty) {
                photos = ['https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80'];
              }

              loaded.add(ProduceListing(
                id: item['id']?.toString() ?? 'lst-${DateTime.now().millisecondsSinceEpoch}',
                farmerId: item['farmer_id']?.toString() ?? '',
                farmerName: item['farmer_name']?.toString() ?? 'Farmer',
                farmerPhone: item['farmer_phone']?.toString() ?? '+91 98765 43210',
                commodity: item['commodity']?.toString() ?? 'Tomato',
                photoUrls: photos,
                qualityGrade: item['quality_grade']?.toString() ?? 'Grade A',
                aiSuggestion: item['ai_suggestion']?.toString() ?? 'Grade A',
                qualityConfidence: (item['quality_confidence'] as num?)?.toDouble() ?? 0.90,
                aiReason: item['ai_reason']?.toString() ?? 'Inspected harvest',
                mandiBenchmarkPrice: (item['mandi_benchmark_price'] as num?)?.toDouble() ?? 24.0,
                suggestedPrice: (item['suggested_price'] as num?)?.toDouble() ?? 26.40,
                finalPrice: (item['final_price'] as num?)?.toDouble() ?? 26.0,
                quantity: (item['quantity'] as num?)?.toDouble() ?? 10.0,
                unit: item['unit']?.toString() ?? 'Quintal',
                description: item['description']?.toString() ?? '',
                village: item['village']?.toString() ?? 'Bhiwandi',
                taluka: item['taluka']?.toString() ?? 'Bhiwandi',
                district: item['district']?.toString() ?? 'Thane',
                status: item['status'] == 'sold' ? ListingStatus.sold : ListingStatus.active,
                isFarmerVerified: true,
              ));
            } catch (parseError) {
              debugPrint("[Supabase] Error parsing listing item: $parseError");
            }
          }

          if (loaded.isNotEmpty) {
            return loaded;
          }
        }
      } catch (e) {
        debugPrint("[Supabase] fetchListings error: $e");
      }
    }

    // Merge locally created listings with mock listings
    final allListings = <ProduceListing>[..._localListings];
    final mockList = MockDataService.getProduceListings();
    for (final m in mockList) {
      if (!allListings.any((l) => l.id == m.id)) {
        allListings.add(m);
      }
    }
    return allListings;
  }

  /// Create a new produce listing
  static Future<bool> createListing(ProduceListing listing) async {
    _localListings.insert(0, listing);

    final supa = client;
    if (supa == null) return true;

    try {
      await supa.from('listings').insert({
        'id': listing.id,
        'farmer_id': listing.farmerId,
        'farmer_name': listing.farmerName,
        'farmer_phone': listing.farmerPhone,
        'commodity': listing.commodity,
        'photo_urls': listing.photoUrls,
        'quality_grade': listing.qualityGrade,
        'ai_suggestion': listing.aiSuggestion,
        'quality_confidence': listing.qualityConfidence,
        'ai_reason': listing.aiReason,
        'mandi_benchmark_price': listing.mandiBenchmarkPrice,
        'suggested_price': listing.suggestedPrice,
        'final_price': listing.finalPrice,
        'quantity': listing.quantity,
        'unit': listing.unit,
        'description': listing.description,
        'village': listing.village,
        'taluka': listing.taluka,
        'district': listing.district,
        'status': listing.status == ListingStatus.active ? 'active' : 'sold',
      });
      debugPrint("[Supabase] Successfully posted listing ${listing.id} to Supabase");
      return true;
    } catch (e) {
      debugPrint("[Supabase] createListing error: $e");
      return false;
    }
  }

  /// Upload produce image bytes to Supabase Storage or generate data URI fallback
  static Future<String> uploadProduceImage(Uint8List bytes, String commodity) async {
    final supa = client;
    final fileName = '${commodity.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (supa != null) {
      try {
        await supa.storage.from('produce-images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
        final publicUrl = supa.storage.from('produce-images').getPublicUrl(fileName);
        debugPrint("[Supabase] Uploaded image to Supabase Storage: $publicUrl");
        return publicUrl;
      } catch (e) {
        debugPrint("[Supabase] Storage upload notice: $e");
      }
    }

    // High quality Base64 Data URI fallback (works instantly offline & cross-platform)
    final base64String = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  /// Delete a produce listing from Supabase and local cache
  static Future<bool> deleteListing(String listingId) async {
    _localListings.removeWhere((l) => l.id == listingId);

    final supa = client;
    if (supa == null) return true;

    try {
      await supa.from('listings').delete().eq('id', listingId);
      debugPrint("[Supabase] Successfully deleted listing $listingId from Supabase");
      return true;
    } catch (e) {
      debugPrint("[Supabase] deleteListing error: $e");
      return false;
    }
  }

  /// Delete User Account and all associated data from Supabase and local DB
  static Future<bool> deleteAccount({
    required String userId,
    required String phone,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // 1. Remove local user record and listings
    _localUsersDb.remove(cleanPhone);
    _localListings.removeWhere((l) => l.farmerId == userId || l.farmerPhone == phone || l.farmerPhone.contains(cleanPhone));

    final supa = client;
    if (supa != null) {
      try {
        // Delete all listings created by this farmer
        await supa.from('listings').delete().eq('farmer_id', userId);
        // Delete user's profile
        await supa.from('profiles').delete().eq('id', userId);
        
        // Attempt to call delete_user RPC if created, or sign out
        try {
          await supa.rpc('delete_user_account');
        } catch (_) {}

        await supa.auth.signOut();
        debugPrint("[Supabase] Successfully deleted account data for $userId ($cleanPhone)");
      } catch (e) {
        debugPrint("[Supabase] deleteAccount notice: $e");
      }
    }

    return true;
  }

  /// Helper to safely parse numeric or string doubles from Supabase
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  /// Helper to extract or fallback district
  static String _extractDistrict(String? rawDistrict, String market) {
    if (rawDistrict != null && rawDistrict.trim().isNotEmpty && rawDistrict != 'Maharashtra') {
      return rawDistrict.trim();
    }
    final lower = market.toLowerCase();
    if (lower.contains('navi mumbai') || lower.contains('vashi') || lower.contains('thane')) return 'Thane';
    if (lower.contains('nashik') || lower.contains('lasalgaon')) return 'Nashik';
    if (lower.contains('pune') || lower.contains('gultekdi')) return 'Pune';
    if (lower.contains('nagpur')) return 'Nagpur';
    if (lower.contains('latur')) return 'Latur';
    if (lower.contains('solapur')) return 'Solapur';
    if (lower.contains('jalgaon')) return 'Jalgaon';
    if (lower.contains('kolhapur')) return 'Kolhapur';
    if (lower.contains('amravati')) return 'Amravati';
    if (lower.contains('wardha')) return 'Wardha';

    final match = RegExp(r'\(([^)]+)\)').firstMatch(market);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    return rawDistrict?.isNotEmpty == true ? rawDistrict! : 'Maharashtra';
  }

  /// Fetch live / cached Mandi Prices from Supabase 'prices' table
  static Future<List<MandiPrice>> fetchMandiPrices() async {
    final supa = client;
    if (supa == null) {
      debugPrint("[MandiSyncDebug] Supabase client is not initialized or configured.");
      return [];
    }

    try {
      debugPrint("[MandiSyncDebug] Executing Supabase query on table 'prices'...");
      final data = await supa.from('prices').select().order('created_at', ascending: false);
      debugPrint("[MandiSyncDebug] Response received from 'prices' table: ${data.length} records. Raw data: $data");

      if (data.isNotEmpty) {
        final List<MandiPrice> list = [];
        for (final item in data) {
          final comm = item['commodity']?.toString() ?? 'Commodity';
          final mkt = item['market']?.toString() ?? 'APMC Mandi';
          final dist = _extractDistrict(item['district']?.toString(), mkt);
          final icon = item['commodity_icon']?.toString() ?? PriceService.getIconForCommodity(comm);

          final min = _parseDouble(item['min_price']);
          final modal = _parseDouble(item['modal_price']);
          final max = _parseDouble(item['max_price']);
          final date = item['date']?.toString() ?? 'Today';
          final source = item['source']?.toString() ?? 'Agmarknet / MSAMB';
          final trend = _parseDouble(item['trend_percent']);

          list.add(MandiPrice(
            id: item['id']?.toString() ?? 'pr-${list.length + 1}',
            commodity: comm,
            commodityIcon: icon,
            market: mkt,
            district: dist,
            minPrice: min,
            modalPrice: modal,
            maxPrice: max,
            unit: 'kg',
            date: date,
            source: source,
            trendPercent: trend,
          ));
        }
        debugPrint("[MandiSyncDebug] Deserialized ${list.length} MandiPrice objects successfully from Supabase.");
        return list;
      }
    } catch (e, stack) {
      debugPrint("[MandiSyncDebug] Response/Error: $e");
      debugPrint("[MandiSyncDebug] StackTrace: $stack");
    }

    return [];
  }

  /// Automatically syncs live government records into Supabase 'prices' table
  static Future<void> upsertMandiPrices(List<MandiPrice> prices) async {
    final supa = client;
    if (supa == null || prices.isEmpty) return;
    try {
      final rows = prices.take(25).map((p) => {
        'id': p.id,
        'commodity': p.commodity,
        'market': p.market,
        'min_price': p.minPrice,
        'modal_price': p.modalPrice,
        'max_price': p.maxPrice,
        'date': p.date,
        'source': p.source,
        'is_live': true,
      }).toList();

      await supa.from('prices').upsert(rows, onConflict: 'id');
      debugPrint("[Supabase] Auto-synced ${rows.length} live govt prices into Supabase 'prices' table!");
    } catch (e) {
      debugPrint("[Supabase] Auto-sync to Supabase notice: $e");
    }
  }
}
