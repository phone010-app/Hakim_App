import 'package:flutter/material.dart';
import '../services/pin_service.dart';

/// شاشة تُعرض عند بدء التطبيق: إما لإنشاء PIN لأول مرة أو للتحقق منه.
class PinScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const PinScreen({super.key, required this.onSuccess});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinService = PinService.instance;
  bool _loading = true;
  bool _isSetupMode = false;

  String _pin = '';
  String _confirmPin = '';
  bool _askingConfirm = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  Future<void> _checkPinExists() async {
    final exists = await _pinService.hasPin();
    setState(() {
      _isSetupMode = !exists;
      _loading = false;
    });
  }

  void _onDigit(String digit) {
    setState(() {
      _error = null;
      if (_isSetupMode && _askingConfirm) {
        if (_confirmPin.length < 4) _confirmPin += digit;
        if (_confirmPin.length == 4) _submitSetupConfirm();
      } else {
        if (_pin.length < 4) _pin += digit;
        if (_pin.length == 4) {
          if (_isSetupMode) {
            setState(() => _askingConfirm = true);
          } else {
            _submitVerify();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _error = null;
      if (_isSetupMode && _askingConfirm) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _submitSetupConfirm() async {
    if (_confirmPin == _pin) {
      await _pinService.setPin(_pin);
      widget.onSuccess();
    } else {
      setState(() {
        _error = 'الرمزان غير متطابقين، حاول مجدداً';
        _pin = '';
        _confirmPin = '';
        _askingConfirm = false;
      });
    }
  }

  Future<void> _submitVerify() async {
    final ok = await _pinService.verifyPin(_pin);
    if (ok) {
      widget.onSuccess();
    } else {
      setState(() {
        _error = 'رمز خاطئ، حاول مجدداً';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeLen =
        (_isSetupMode && _askingConfirm) ? _confirmPin.length : _pin.length;

    final title = !_isSetupMode
        ? 'أدخل رمز الدخول'
        : (_askingConfirm ? 'أعد إدخال الرمز للتأكيد' : 'أنشئ رمز دخول جديد (4 أرقام)');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('لحماية بيانات المحل والأرباح والديون',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < activeLen;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary, width: 1.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              const SizedBox(height: 24),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox.shrink();
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => k == '⌫' ? _onBackspace() : _onDigit(k),
            child: Center(
              child: Text(
                k,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
