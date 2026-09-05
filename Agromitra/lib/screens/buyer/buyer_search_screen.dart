import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/search_bar_widget.dart';
import 'buyer_listing_details_screen.dart';

class BuyerSearchScreen extends StatefulWidget {
  final AppState appState;
  final String? initialQuery;

  const BuyerSearchScreen({super.key, required this.appState, this.initialQuery});

  @override
  State<BuyerSearchScreen> createState() => _BuyerSearchScreenState();
}

class _BuyerSearchScreenState extends State<BuyerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCommodity = "All";
  String _selectedDistrict = "All";
  String _selectedGrade = "All";
  String _selectedSort = "Newest";

  final List<String> _districts = ["All", "Thane", "Nashik", "Pune", "Solapur", "Latur", "Jalgaon"];
  final List<String> _commodities = ["All", "Tomato", "Onion", "Potato", "Pomegranate", "Soybean", "Cotton", "Wheat"];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter & Sort Produce",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Filter by District", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _districts.map((d) {
                        final isSel = _selectedDistrict == d;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(d),
                            selected: isSel,
                            onSelected: (selected) {
                              setSheetState(() => _selectedDistrict = d);
                              setState(() => _selectedDistrict = d);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Sort Order", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["Newest", "Price: Low to High", "Price: High to Low"].map((s) {
                      final isSel = _selectedSort == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSel,
                        onSelected: (selected) {
                          setSheetState(() => _selectedSort = s);
                          setState(() => _selectedSort = s);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                      child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ProduceListing> listings = widget.appState.listings.where((l) => l.status == ListingStatus.active).toList();

    // Filtering
    listings = listings.where((l) {
      final matchesQuery = _searchQuery.isEmpty ||
          l.commodity.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.district.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.village.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesComm = _selectedCommodity == "All" || l.commodity.toLowerCase().contains(_selectedCommodity.toLowerCase());
      final matchesDist = _selectedDistrict == "All" || l.district.toLowerCase() == _selectedDistrict.toLowerCase();
      final matchesGrade = _selectedGrade == "All" || l.qualityGrade.toLowerCase() == _selectedGrade.toLowerCase();
      return matchesQuery && matchesComm && matchesDist && matchesGrade;
    }).toList();

    // Sorting
    if (_selectedSort == "Price: Low to High") {
      listings.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
    } else if (_selectedSort == "Price: High to Low") {
      listings.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
    } else {
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('nav_search')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Column(
                children: [
                  SearchBarWidget(
                    hintText: widget.appState.tr('search_placeholder'),
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                    onFilterTap: _showFilterSheet,
                  ),
                  const SizedBox(height: 12),
                  // Commodity quick chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _commodities.map((comm) {
                        final isSel = _selectedCommodity == comm;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(comm),
                            selected: isSel,
                            onSelected: (selected) {
                              setState(() => _selectedCommodity = comm);
                            },
                            backgroundColor: AppTheme.scaffoldBackground,
                            selectedColor: AppTheme.primaryLight,
                            labelStyle: TextStyle(
                              color: isSel ? AppTheme.primaryGreen : AppTheme.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSel ? AppTheme.primaryGreen : AppTheme.borderColor,
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

            // Active Listings Result
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 50, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            "No harvest listings found",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Try searching another crop or district",
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                                _selectedCommodity = "All";
                                _selectedDistrict = "All";
                                _selectedGrade = "All";
                              });
                            },
                            child: const Text("Reset All Filters"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final item = listings[index];
                        return ListingCard(
                          listing: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuyerListingDetailsScreen(
                                  listing: item,
                                  appState: widget.appState,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
