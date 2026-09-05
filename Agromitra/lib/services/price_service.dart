import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/price.dart';
import 'mock_data_service.dart';
import 'supabase_service.dart';

enum MandiPriceSource {
  dataGovLive,
  supabaseLive,
  offlineCache,
}

class PriceService {
  static const String _dataGovApiKey = "579b464db66ec23bdd00000190cd99fd52804ab77183303a7fc4a2bd";
  static const String _resourceId = "9ef84268-d588-465a-a308-a864a43d0070";
  static const String _dataGovEndpoint =
      "https://api.data.gov.in/resource/$_resourceId?api-key=$_dataGovApiKey&format=json&limit=100";

  static List<MandiPrice> _cachedPrices = [];
  static MandiPriceSource _currentSource = MandiPriceSource.offlineCache;

  static MandiPriceSource get currentSource => _currentSource;
  static bool get isLive =>
      _currentSource == MandiPriceSource.dataGovLive ||
      _currentSource == MandiPriceSource.supabaseLive;

  /// Backward compatible getter
  static bool get isLiveFromDataGov => isLive;

  static String get liveStatusBannerText {
    switch (_currentSource) {
      case MandiPriceSource.dataGovLive:
        return "🟢 Live Mandi Prices from Data.gov.in / Agmarknet";
      case MandiPriceSource.supabaseLive:
        return "🟢 Live Mandi Prices from Agmarknet (Synced via Supabase)";
      case MandiPriceSource.offlineCache:
        return "🟡 Mandi APMC Benchmark Cache (Auto-syncs online)";
    }
  }

  /// Assigns appropriate commodity icon based on name
  static String getIconForCommodity(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('cotton')) return '🌱';
    if (lower.contains('soybean') || lower.contains('soya')) return '🫘';
    if (lower.contains('pomegranate') || lower.contains('anar')) return '🍎';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('wheat') || lower.contains('gehu')) return '🌾';
    if (lower.contains('rice') || lower.contains('paddy')) return '🍚';
    if (lower.contains('mango')) return '🥭';
    if (lower.contains('chilli') || lower.contains('mirchi')) return '🌶️';
    if (lower.contains('garlic') || lower.contains('lahsun')) return '🧄';
    if (lower.contains('ginger') || lower.contains('adrak')) return '🫚';
    if (lower.contains('maize') || lower.contains('corn')) return '🌽';
    return '🌾';
  }

  /// Fetches live Mandi Prices with 3-tier fallback:
  /// 1. Data.gov.in Agmarknet REST API
  /// 2. Supabase prices table
  /// 3. Realistic APMC benchmark cache
  static Future<List<MandiPrice>> fetchLiveMandiPrices({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPrices.isNotEmpty) {
      return _cachedPrices;
    }

    // 1. Try Data.gov.in API with responsive 3s timeout
    try {
      debugPrint("[MandiSyncDebug] Attempting direct Data.gov.in API fetch...");
      final response = await http
          .get(Uri.parse(_dataGovEndpoint))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final records = data['records'] as List?;

        if (records != null && records.isNotEmpty) {
          final List<MandiPrice> liveList = [];
          for (int i = 0; i < records.length; i++) {
            final r = records[i];
            final String comm = r['commodity']?.toString() ?? 'Commodity';
            final String mkt = r['market']?.toString() ?? 'Mandi';
            final String dist = r['district']?.toString() ?? 'Maharashtra';
            final String date = r['arrival_date']?.toString() ?? 'Today';

            double min = double.tryParse(r['min_price']?.toString() ?? '0') ?? 0;
            double modal = double.tryParse(r['modal_price']?.toString() ?? '0') ?? 0;
            double max = double.tryParse(r['max_price']?.toString() ?? '0') ?? 0;

            // Normalize quintal prices (> 100) to kg prices for clear retail/mandi comparison
            if (modal > 100) {
              min = min / 100.0;
              modal = modal / 100.0;
              max = max / 100.0;
            }

            liveList.add(MandiPrice(
              id: 'dg-$i-${comm.toLowerCase().replaceAll(' ', '')}',
              commodity: comm,
              commodityIcon: getIconForCommodity(comm),
              market: mkt,
              district: dist,
              minPrice: min,
              modalPrice: modal,
              maxPrice: max,
              unit: 'kg',
              date: date,
              source: 'Data.gov.in (Agmarknet Live)',
              trendPercent: 0.0,
            ));
          }

          if (liveList.isNotEmpty) {
            _cachedPrices = liveList;
            _currentSource = MandiPriceSource.dataGovLive;
            debugPrint("[MandiSyncDebug] Loaded ${liveList.length} live records from Data.gov.in");

            // Automatically persist live govt data to Supabase database in background
            SupabaseService.upsertMandiPrices(liveList);

            return liveList;
          }
        }
      }
    } catch (e) {
      debugPrint("[MandiSyncDebug] Data.gov.in API note (falling back to Supabase live prices table): $e");
    }

    // 2. Try Supabase prices table
    debugPrint("[MandiSyncDebug] Querying Supabase prices table...");
    final supaPrices = await SupabaseService.fetchMandiPrices();
    if (supaPrices.isNotEmpty) {
      _cachedPrices = supaPrices;
      _currentSource = MandiPriceSource.supabaseLive;
      debugPrint("[MandiSyncDebug] Successfully synced ${_cachedPrices.length} live records from Supabase prices table.");
      return supaPrices;
    }

    // 3. Fallback to Local APMC Mock Benchmark
    debugPrint("[MandiSyncDebug] Fallback to local APMC Benchmark cache.");
    _currentSource = MandiPriceSource.offlineCache;
    _cachedPrices = MockDataService.getMandiPrices();
    return _cachedPrices;
  }

  /// Synchronous filtered retrieval using latest cache
  static List<MandiPrice> getLatestMandiPrices({String query = "", String? district}) {
    List<MandiPrice> all = _cachedPrices.isNotEmpty ? _cachedPrices : MockDataService.getMandiPrices();
    if (query.trim().isNotEmpty) {
      all = all
          .where((p) =>
              p.commodity.toLowerCase().contains(query.toLowerCase()) ||
              p.market.toLowerCase().contains(query.toLowerCase()) ||
              p.district.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (district != null && district.isNotEmpty && district != "All") {
      all = all.where((p) => p.district.toLowerCase() == district.toLowerCase()).toList();
    }
    return all;
  }

  /// Find benchmark price for a given commodity
  static MandiPrice? getPriceForCommodity(String commodity) {
    final all = _cachedPrices.isNotEmpty ? _cachedPrices : MockDataService.getMandiPrices();
    try {
      return all.firstWhere(
        (p) => commodity.toLowerCase().contains(p.commodity.toLowerCase()) ||
               p.commodity.toLowerCase().contains(commodity.toLowerCase()),
      );
    } catch (_) {
      // Fallback: return first benchmark in cache
      return all.isNotEmpty ? all.first : null;
    }
  }
}
