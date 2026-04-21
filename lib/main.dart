import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/core/app_config.dart';
import 'src/core/app_state.dart';
import 'src/core/app_theme.dart';
import 'src/features/auth/auth_screen.dart';
import 'src/features/auth/splash_screen.dart';
import 'src/features/account/account_screen.dart';
import 'src/features/cart/cart_screen.dart';
import 'src/features/catalog/catalog_screen.dart';
import 'src/features/orders/orders_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: const CuratedStoreCustomersApp(),
    ),
  );
}

class CuratedStoreCustomersApp extends StatelessWidget {
  const CuratedStoreCustomersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const _RootGate(),
    );
  }
}

class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(onFinished: () => setState(() => _splashDone = true));
    }

    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isAuthenticated) {
          return const AuthScreen();
        }
        return const _AppShell();
      },
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = <Widget>[
    CatalogScreen(),
    CartScreen(),
    OrdersScreen(),
    AccountScreen(),
  ];

  static const List<String> _titles = <String>[
    'Discover',
    'Cart',
    'Orders',
    'Account',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
