import 'package:flutter/material.dart';
import 'screens/language/language_screen.dart';
import 'services/app_state.dart';
import 'services/supabase_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const AgroMitraApp());
}


class AgroMitraApp extends StatefulWidget {
  const AgroMitraApp({super.key});

  @override
  State<AgroMitraApp> createState() => _AgroMitraAppState();
}

class _AgroMitraAppState extends State<AgroMitraApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _appState.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroMitra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LanguageScreen(appState: _appState),
    );
  }
}
