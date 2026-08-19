import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/customer_debt.dart';
import '../models/delivery_person.dart';
import '../models/repair_order.dart';
import '../models/supplier_debt.dart';
import '../models/weekly_report.dart';

/// طبقة الوصول لقاعدة البيانات المحلية (SQLite عبر sqflite)
/// كل الجداول والاستعلامات موجودة هنا في مكان واحد لسهولة الصيانة.
class DBService {
  DBService._internal();
  static final DBService instance = DBService._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'phone_repair_manager.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE repair_orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerName TEXT NOT NULL,
            customerPhone TEXT NOT NULL,
            partName TEXT NOT NULL,
            purchasePrice REAL NOT NULL,
            sellingPrice REAL NOT NULL,
            deposit REAL NOT NULL,
            status TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            deliveredAt TEXT,
            archivedWeekId INTEGER,
            syncedToSheet INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE supplier_debts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            supplierName TEXT NOT NULL,
            amount REAL NOT NULL,
            note TEXT,
            isPaid INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE customer_debts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerName TEXT NOT NULL,
            customerPhone TEXT,
            amount REAL NOT NULL,
            note TEXT,
            isPaid INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE delivery_persons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            amountDue REAL NOT NULL,
            isPaid INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            paidAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE weekly_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weekNumber INTEGER NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            totalCollected REAL NOT NULL,
            myProfitCollected REAL NOT NULL,
            partnerProfitCollected REAL NOT NULL,
            totalCustomerDebtRemaining REAL NOT NULL,
            totalSupplierDebtRemaining REAL NOT NULL,
            ordersCount INTEGER NOT NULL,
            closedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ---------------------- طلبات الصيانة ----------------------

  Future<int> insertOrder(RepairOrder order) async {
    final db = await database;
    return db.insert('repair_orders', order.toMap()
      ..remove('id'));
  }

  Future<int> updateOrder(RepairOrder order) async {
    final db = await database;
    return db.update('repair_orders', order.toMap(),
        where: 'id = ?', whereArgs: [order.id]);
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return db.delete('repair_orders', where: 'id = ?', whereArgs: [id]);
  }

  /// الطلبات النشطة (غير المؤرشفة بعد) - تُعرض في واجهة إدارة الطلبات
  Future<List<RepairOrder>> getActiveOrders() async {
    final db = await database;
    final rows = await db.query(
      'repair_orders',
      where: 'archivedWeekId IS NULL',
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => RepairOrder.fromMap(r)).toList();
  }

  /// كل الطلبات (تُستخدم لحساب الديون الكلية وسجل العمليات)
  Future<List<RepairOrder>> getAllOrders() async {
    final db = await database;
    final rows = await db.query('repair_orders', orderBy: 'createdAt DESC');
    return rows.map((r) => RepairOrder.fromMap(r)).toList();
  }

  // ---------------------- ديون الموردين ----------------------

  Future<int> insertSupplierDebt(SupplierDebt debt) async {
    final db = await database;
    return db.insert('supplier_debts', debt.toMap()..remove('id'));
  }

