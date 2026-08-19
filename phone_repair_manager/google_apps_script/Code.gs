/**
 * ============================================================
 *  سكريبت ربط تطبيق "إدارة محل الصيانة" بـ Google Sheets
 * ============================================================
 * طريقة الاستخدام موضحة بالتفصيل في ملف README.md
 *
 * هذا السكريبت يستقبل طلبات POST من التطبيق (JSON) ويقوم بـ:
 *  - إنشاء الأوراق (Sheets) المطلوبة تلقائياً إن لم تكن موجودة
 *  - إضافة صف جديد في الورقة المناسبة حسب نوع البيانات "type"
 * ============================================================
 */

function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    const type = data.type;

    switch (type) {
      case 'operation':
        writeOperation(data);
        break;
      case 'weekly_report':
        writeWeeklyReport(data);
        break;
      case 'supplier_debt':
        writeSupplierDebt(data);
        break;
      case 'customer_debt':
        writeCustomerDebt(data);
        break;
      case 'delivery_payment':
        writeDeliveryPayment(data);
        break;
      default:
        return jsonResponse({ ok: false, error: 'نوع بيانات غير معروف: ' + type });
    }

    return jsonResponse({ ok: true });
  } catch (err) {
    return jsonResponse({ ok: false, error: err.toString() });
  }
}

// دالة اختبارية بسيطة للتأكد أن الرابط يعمل عند فتحه في المتصفح
function doGet(e) {
  return ContentService.createTextOutput(
    'تطبيق إدارة محل الصيانة متصل بنجاح بهذا السكريبت ✅'
  );
}

function jsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function getOrCreateSheet(name, headers) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(name);
  if (!sheet) {
    sheet = ss.insertSheet(name);
    sheet.appendRow(headers);
    sheet.setFrozenRows(1);
    sheet.getRange(1, 1, 1, headers.length).setFontWeight('bold');
  }
  return sheet;
}

// ---------------------- عمليات الصيانة اليومية ----------------------
function writeOperation(d) {
  const sheet = getOrCreateSheet('العمليات', [
    'المعرف', 'اسم الزبون', 'الهاتف', 'القطعة', 'سعر الشراء',
    'سعر البيع', 'العربون', 'المتبقي', 'الفائدة الإجمالية',
    'فائدتي', 'فائدة الشريك', 'الحالة', 'تاريخ الإنشاء'
  ]);
  sheet.appendRow([
    d.id, d.customerName, d.customerPhone, d.partName, d.purchasePrice,
    d.sellingPrice, d.deposit, d.remaining, d.totalProfit,
    d.myProfit, d.partnerProfit, statusLabel(d.status), d.createdAt
  ]);
}

function statusLabel(status) {
  if (status === 'pending') return 'قيد التصليح';
  if (status === 'ready') return 'بانتظار الزبون';
  if (status === 'delivered') return 'تم التسليم والقبض';
  return status;
}

// ---------------------- التقارير الأسبوعية ----------------------
function writeWeeklyReport(d) {
  const sheet = getOrCreateSheet('التقارير الأسبوعية', [
    'رقم الأسبوع', 'من تاريخ', 'إلى تاريخ', 'عدد العمليات',
    'إجمالي المقبوض', 'فائدتي المقبوضة', 'فائدة الشريك المقبوضة',
    'الكريدي المتبقي عند الزبائن', 'الديون المتبقية للموردين', 'تاريخ الغلق'
  ]);
  sheet.appendRow([
    d.weekNumber, d.startDate, d.endDate, d.ordersCount,
    d.totalCollected, d.myProfitCollected, d.partnerProfitCollected,
    d.totalCustomerDebtRemaining, d.totalSupplierDebtRemaining, d.closedAt
  ]);
}

// ---------------------- ديون الموردين ----------------------
function writeSupplierDebt(d) {
  const sheet = getOrCreateSheet('ديون الموردين', [
    'المعرف', 'اسم المورد', 'المبلغ', 'ملاحظة', 'مدفوع؟', 'التاريخ'
  ]);
  sheet.appendRow([
    d.id, d.supplierName, d.amount, d.note, d.isPaid ? 'نعم' : 'لا', d.createdAt
  ]);
}

// ---------------------- ديون الزبائن اليدوية ----------------------
function writeCustomerDebt(d) {
  const sheet = getOrCreateSheet('ديون الزبائن اليدوية', [
    'المعرف', 'اسم الزبون', 'الهاتف', 'المبلغ', 'ملاحظة', 'مدفوع؟', 'التاريخ'
  ]);
  sheet.appendRow([
    d.id, d.customerName, d.customerPhone, d.amount, d.note,
    d.isPaid ? 'نعم' : 'لا', d.createdAt
  ]);
}

// ---------------------- أجور التوصيل ----------------------
function writeDeliveryPayment(d) {
  const sheet = getOrCreateSheet('أجور التوصيل', [
    'المعرف', 'الاسم', 'المبلغ المستحق', 'مدفوع؟', 'تاريخ الإضافة', 'تاريخ الدفع'
  ]);
  sheet.appendRow([
    d.id, d.name, d.amountDue, d.isPaid ? 'نعم' : 'لا', d.createdAt, d.paidAt || ''
  ]);
}
