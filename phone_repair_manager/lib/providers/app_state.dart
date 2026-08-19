import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_debt.dart';
import '../models/delivery_person.dart';
import '../models/repair_order.dart';
import '../models/supplier_debt.dart';
import '../models/weekly_report.dart';
import '../services/db_service.dart';
import '../services/sheets_service.dart';

/// الحالة المركزية للتطبيق — كل الشاشات تقرأ وتُحدّث بياناتها من هنا.
/// يحافظ هذا على فصل واضح بين الواجهات ومنطق قاعدة البيانات.
class AppState extends ChangeNotifier {
  final DBService _db = DBService.instance;
  final SheetsService _sheets = SheetsService.instance;

  List<RepairOrder> orders = [];
  List<SupplierDebt> supplierDebts = [];
  List<CustomerDebt> customerDebts = [];
  List<DeliveryPerson> deliveryPersons = [];
  List<WeeklyReport> weeklyReports = [];

  int currentWeekNumber = 1;
  DateTime currentWeekStart = DateTime.now();
  bool isLoading = true;

  static const _weekNumberKey = 'current_week_number';
  static const _weekStartKey = 'current_week_start';

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    currentWeekNumber = prefs.getInt(_weekNumberKey) ?? 1;
    final startStr = prefs.getString(_weekStartKey);
    currentWeekStart =
        startStr != null ? DateTime.parse(startStr) : DateTime.now();

    await refreshAll();

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    orders = await _db.getActiveOrders();
    supplierDebts = await _db.getSupplierDebts();
    customerDebts = await _db.getCustomerDebts();
    deliveryPersons = await _db.getDeliveryPersons();
    weeklyReports = await _db.getWeeklyReports();
    notifyListeners();
  }

  // ---------------------- طلبات الصيانة ----------------------

  Future<void> addOrder(RepairOrder order) async {
    final id = await _db.insertOrder(order);
    order.id = id;
    // إرسال نسخة إلى جوجل شيت (لا يوقف التطبيق إن فشل الاتصال)
    _sheets.sendData(order.toSheetJson());
    await refreshAll();
  }

  Future<void> updateOrderStatus(RepairOrder order, String newStatus) async {
    final updated = order.copyWith(
      status: newStatus,
      deliveredAt: newStatus == OrderStatus.delivered ? DateTime.now() : null,
    );
    await _db.updateOrder(updated);
    _sheets.sendData(updated.toSheetJson());
    await refreshAll();
  }

  Future<void> deleteOrder(RepairOrder order) async {
    if (order.id != null) {
      await _db.deleteOrder(order.id!);
      await refreshAll();
    }
  }

  // ---------------------- ديون الموردين ----------------------

  Future<void> addSupplierDebt(SupplierDebt debt) async {
    final id = await _db.insertSupplierDebt(debt);
    debt.id = id;
    _sheets.sendData(debt.toSheetJson());
    await refreshAll();
  }

  Future<void> markSupplierDebtPaid(SupplierDebt debt) async {
    debt.isPaid = true;
    await _db.updateSupplierDebt(debt);
    _sheets.sendData(debt.toSheetJson());
    await refreshAll();
  }

  Future<void> deleteSupplierDebt(SupplierDebt debt) async {
    if (debt.id != null) {
      await _db.deleteSupplierDebt(debt.id!);
      await refreshAll();
    }
  }

  // ---------------------- ديون الزبائن اليدوية ----------------------

  Future<void> addCustomerDebt(CustomerDebt debt) async {
    final id = await _db.insertCustomerDebt(debt);
    debt.id = id;
    _sheets.sendData(debt.toSheetJson());
    await refreshAll();
  }

  Future<void> markCustomerDebtPaid(CustomerDebt debt) async {
    debt.isPaid = true;
    await _db.updateCustomerDebt(debt);
    _sheets.sendData(debt.toSheetJson());
    await refreshAll();
  }

  Future<void> deleteCustomerDebt(CustomerDebt debt) async {
    if (debt.id != null) {
      await _db.deleteCustomerDebt(debt.id!);
      await refreshAll();
    }
  }

  /// كل ديون الزبائن مجتمعة: الناتجة تلقائياً من طلبات الصيانة + اليدوية
  List<Map<String, dynamic>> get combinedCustomerDebts {
    final fromOrders = orders
        .where((o) => o.status != OrderStatus.delivered && o.remaining > 0)
        .map((o) => {
              'source': 'order',
              'name': o.customerName,
              'phone': o.customerPhone,
              'amount': o.remaining,
              'note': o.partName,
              'order': o,
            })
        .toList();
    final manual = customerDebts.where((d) => !d.isPaid).map((d) => {
          'source': 'manual',
          'name': d.customerName,
          'phone': d.customerPhone,
          'amount': d.amount,
          'note': d.note,
          'debt': d,
        });
    return [...fromOrders, ...manual];
  }

  double get totalCustomerDebt => combinedCustomerDebts.fold<double>(
      0, (sum, item) => sum + (item['amount'] as double));

  double get totalSupplierDebt => supplierDebts
      .where((d) => !d.isPaid)
      .fold<double>(0, (sum, d) => sum + d.amount);

  // ---------------------- عمال التوصيل ----------------------

  Future<void> addDeliveryPerson(DeliveryPerson person) async {
    final id = await _db.insertDeliveryPerson(person);
    person.id = id;
    _sheets.sendData(person.toSheetJson());
    await refreshAll();
  }

  Future<void> markDeliveryPaid(DeliveryPerson person) async {
    person.isPaid = true;
    person.paidAt = DateTime.now();
    await _db.updateDeliveryPerson(person);
    _sheets.sendData(person.toSheetJson());
    await refreshAll();
  }

  Future<void> deleteDeliveryPerson(DeliveryPerson person) async {
    if (person.id != null) {
      await _db.deleteDeliveryPerson(person.id!);
      await refreshAll();
    }
  }

  // ---------------------- الغلق الأسبوعي ----------------------

  Future<WeeklyReport> closeCurrentWeek() async {
    final report = await _db.closeWeek(
      weekNumber: currentWeekNumber,
      startDate: currentWeekStart,
    );
    _sheets.sendData(report.toSheetJson());

    // الانتقال إلى أسبوع جديد
    final prefs = await SharedPreferences.getInstance();
    currentWeekNumber += 1;
    currentWeekStart = DateTime.now();
    await prefs.setInt(_weekNumberKey, currentWeekNumber);
    await prefs.setString(_weekStartKey, currentWeekStart.toIso8601String());

    await refreshAll();
    return report;
  }
}
