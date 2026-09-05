import 'package:flutter/material.dart';
import '../../models/scheme.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/scheme_card.dart';
import '../../widgets/search_bar_widget.dart';
import 'scheme_details_screen.dart';

class SchemesListScreen extends StatefulWidget {
  final AppState appState;

  const SchemesListScreen({super.key, required this.appState});

  @override
  State<SchemesListScreen> createState() => _SchemesListScreenState();
}

class _SchemesListScreenState extends State<SchemesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _categories = [
    {'id': 'All', 'label': 'category_all'},
    {'id': 'Subsidy', 'label': 'category_subsidy'},
    {'id': 'Insurance', 'label': 'category_insurance'},
    {'id': 'Loan', 'label': 'category_loan'},
    {'id': 'Women', 'label': 'category_women'},
    {'id': 'Organic', 'label': 'category_organic'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String selectedCat = widget.appState.selectedSchemeCategory;

    // Filter schemes
    List<GovernmentScheme> filtered = widget.appState.schemes.where((s) {
      final matchesCat = selectedCat == 'All' || s.category.toLowerCase() == selectedCat.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('schemes_title')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Category Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appState.tr('schemes_subtitle'),
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  SearchBarWidget(
                    hintText: "Search schemes (e.g. PM-KISAN, Solar, PMFBY)...",
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final bool isSelected = selectedCat == cat['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(widget.appState.tr(cat['label']!)),
                            selected: isSelected,
                            onSelected: (selected) {
                              widget.appState.setSchemeCategory(cat['id']!);
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

            // Schemes List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            "No schemes found matching your search",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.appState.setSchemeCategory('All');
                              setState(() => _searchQuery = "");
                            },
                            child: const Text("Reset Filters"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final scheme = filtered[index];
                        return SchemeCard(
                          scheme: scheme,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchemeDetailsScreen(
                                  scheme: scheme,
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
