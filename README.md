# تطبيق متابعة الطلبات للمدير (Android)

تطبيق إدارة احترافي باللغة التركية (مع العربية) — يستقبل إشعاراً وبانراً عند كل طلب
جديد، ويتيح التعديل الكامل أو الحذف، وكل تعديل يُكتب مباشرة في Google Sheets
(والمتصل بالموقع نفسه).

## مكونات المشروع
- `lib/` كود تطبيق Flutter كامل
- `google_apps_script/Code.gs` بوابة الربط مع Google Sheets
- `.github/workflows/build_apk.yml` بناء APK تلقائي مجاني على GitHub

## الخطوة 1 — ربط Google Sheets
1. افتح ملف Google Sheets الخاص بالطلبات.
2. من القائمة: Extensions ← Apps Script.
3. امسح أي كود موجود والصق محتوى `google_apps_script/Code.gs`.
4. عدّل `SHEET_NAME` و `ADMIN_USER` و `ADMIN_PASS`.
5. Deploy ← New deployment ← Web app:
   - Execute as: **Me**
   - Who has access: **Anyone**
6. انسخ رابط الـ Web App (ينتهي بـ /exec).

## الخطوة 2 — الحصول على ملف APK
### الطريقة (أ): عبر GitHub بدون حاسوب
1. أنشئ حساباً على github.com وأنشئ مستودعاً (Repository) جديداً خاصاً.
2. ارفع محتويات هذا المجلد إلى المستودع (Add file ← Upload files).
3. بعد ثوانٍ افتح تبويب **Actions** — ستجد workflow باسم "Build APK" يعمل تلقائياً.
4. عند انتهائه بالأخضر، افتح الـ Workflow ← Artifacts ← حمّل `admin-app-apk`.
   الملف بداخله اسمه `app-release.apk`.

### الطريقة (ب): على حاسوبك
1. ثبّت Flutter: https://docs.flutter.dev/get-started/install
2. داخل مجلد المشروع نفّذ:
   ```
   flutter create .
   flutter pub get
   flutter build apk --release
   ```
3. الملف الناتج: `build/app/outputs/flutter-apk/app-release.apk`

### الخطوة 3 — تعديل AndroidManifest
بعد `flutter create .` افتح `android/app/src/main/AndroidManifest.xml`
وأضف الأذونات الموجودة في `android_manifest_snippet.xml`.
(للصوت "Alarm" ضع ملف `alarm.mp3` في `android/app/src/main/res/raw/`)

## الخطوة 4 — التثبيت على الهاتف
1. انسخ ملف `app-release.apk` إلى هاتفك (واتساب / بريد / كابل USB).
2. افتح الملف من مدير الملفات.
3. عند الطلب، فعّل "التثبيت من مصادر غير معروفة" للمتصفح/مدير الملفات.
4. اضغط تثبيت، ثم افتح التطبيق.
5. أدخل رابط Apps Script + اسم المستخدم + كلمة المرور ← Giriş Yap.

## الأذونات التي يطلبها التطبيق وسببها
- **الإشعارات**: لإظهار تنبيه صوتي/بانر عند طلب جديد.
- **الاهتزاز**: اختياري من الإعدادات.
- **الهاتف (CALL_PHONE / DIAL)**: زر الاتصال بالعميل (مع نسخ الرقم تلقائياً).
- **الإنترنت**: المزامنة مع Google Sheets.
- **التشغيل في الخلفية (WorkManager)**: فحص الطلبات الجديدة كل 15 دقيقة
  (هذا أقل فاصل تسمح به أندرويد بدون خادم Firebase).

## ملاحظات
- الموقع + Google Sheets + التطبيق = مصدر بيانات واحد (الورقة)، أي تعديل
  من التطبيق يظهر فوراً في الشيت وفي الموقع.
- الفحص الفوري للطلبات الجديدة كل 30 ثانية أثناء فتح التطبيق، وكل 15 دقيقة
  في الخلفية. لإشعار لحظي 100% حتى وأنت بعيد تحتاج خادم Firebase Cloud
  Messaging — أخبرني إن أردت إضافته.