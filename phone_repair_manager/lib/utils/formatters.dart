import 'package:intl/intl.dart';

/// غيّر "دج" هنا إلى رمز عملتك المحلي إن أردت (ريال، جنيه، دينار...)
const String currencySymbol = 'دج';

final NumberFormat _numberFormat = NumberFormat('#,##0.##', 'en');

String formatMoney(double amount) {
  return '${_numberFormat.format(amount)} $currencySymbol';
}

String formatDate(DateTime date) {
  return DateFormat('yyyy/MM/dd', 'en').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('yyyy/MM/dd - HH:mm', 'en').format(date);
}
