/*************************************************
 * Google Apps Script - بوابة الربط بين الموقع وجوجل شيت والتطبيق
 * 1) افتح جدول Google Sheets الخاص بالطلبات
 * 2) Extensions > Apps Script
 * 3) الصق هذا الكود، عدّل اسم الورقة وبيانات الدخول
 * 4) Deploy > New deployment > Web app >
 *    Execute as: Me  |  Who has access: Anyone
 * 5) انسخ رابط Web App والصقه في التطبيق
 *************************************************/

const SHEET_NAME = 'Orders';        // <-- اسم ورقة الطلبات
const ADMIN_USER = 'admin';         // <-- اسم مستخدم المدير
const ADMIN_PASS = '123456';        // <-- كلمة المرور

// أرقام الأعمدة في الورقة (1 = العمود A)
const COLS = {
  ID: 1, DATE: 2, NAME: 3, PHONE: 4,
  ADDRESS: 5, ITEMS: 6, PRICE: 7, STATUS: 8, NOTES: 9
};

function doPost(e) {
  const b = JSON.parse(e.postData.contents);
  const sh = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
  const lastRow = sh.getLastRow();

  if (b.action === 'login') {
    return out({ ok: b.user === ADMIN_USER && b.pass === ADMIN_PASS });
  }

  if (b.action === 'orders') {
    if (lastRow < 2) return out({ orders: [] });
    const vals = sh.getRange(2, 1, lastRow - 1, 9).getValues();
    const orders = vals
      .map((r, i) => ({
        row: i + 2,
        id: String(r[COLS.ID - 1] || i + 2),
        date: fmtDate_(r[COLS.DATE - 1]),
        name: String(r[COLS.NAME - 1] || ''),
        phone: String(r[COLS.PHONE - 1] || ''),
        address: String(r[COLS.ADDRESS - 1] || ''),
        items: String(r[COLS.ITEMS - 1] || ''),
        price: String(r[COLS.PRICE - 1] || ''),
        status: String(r[COLS.STATUS - 1] || ''),
        notes: String(r[COLS.NOTES - 1] || '')
      }))
      .filter(o => o.name !== '');
    return out({ orders: orders });
  }

  if (b.action === 'update') {
    const row = Number(b.row);
    sh.getRange(row, COLS.DATE).setValue(b.date);
    sh.getRange(row, COLS.NAME).setValue(b.name);
    sh.getRange(row, COLS.PHONE).setValue(b.phone);
    sh.getRange(row, COLS.ADDRESS).setValue(b.address);
    sh.getRange(row, COLS.ITEMS).setValue(b.items);
    sh.getRange(row, COLS.PRICE).setValue(b.price);
    sh.getRange(row, COLS.STATUS).setValue(b.status);
    sh.getRange(row, COLS.NOTES).setValue(b.notes);
    return out({ ok: true });
  }

  if (b.action === 'delete') {
    sh.deleteRow(Number(b.row));
    return out({ ok: true });
  }

  return out({ ok: false });
}

function fmtDate_(d) {
  if (!d) return '';
  if (Object.prototype.toString.call(d) === '[object Date]') {
    return Utilities.formatDate(d, Session.getScriptTimeZone(), 'yyyy-MM-dd');
  }
  return String(d);
}

function out(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}