import 'package:flutter/material.dart';
import 'archive_screen.dart';
import 'calculator_tab.dart';
import 'debts_tab.dart';
import 'orders_tab.dart';
import 'settings_screen.dart';

/// الحاوية الرئيسية: تجمع الواجهات الثلاث + الأرشيف + الإعدادات
/// عبر شريط تنقل سفلي بتصميم Material 3
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    CalculatorTab(),
    DebtsTab(),
    OrdersTab(),
    ArchiveScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'الحاسبة'),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card), label: 'الديون'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.archive_outlined), selectedIcon: Icon(Icons.archive), label: 'الأرشيف'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
