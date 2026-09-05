import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import 'buyer_listing_details_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  final AppState appState;
  final void Function(int tabIndex)? onTabSwitch;
  final void Function(String query)? onSearchCommodity;

  const BuyerHomeScreen({
    super.key,
    required this.appState,
    this.onTabSwitch,
    this.onSearchCommodity,
  });

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final activeListings = appState.listings.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text("🏬", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, ${user?.name.split(' ').first ?? 'Amit'} 👋",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  "${user?.district ?? 'Thane'} Market Yard",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => appState.refreshListings(),
          color: const Color(0xFF1E88E5),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Hero Card
                _buildHeroSearch(context),

              const SizedBox(height: 24),

              // Featured Commodities
              Text(
                appState.tr('featured_commodities'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildCommodityCarousel(),

              const SizedBox(height: 24),

              // Recommended Agricultural Hubs
              Text(
                appState.tr('recommended_districts'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildDistrictHubs(),

              const SizedBox(height: 24),

              // Trending Harvest Listings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.tr('trending_listings'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onTabSwitch?.call(1), // Switch to Search tab
                    child: Text(
                      appState.tr('view_all'),
                      style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...activeListings.map((l) => ListingCard(
                    listing: l,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyerListingDetailsScreen(
                            listing: l,
                            appState: appState,
                          ),
                        ),
                      );
                    },
                  )),

              const SizedBox(height: 20),

              // Government Schemes Shortcut
              _buildSchemesShortcut(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}




  Widget _buildHeroSearch(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "DIRECT FROM FARMS",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Text("🚜", style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appState.tr('buyer_hero_title'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appState.tr('buyer_hero_subtitle'),
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          // Search Trigger Input
          InkWell(
            onTap: () => onTabSwitch?.call(1),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    appState.tr('search_placeholder'),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityCarousel() {
    final list = [
      {'name': 'Tomato', 'icon': '🍅'},
      {'name': 'Onion', 'icon': '🧅'},
      {'name': 'Potato', 'icon': '🥔'},
      {'name': 'Pomegranate', 'icon': '🍎'},
      {'name': 'Soybean', 'icon': '🫘'},
      {'name': 'Banana', 'icon': '🍌'},
      {'name': 'Cotton', 'icon': '🌱'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                onSearchCommodity?.call(item['name']!);
                onTabSwitch?.call(1);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 85,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      item['name']!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDistrictHubs() {
    final districts = [
      {'name': 'Nashik', 'crops': 'Onions, Grapes'},
      {'name': 'Thane', 'crops': 'Tomatoes, Veggies'},
      {'name': 'Pune', 'crops': 'Potatoes, Flowers'},
      {'name': 'Solapur', 'crops': 'Pomegranates'},
    ];

    return Row(
      children: districts.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () {
                onSearchCommodity?.call(d['name']!);
                onTabSwitch?.call(1);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d['crops']!,
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSchemesShortcut(BuildContext context) {
    return InkWell(
      onTap: () => onTabSwitch?.call(2), // Switch to Schemes Tab
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text("🇮🇳", style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Agricultural Schemes & Mandi Portal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Explore central and state agriculture initiatives",
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryGreen),
          ],
        ),
      ),
    );
  }
}
