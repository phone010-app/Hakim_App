import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/pin_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const PhoneRepairApp());
}

class PhoneRepairApp extends StatelessWidget {
  const PhoneRepairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'إدارة محل الصيانة',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        // دعم الاتجاه من اليمين لليسار للغة العربية
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const _AppGate(),
      ),
    );
  }
}

/// بوابة الدخول: تعرض شاشة PIN أولاً، ثم الشاشة الرئيسية بعد النجاح
class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return PinScreen(onSuccess: () => setState(() => _unlocked = true));
    }

    final state = context.watch<AppState>();
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const HomeScreen();
  }
}
