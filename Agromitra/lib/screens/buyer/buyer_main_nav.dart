import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../schemes/schemes_list_screen.dart';
import 'buyer_home_screen.dart';
import 'buyer_profile_screen.dart';
import 'buyer_search_screen.dart';

class BuyerMainNav extends StatefulWidget {
  final AppState appState;
  final int initialIndex;

  const BuyerMainNav({
    super.key,
    required this.appState,
    this.initialIndex = 0,
  });

  @override
  State<BuyerMainNav> createState() => _BuyerMainNavState();
}

class _BuyerMainNavState extends State<BuyerMainNav> {
  late int _currentIndex;
  String? _prefilledSearchQuery;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _switchTab(int index, {String? searchQuery}) {
    setState(() {
      _currentIndex = index;
      if (searchQuery != null) {
        _prefilledSearchQuery = searchQuery;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color buyerColor = Color(0xFF1E88E5);

    final List<Widget> screens = [
      BuyerHomeScreen(
        appState: widget.appState,
        onTabSwitch: (idx) => _switchTab(idx),
        onSearchCommodity: (query) => _switchTab(1, searchQuery: query),
      ),
      BuyerSearchScreen(
        appState: widget.appState,
        initialQuery: _prefilledSearchQuery,
      ),
      SchemesListScreen(appState: widget.appState),
      BuyerProfileScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: buyerColor,
          unselectedItemColor: AppTheme.textMuted,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: widget.appState.tr('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              activeIcon: const Icon(Icons.search, color: buyerColor),
              label: widget.appState.tr('nav_search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_outlined),
              activeIcon: const Icon(Icons.account_balance),
              label: widget.appState.tr('nav_schemes'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: widget.appState.tr('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
