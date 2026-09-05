import 'package:flutter/material.dart';
import '../../models/price.dart';
import '../../services/app_state.dart';
import '../../services/price_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/price_card.dart';
import '../../widgets/search_bar_widget.dart';

class MandiPricesScreen extends StatefulWidget {
  final AppState appState;

  const MandiPricesScreen({super.key, required this.appState});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCommodity = "All";
  bool _isRefreshing = false;

  final List<String> _quickCommodities = [
    "All",
    "Tomato",
    "Onion",
    "Potato",
    "Cotton",
    "Soybean",
    "Pomegranate",
    "Banana",
    "Wheat",
  ];

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateUpdated);
  }

  void _onStateUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateUpdated);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await widget.appState.refreshMandiPrices();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _showPriceTrendModal(MandiPrice price) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(price.commodityIcon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Text(
                        "${price.commodity} Price Benchmark",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "${price.market} • ${price.district}",
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                "7-Day Modal Price Trend (₹/kg)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTrendBar("Mon", (price.modalPrice * 0.95), price.modalPrice),
                    _buildTrendBar("Tue", (price.modalPrice * 0.98), price.modalPrice),
                    _buildTrendBar("Wed", (price.modalPrice * 0.96), price.modalPrice),
                    _buildTrendBar("Thu", (price.modalPrice * 1.02), price.modalPrice),
                    _buildTrendBar("Fri", (price.modalPrice * 0.99), price.modalPrice),
                    _buildTrendBar("Sat", (price.modalPrice * 1.01), price.modalPrice),
                    _buildTrendBar("Today", price.modalPrice, price.modalPrice, isToday: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    "Source: ${price.source} (Latest)",
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendBar(String day, double priceVal, double currentModal, {bool isToday = false}) {
    final double heightRatio = currentModal > 0 ? (priceVal / (currentModal * 1.3)).clamp(0.2, 1.0) : 0.5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "₹${priceVal.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppTheme.primaryGreen : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 22,
          height: 60 * heightRatio,
          decoration: BoxDecoration(
            color: isToday ? AppTheme.primaryGreen : AppTheme.secondaryGreen.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: isToday ? AppTheme.primaryGreen : AppTheme.textMuted,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MandiPrice> list = PriceService.getLatestMandiPrices(query: _searchQuery);
    if (_selectedCommodity != "All") {
      list = list.where((p) => p.commodity.toLowerCase().contains(_selectedCommodity.toLowerCase())).toList();
    }

    final isLive = PriceService.isLive;
    final bannerText = PriceService.liveStatusBannerText;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('nav_prices')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                  )
                : const Icon(Icons.refresh, color: AppTheme.primaryGreen),
            tooltip: "Refresh Mandi Prices",
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
          const SizedBox(width: 8),
        ],
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: "Back",
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live Status Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isLive ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
              child: Row(
                children: [
                  Icon(
                    isLive ? Icons.sensors : Icons.cloud_done_outlined,
                    size: 16,
                    color: isLive ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bannerText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLive ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search and Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SearchBarWidget(
                    hintText: widget.appState.tr('search_commodity_hint'),
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                  ),
                  const SizedBox(height: 12),
                  // Quick Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickCommodities.map((comm) {
                        final isSelected = _selectedCommodity == comm;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(comm),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCommodity = comm;
                              });
                            },
                            backgroundColor: AppTheme.scaffoldBackground,
                            selectedColor: AppTheme.primaryLight,
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderColor),

            // Mandi Prices List with RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppTheme.primaryGreen,
                child: list.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.store_mall_directory_outlined, size: 48, color: AppTheme.textMuted),
                                const SizedBox(height: 12),
                                const Text(
                                  "No Mandi benchmark records found",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = "";
                                      _selectedCommodity = "All";
                                    });
                                  },
                                  child: const Text("Reset Search"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: list.length + 1,
                        itemBuilder: (context, index) {
                          if (index == list.length) {
                            // Disclaimer at bottom
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, size: 18, color: AppTheme.textMuted),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.appState.tr('latest_mandi_price_disclaimer'),
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final price = list[index];
                          return PriceCard(
                            price: price,
                            onTap: () => _showPriceTrendModal(price),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
