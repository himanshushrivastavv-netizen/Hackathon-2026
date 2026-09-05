import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../schemes/schemes_list_screen.dart';
import 'farmer_home_screen.dart';
import 'farmer_profile_screen.dart';
import 'mandi_prices_screen.dart';
import 'sell_produce_screen.dart';
import 'my_listings_screen.dart';

class FarmerMainNav extends StatefulWidget {
  final AppState appState;
  final int initialIndex;

  const FarmerMainNav({
    super.key,
    required this.appState,
    this.initialIndex = 0,
  });

  @override
  State<FarmerMainNav> createState() => _FarmerMainNavState();
}

class _FarmerMainNavState extends State<FarmerMainNav> {
  late int _currentIndex;

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

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FarmerHomeScreen(
        appState: widget.appState,
        onTabSwitch: _switchTab,
      ),
      MandiPricesScreen(appState: widget.appState),
      SellProduceScreen(
        appState: widget.appState,
        onListingCreated: () {
          // Open My Listings screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyListingsScreen(appState: widget.appState),
            ),
          );
        },
      ),
      SchemesListScreen(appState: widget.appState),
      FarmerProfileScreen(appState: widget.appState),
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
          selectedItemColor: AppTheme.primaryGreen,
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
              icon: const Icon(Icons.trending_up_outlined),
              activeIcon: const Icon(Icons.trending_up),
              label: widget.appState.tr('nav_prices'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? AppTheme.primaryGreen : AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: _currentIndex == 2 ? Colors.white : AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              label: widget.appState.tr('nav_sell'),
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