  Future<int> updateSupplierDebt(SupplierDebt debt) async {
    final db = await database;
    return db.update('supplier_debts', debt.toMap(),
        where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<int> deleteSupplierDebt(int id) async {
    final db = await database;
    return db.delete('supplier_debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SupplierDebt>> getSupplierDebts() async {
    final db = await database;
    final rows = await db.query('supplier_debts', orderBy: 'createdAt DESC');
    return rows.map((r) => SupplierDebt.fromMap(r)).toList();
  }

  // ---------------------- ديون الزبائن اليدوية ----------------------

  Future<int> insertCustomerDebt(CustomerDebt debt) async {
    final db = await database;
    return db.insert('customer_debts', debt.toMap()..remove('id'));
  }

  Future<int> updateCustomerDebt(CustomerDebt debt) async {
    final db = await database;
    return db.update('customer_debts', debt.toMap(),
        where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<int> deleteCustomerDebt(int id) async {
    final db = await database;
    return db.delete('customer_debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CustomerDebt>> getCustomerDebts() async {
    final db = await database;
    final rows = await db.query('customer_debts', orderBy: 'createdAt DESC');
    return rows.map((r) => CustomerDebt.fromMap(r)).toList();
  }

  // ---------------------- عمال التوصيل ----------------------

  Future<int> insertDeliveryPerson(DeliveryPerson person) async {
    final db = await database;
    return db.insert('delivery_persons', person.toMap()..remove('id'));
  }

  Future<int> updateDeliveryPerson(DeliveryPerson person) async {
    final db = await database;
    return db.update('delivery_persons', person.toMap(),
        where: 'id = ?', whereArgs: [person.id]);
  }

  Future<int> deleteDeliveryPerson(int id) async {
    final db = await database;
    return db.delete('delivery_persons', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DeliveryPerson>> getDeliveryPersons() async {
    final db = await database;
    final rows = await db.query('delivery_persons', orderBy: 'createdAt DESC');
    return rows.map((r) => DeliveryPerson.fromMap(r)).toList();
  }

  // ---------------------- التقارير الأسبوعية (الأرشيف) ----------------------

  Future<int> insertWeeklyReport(WeeklyReport report) async {
    final db = await database;
    return db.insert('weekly_reports', report.toMap()..remove('id'));
  }

  Future<List<WeeklyReport>> getWeeklyReports() async {
    final db = await database;
    final rows = await db.query('weekly_reports', orderBy: 'closedAt DESC');
    return rows.map((r) => WeeklyReport.fromMap(r)).toList();
  }

  /// تنفيذ عملية الغلق الأسبوعي بشكل متكامل داخل معاملة واحدة (transaction)
  /// يحسب كل الأرقام المطلوبة، يحفظ التقرير، ثم يؤرشف الطلبات المُسلَّمة.
  Future<WeeklyReport> closeWeek({
    required int weekNumber,
    required DateTime startDate,
  }) async {
    final db = await database;

    final allOrders = await getAllOrders();
    final activeDeliveredThisWeek = allOrders
        .where((o) => o.archivedWeekId == null && o.status == OrderStatus.delivered)
        .toList();

    final totalCollected = activeDeliveredThisWeek.fold<double>(
        0, (sum, o) => sum + o.sellingPrice);
    final myProfitCollected = activeDeliveredThisWeek.fold<double>(
        0, (sum, o) => sum + o.myProfit);
    final partnerProfitCollected = activeDeliveredThisWeek.fold<double>(
        0, (sum, o) => sum + o.partnerProfit);

    // الكريدي المتبقي في السوق = كل الطلبات غير المسلَّمة وفيها مبلغ متبقٍ
    // + الديون اليدوية غير المدفوعة
    final outstandingFromOrders = allOrders
        .where((o) => o.status != OrderStatus.delivered && o.remaining > 0)
        .fold<double>(0, (sum, o) => sum + o.remaining);
    final manualCustomerDebts = await getCustomerDebts();
    final outstandingManual = manualCustomerDebts
        .where((d) => !d.isPaid)
        .fold<double>(0, (sum, d) => sum + d.amount);
    final totalCustomerDebtRemaining = outstandingFromOrders + outstandingManual;

    final supplierDebts = await getSupplierDebts();
    final totalSupplierDebtRemaining = supplierDebts
        .where((d) => !d.isPaid)
        .fold<double>(0, (sum, d) => sum + d.amount);

    final report = WeeklyReport(
      weekNumber: weekNumber,
      startDate: startDate,
      endDate: DateTime.now(),
      totalCollected: totalCollected,
      myProfitCollected: myProfitCollected,
      partnerProfitCollected: partnerProfitCollected,
      totalCustomerDebtRemaining: totalCustomerDebtRemaining,
      totalSupplierDebtRemaining: totalSupplierDebtRemaining,
      ordersCount: activeDeliveredThisWeek.length,
    );

    await db.transaction((txn) async {
      final reportId = await txn.insert(
        'weekly_reports',
        report.toMap()..remove('id'),
      );
      report.id = reportId;

      for (final order in activeDeliveredThisWeek) {
        await txn.update(
          'repair_orders',
          {'archivedWeekId': weekNumber},
          where: 'id = ?',
          whereArgs: [order.id],
        );
      }
    });

    return report;
  }
}
