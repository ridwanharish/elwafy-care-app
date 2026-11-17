import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'state/elwafy_store.dart';
import 'theme/elwafy_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElwafyCareApp());
}

class ElwafyCareApp extends StatefulWidget {
  /// Set false pada widget test agar tidak ada timer splash yang menggantung.
  final bool showSplash;

  const ElwafyCareApp({super.key, this.showSplash = true});

  @override
  State<ElwafyCareApp> createState() => _ElwafyCareAppState();
}

class _ElwafyCareAppState extends State<ElwafyCareApp> {
  late final ElwafyStore _store;

  @override
  void initState() {
    super.initState();
    _store = ElwafyStore();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elwafy Care — Mom, Kids & Baby Spa',
      debugShowCheckedModeBanner: false,
      theme: ElwafyTheme.lightTheme,
      home: MainShell(store: _store, showSplash: widget.showSplash),
    );
  }
}
