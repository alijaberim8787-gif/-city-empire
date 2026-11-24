import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const GamePartyApp());
}

// ==================== COLORS & THEME ====================
class AppColors {
  static const bg = Color(0xFF090713);
  static const cardBg = Color(0xFF171128);
  static const purple = Color(0xFF8B35F5);
  static const gold = Color(0xFFFFBF36);
  static const spyRed = Color(0xFFF52D4F);
  static const pantoBlue = Color(0xFF2585FF);
  static const textSub = Color(0xFFA7A0B8);
  static const green = Color(0xFF4CAF50);
}

// ==================== SETTINGS STATE ====================
class AppSettings {
  static bool soundOn = true;
  static bool vibrationOn = true;
  static int totalGames = 0;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    soundOn = prefs.getBool('sound') ?? true;
    vibrationOn = prefs.getBool('vibration') ?? true;
    totalGames = prefs.getInt('totalGames') ?? 0;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', soundOn);
    await prefs.setBool('vibration', vibrationOn);
    await prefs.setInt('totalGames', totalGames);
  }

  static void vibrate() {
    if (vibrationOn) HapticFeedback.mediumImpact();
  }
}

class GamePartyApp extends StatefulWidget {
  const GamePartyApp({super.key});
  @override
  State<GamePartyApp> createState() => _GamePartyAppState();
}

class _GamePartyAppState extends State<GamePartyApp> {
  @override
  void initState() {
    super.initState();
    AppSettings.load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'گیم پارتی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        }),
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale, _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scale = Tween(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glow = Tween(begin: 0.1, end: 0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 3), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/6.png'), fit: BoxFit.cover, opacity: 0.5),
          gradient: RadialGradient(colors: [Color(0xFF2A1548), AppColors.bg], radius: 1.2),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(_glow.value), blurRadius: 50, spreadRadius: 20)],
                ),
                child: ScaleTransition(scale: _scale, child: Image.asset('assets/images/1.png', width: 250)),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/6.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/images/4.png', width: 40),
                      onPressed: () { AppSettings.vibrate(); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_book, color: AppColors.textSub, size: 30),
                          onPressed: () { AppSettings.vibrate(); Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())); },
                        ),
                        IconButton(
                          icon: const Icon(Icons.bar_chart, color: AppColors.textSub, size: 30),
                          onPressed: () { AppSettings.vibrate(); Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())); },
                        ),
                      ],
                    ),
                    Image.asset('assets/images/5.png', width: 40),
                  ],
                ),
              ),
              Image.asset('assets/images/1.png', width: 260),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Expanded(child: _buildCard(context, 'assets/images/2.png', () { AppSettings.vibrate(); Navigator.push(context, MaterialPageRoute(builder: (_) => const SpySetupScreen())); })),
                      const SizedBox(height: 16),
                      Expanded(child: _buildCard(context, 'assets/images/3.png', () { AppSettings.vibrate(); Navigator.push(context, MaterialPageRoute(builder: (_) => const PantoSetupScreen())); })),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: image,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset(image, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}

// ==================== STATS SCREEN ====================
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('آمار بازی‌ها'), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports, size: 80, color: AppColors.gold),
            const SizedBox(height: 20),
            const Text('تعداد کل بازی‌های انجام شده', style: TextStyle(fontSize: 18, color: AppColors.textSub)),
            const SizedBox(height: 10),
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final total = snapshot.data!.getInt('totalGames') ?? 0;
                return Text('$total', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: AppColors.purple));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('صدای بازی'),
            secondary: const Icon(Icons.volume_up, color: AppColors.purple),
            activeColor: AppColors.purple,
            value: AppSettings.soundOn,
            onChanged: (val) { setState(() => AppSettings.soundOn = val); AppSettings.save(); AppSettings.vibrate(); },
          ),
          SwitchListTile(
            title: const Text('لرزش (ویبره)'),
            secondary: const Icon(Icons.vibration, color: AppColors.purple),
            activeColor: AppColors.purple,
            value: AppSettings.vibrationOn,
            onChanged: (val) { setState(() => AppSettings.vibrationOn = val); AppSettings.save(); AppSettings.vibrate(); },
          ),
          const Divider(color: AppColors.cardBg),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('پاک کردن آمار', style: TextStyle(color: Colors.red)),
            onTap: () {
              AppSettings.vibrate();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.cardBg,
                  title: const Text('مطمئنی؟'),
                  content: const Text('تمام آمارهای بازی شما پاک خواهد شد.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
                    TextButton(onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if(context.mounted) Navigator.pop(ctx);
                    }, child: const Text('بله', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
          const Divider(color: AppColors.cardBg),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.textSub),
            title: Text('درباره گیم پارتی'),
            subtitle: Text('نسخه 4.0.0 - آپدیت دیتابیس کلمات', style: TextStyle(color: AppColors.textSub)),
          ),
        ],
      ),
    );
  }
}

// ==================== DATA MODELS & DATABASE ====================
class PantoWord {
  final String word;
  final int diff;
  const PantoWord(this.word, this.diff);
}

// 10 Spy Categories
const spyData = {
  'مکان‌ها': ['بیمارستان', 'فرودگاه', 'دانشگاه', 'رستوران', 'پارک', 'کافه', 'سینما', 'کتابخانه', 'بانک', 'هتل', 'موزه', 'بازار', 'زندان', 'مدرسه', 'پارکینگ', 'پمپ بنزین', 'داروخانه', 'باشگاه ورزشی', 'استادیوم', 'تئاتر'],
  'سفر': ['کوه', 'جنگل', 'ساحل', 'بیابان', 'جزیره', 'دریاچه', 'تونل', 'ایستگاه قطار', 'کشتی', 'قطار', 'هواپیما', 'اتوبوس', 'متریو', 'تاکسی', 'دوچرخه', 'کوله‌پشتی', 'چادر', 'نقشه', 'قطب‌نما', 'بلیط'],
  'غذا': ['پیتزا', 'کباب', 'قورمه سبزی', 'آش رشته', 'فسنجان', 'املت', 'سالاد', 'سوشی', 'برگر', 'ماکارونی', 'جوجه کباب', 'قیمه', 'عدس پلو', 'زرشک پلو', 'باقالی پلو', 'دلمه', 'کوکو', 'کشک بادمجان', 'میگو', 'ماهی'],
  'حیوانات': ['شیر', 'فیل', 'زرافه', 'پنگوئن', 'دلفین', 'طوطی', 'کوالا', 'گربه', 'خرس', 'کبوتر', 'ببر', 'پلنگ', 'گرگ', 'روباه', 'اسب', 'گاو', 'گوسفند', 'مرغ', 'اردک', 'عقاب'],
  'مشاغل': ['دکتر', 'معلم', 'خلبان', 'آشپز', 'بازیگر', 'راننده', 'پلیس', 'نقاش', 'خبرنگار', 'خواننده', 'مهندس', 'وکیل', 'پرستار', 'آتش‌نشان', 'نجار', 'بنا', 'خیاط', 'آرایشگر', 'عکاس', 'کشاورز'],
  'اشیاء': ['چتر', 'عینک', 'ساعت', 'کیف', 'لپ‌تاپ', 'صندلی', 'ماشین', 'آینه', 'چاقو', 'کلید', 'تلفن', 'دفتر', 'مداد', 'کتاب', 'توپ', 'پنجره', 'در', 'دیوار', 'فرش', 'لامپ'],
  'فیلم': ['تایتانیک', 'آواتار', 'ماتریکس', 'شرک', 'شیر شاه', 'هری پاتر', 'فروزن', 'جوراسیک پارک', 'انتقام‌جویان', 'بتمن', 'سوپرمن', 'مرد عنکبوتی', 'دزدان دریایی', 'جنگ ستارگان', 'ارباب حلقه‌ها', 'هالک', 'آیرون من', 'مرد مورچه‌ای', 'پاندای کونگ‌فوکار', 'ماداگاسکار'],
  'ورزش': ['فوتبال', 'والیبال', 'بسکتبال', 'شنا', 'شطرنج', 'کاراته', 'تنیس', 'کوهنوردی', 'بوکس', 'کشتی', 'ژیمناستیک', 'دوچرخه‌سواری', 'اسکی', 'اسکیت', 'گلف', 'بیسبال', 'هاکی', 'بولینگ', 'تیراندازی', 'شمشیربازی'],
  'احساسات': ['عصبانی', 'خسته', 'ترسیده', 'عاشق', 'مغرور', 'حسود', 'خوشحال', 'غمگین', 'هیجان‌زده', 'نگران', 'شگفت‌زده', 'آرام', 'بی‌حوصله', 'دلواپس', 'شرمنده', 'مضطرب', 'امیدوار', 'ناامید', 'متعجب', 'راضی'],
  'تکنولوژی': ['کامپیوتر', 'موبایل', 'تبلت', 'هدفون', 'دوربین', 'پرینتر', 'مودم', 'فلش', 'هارد', 'کیبورد', 'ماوس', 'مانیتور', 'باتری', 'شارژر', 'رام', 'سی‌پی‌یو', 'کارت گرافیک', 'بلندگو', 'میکروفون', 'ساعت هوشمند'],
};

// 10 Pantomime Categories
const pantoData = {
  'عمومی': [PantoWord('دویدن', 1), PantoWord('شیر', 1), PantoWord('دکتر', 1), PantoWord('چتر', 1), PantoWord('خوشحال', 2), PantoWord('رقصیدن', 2), PantoWord('کتاب خواندن', 1), PantoWord('غذا خوردن', 1), PantoWord('خوابیدن', 1), PantoWord('مسواک زدن', 1), PantoWord('گوش دادن به موسیقی', 2), PantoWord('تلفن زدن', 2), PantoWord('رانندگی', 2), PantoWord('آشپزی', 2), PantoWord('خرید کردن', 2), PantoWord('عکاسی', 2), PantoWord('نقاشی کشیدن', 2), PantoWord('باغبانی', 3), PantoWord('تمیز کردن خانه', 3), PantoWord('منتظر ماندن', 3)],
  'فیلم و سریال': [PantoWord('شرک', 2), PantoWord('آواتار', 2), PantoWord('تایتانیک', 2), PantoWord('ماتریکس', 3), PantoWord('شیر شاه', 3), PantoWord('هری پاتر', 3), PantoWord('فروزن', 2), PantoWord('جوراسیک پارک', 3), PantoWord('بتمن', 2), PantoWord('سوپرمن', 2), PantoWord('مرد عنکبوتی', 2), PantoWord('دزدان دریایی کارائیب', 3), PantoWord('جنگ ستارگان', 3), PantoWord('ارباب حلقه‌ها', 3), PantoWord('انتقام‌جویان', 3), PantoWord('ماداگاسکار', 2), PantoWord('پاندای کونگ‌فوکار', 2), PantoWord('هالک', 2), PantoWord('آیرون من', 2), PantoWord('مرد مورچه‌ای', 3)],
  'ضرب‌المثل‌ها': [PantoWord('آب در هاون کوبیدن', 3), PantoWord('دست و پا چلفتی', 3), PantoWord('خون به جگر شدن', 3), PantoWord('چشم و همچشمی', 3), PantoWord('زیر آبی به کسی زدن', 3), PantoWord('گربه را دم حجله کشتن', 3), PantoWord('دیگ به دیگ میگه روت سیاه', 3), PantoWord('آشپز که دو تا شد آش یا شور میشه یا بی‌نمک', 3), PantoWord('از این ستون به آن ستون فرج است', 3), PantoWord('با یک گل بهار نمیشه', 3), PantoWord('خواستن توانستن است', 2), PantoWord('هر که بامش بیش برفش بیشتر', 3), PantoWord('موش تو سوراخ نمیرفت جارو به دمش می‌بست', 3), PantoWord('شتر دیدی ندیدی', 3), PantoWord('دوست آن باشد که گیرد دست دوست', 3), PantoWord('سنگ بزرگ علامت نزدن است', 3), PantoWord('کوه به کوه نمیرسد آدم به آدم میرسد', 3), PantoWord('آب که از سر گذشت چه یک وجب چه صد وجب', 3), PantoWord('هرچه بگندد نمکش میزنند', 3), PantoWord('از تو حرکت از خدا برکت', 2)],
  'سلبریتی‌ها': [PantoWord('مهران مدیری', 2), PantoWord('عادل فردوسی‌پور', 2), PantoWord('جواد خیابانی', 2), PantoWord('نوید محمدزاده', 3), PantoWord('رامبد جوان', 2), PantoWord('محسن تنابنده', 3), PantoWord('بهاره رهنما', 3), PantoWord('مهدی هاشمی', 3), PantoWord('پرویز پرستویی', 2), PantoWord('رضا عطاران', 2), PantoWord('حمید فرخ‌نژاد', 3), PantoWord('شهاب حسینی', 2), PantoWord('ترانه علیدوستی', 3), PantoWord('هومن سیدی', 3), PantoWord('سعید آقاخانی', 3), PantoWord('علی نصیریان', 3), PantoWord('اکبر عبدی', 2), PantoWord('مریلا زارعی', 3), PantoWord('امیر جعفری', 3), PantoWord('علی صادقی', 3)],
  'حیوانات': [PantoWord('پنگوئن', 1), PantoWord('زرافه', 1), PantoWord('کانگورو', 2), PantoWord('هشت‌پا', 2), PantoWord('خفاش', 3), PantoWord('آفتاب‌پرست', 3), PantoWord('دلفین', 2), PantoWord('کوالا', 2), PantoWord('شترمرغ', 3), PantoWord('طاووس', 2), PantoWord('تمساح', 2), PantoWord('مار کبری', 3), PantoWord('خرچنگ', 2), PantoWord('عقاب', 2), PantoWord('جغد', 2), PantoWord('حلزون', 3), PantoWord('میمون', 1), PantoWord('کرگدن', 2), PantoWord('اسب آبی', 2), PantoWord('گورخر', 2)],
  'ورزش': [PantoWord('فوتبال', 1), PantoWord('شنا', 1), PantoWord('والیبال', 2), PantoWord('بسکتبال', 2), PantoWord('شطرنج', 3), PantoWord('کاراته', 3), PantoWord('تنیس', 2), PantoWord('کوهنوردی', 2), PantoWord('بوکس', 2), PantoWord('کشتی', 3), PantoWord('ژیمناستیک', 3), PantoWord('دوچرخه‌سواری', 2), PantoWord('اسکی', 2), PantoWord('اسکیت', 2), PantoWord('گلف', 2), PantoWord('بیسبال', 3), PantoWord('هاکی', 3), PantoWord('بولینگ', 2), PantoWord('تیراندازی', 3), PantoWord('شمشیربازی', 3)],
  'مشاغل': [PantoWord('پلیس', 1), PantoWord('معلم', 1), PantoWord('خلبان', 2), PantoWord('نقاش', 2), PantoWord('آتش‌نشان', 3), PantoWord('بازیگر', 3), PantoWord('دندانپزشک', 3), PantoWord('مهندس', 2), PantoWord('وکیل', 3), PantoWord('پرستار', 2), PantoWord('نجار', 2), PantoWord('بنا', 2), PantoWord('خیاط', 3), PantoWord('آرایشگر', 2), PantoWord('عکاس', 2), PantoWord('کشاورز', 3), PantoWord('راننده تاکسی', 2), PantoWord('قصاب', 2), PantoWord('نانوا', 2), PantoWord('پستچی', 3)],
  'احساسات': [PantoWord('عصبانی', 1), PantoWord('خسته', 1), PantoWord('ترسیده', 2), PantoWord('عاشق', 2), PantoWord('مغرور', 3), PantoWord('حسود', 3), PantoWord('خوشحال', 1), PantoWord('غمگین', 2), PantoWord('هیجان‌زده', 2), PantoWord('نگران', 3), PantoWord('شگفت‌زده', 3), PantoWord('آرام', 2), PantoWord('بی‌حوصله', 3), PantoWord('دلواپس', 3), PantoWord('شرمنده', 2), PantoWord('مضطرب', 3), PantoWord('امیدوار', 2), PantoWord('ناامید', 3), PantoWord('متعجب', 2), PantoWord('راضی', 2)],
  'اشیاء': [PantoWord('چتر', 1), PantoWord('عینک', 1), PantoWord('ساعت', 2), PantoWord('کیف', 2), PantoWord('لپ‌تاپ', 3), PantoWord('آینه', 3), PantoWord('تلفن', 1), PantoWord('دفتر', 1), PantoWord('مداد', 1), PantoWord('کتاب', 2), PantoWord('توپ', 2), PantoWord('پنجره', 2), PantoWord('در', 2), PantoWord('دیوار', 3), PantoWord('فرش', 2), PantoWord('لامپ', 3), PantoWord('صندلی', 1), PantoWord('میز', 2), PantoWord('ماشین', 1), PantoWord('دوچرخه', 2)],
  'غذا': [PantoWord('پیتزا', 1), PantoWord('کباب', 1), PantoWord('قورمه سبزی', 2), PantoWord('فسنجان', 2), PantoWord('املت', 3), PantoWord('سالاد', 3), PantoWord('سوشی', 2), PantoWord('برگر', 1), PantoWord('ماکارونی', 2), PantoWord('جوجه کباب', 2), PantoWord('قیمه', 3), PantoWord('عدس پلو', 3), PantoWord('زرشک پلو', 3), PantoWord('باقالی پلو', 3), PantoWord('دلمه', 3), PantoWord('کوکو', 2), PantoWord('کشک بادمجان', 3), PantoWord('میگو', 2), PantoWord('ماهی', 2), PantoWord('پنکیک', 1)],
};

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دسته‌بندی کلمات پانتومیم'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: pantoData.keys.map((cat) {
          final List<PantoWord> words = pantoData[cat]!;
          return ExpansionTile(
            title: Text(cat, style: const TextStyle(color: AppColors.pantoBlue, fontWeight: FontWeight.bold)),
            subtitle: Text('${words.length} کلمه', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
            children: words.map((w) {
              return ListTile(
                title: Text(w.word),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => Icon(Icons.star, size: 16, color: i < w.diff ? AppColors.gold : Colors.grey)),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== SPY GAME FLOW ====================
class SpySetupScreen extends StatefulWidget {
  const SpySetupScreen({super.key});
  @override
  State<SpySetupScreen> createState() => _SpySetupScreenState();
}

class _SpySetupScreenState extends State<SpySetupScreen> {
  int _players = 5, _spies = 1, _time = 120;
  String _category = 'مکان‌ها';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم جاسوس'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _row('بازیکنان', '$_players', () => setState(() => _players = min(_players + 1, 12)), () => setState(() => _players = max(_players - 1, 3))),
          _row('جاسوس‌ها', '$_spies', () => setState(() => _spies = min(_spies + 1, 3)), () => setState(() => _spies = max(_spies - 1, 1))),
          _row('زمان', '$_time', () => setState(() => _time += 30), () => setState(() => _time = max(_time - 30, 60))),
          const SizedBox(height: 20),
          const Text('دسته‌بندی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.spyRed)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, 
            runSpacing: 8, 
            children: spyData.keys.map((c) => ChoiceChip(
              label: Text(c), 
              selected: _category == c, 
              onSelected: (bool selected) {
                if (selected) setState(() => _category = c);
              }
            )).toList()
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              AppSettings.vibrate();
              final word = spyData[_category]![Random().nextInt(spyData[_category]!.length)];
              Navigator.push(context, MaterialPageRoute(builder: (_) => SpyRevealScreen(total: _players, spies: _spies, time: _time, word: word, cat: _category)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.spyRed, minimumSize: const Size(double.infinity, 55)),
            child: const Text('شروع بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _row(String t, String v, VoidCallback i, VoidCallback d) {
    return Card(color: AppColors.cardBg, child: ListTile(title: Text(t), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.remove, color: AppColors.spyRed), onPressed: d),
      Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      IconButton(icon: const Icon(Icons.add, color: AppColors.spyRed), onPressed: i),
    ])));
  }
}

class SpyRevealScreen extends StatefulWidget {
  final int total, spies, time; final String word, cat;
  const SpyRevealScreen({super.key, required this.total, required this.spies, required this.time, required this.word, required this.cat});
  @override
  State<SpyRevealScreen> createState() => _SpyRevealScreenState();
}

class _SpyRevealScreenState extends State<SpyRevealScreen> {
  int _curr = 0; bool _revealed = false; late List<bool> _roles;
  @override
  void initState() {
    super.initState();
    _roles = List.generate(widget.total, (_) => false);
    for (int i = 0; i < widget.spies; i++) { _roles[i] = true; }
    _roles.shuffle();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('بازیکن ${_curr + 1}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () { AppSettings.vibrate(); setState(() => _revealed = true); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200, height: 300,
                decoration: BoxDecoration(
                  color: _revealed ? (_roles[_curr] ? AppColors.spyRed.withOpacity(0.2) : AppColors.cardBg) : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _revealed && _roles[_curr] ? AppColors.spyRed : AppColors.purple, width: 2),
                ),
                child: Center(
                  child: !_revealed ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.touch_app, size: 60, color: AppColors.purple), SizedBox(height: 10), Text('برای دیدن لمس کن')]) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_roles[_curr] ? '🕵️' : '👤', style: const TextStyle(fontSize: 60)),
                      Text(_roles[_curr] ? 'جاسوس' : widget.word, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      if(_roles[_curr]) Text('راهنما: ${widget.cat}', style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            if (_revealed) ElevatedButton(
              onPressed: () {
                AppSettings.vibrate();
                if (_curr < widget.total - 1) setState(() { _curr++; _revealed = false; });
                else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyResultScreen(roles: _roles, word: widget.word)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.spyRed, minimumSize: const Size(200, 50)),
              child: Text(_curr < widget.total - 1 ? 'نفر بعدی' : 'پایان و نتیجه', style: const TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}

class SpyResultScreen extends StatefulWidget {
  final List<bool> roles; final String word;
  const SpyResultScreen({super.key, required this.roles, required this.word});
  @override
  State<SpyResultScreen> createState() => _SpyResultScreenState();
}

class _SpyResultScreenState extends State<SpyResultScreen> {
  late ConfettiController _controller;
  @override
  void initState() { super.initState(); _controller = ConfettiController(duration: const Duration(seconds: 3))..play(); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 80)),
                Text('کلمه اصلی: ${widget.word}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('جاسوس‌ها:', style: TextStyle(color: AppColors.textSub)),
                ...widget.roles.asMap().entries.where((e) => e.value).map((e) => Text('بازیکن ${e.key + 1}', style: const TextStyle(color: AppColors.spyRed, fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), 
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
                  child: const Text('بازگشت به خانه', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _controller, blastDirectionality: BlastDirectionality.explosive, colors: const [AppColors.gold, AppColors.purple, Colors.white])),
        ],
      ),
    );
  }
}

// ==================== PANTOMIME MODES ====================
enum PantoMode { classic, speed, war, marathon }

extension PantoModeExt on PantoMode {
  String get title {
    switch (this) {
      case PantoMode.classic: return 'کلاسیک (نوبتی)';
      case PantoMode.speed: return 'سرعتی (چابک)';
      case PantoMode.war: return 'جنگی (ریسکی)';
      case PantoMode.marathon: return 'ماراتن (طولانی)';
    }
  }
  String get desc {
    switch (this) {
      case PantoMode.classic: return 'زمان ۶۰ ثانیه. امتیاز = (سختی × ۱۰) + ثانیه باقی‌مانده.';
      case PantoMode.speed: return 'فقط ۱۵ ثانیه! اگر درست بگوید ۳۰ امتیاز، اگر ببازد صفر.';
      case PantoMode.war: return 'زمان ۴۵ ثانیه. درست: +۴۰ امتیاز. اشتباه: -۲۰ امتیاز (جنگی!)';
      case PantoMode.marathon: return 'زمان ۱۲۰ ثانیه. امتیاز پایه دو برابر محاسبه می‌شود.';
    }
  }
  Color get color {
    switch (this) {
      case PantoMode.classic: return AppColors.pantoBlue;
      case PantoMode.speed: return Colors.orange;
      case PantoMode.war: return AppColors.spyRed;
      case PantoMode.marathon: return AppColors.purple;
    }
  }
  IconData get icon {
    switch (this) {
      case PantoMode.classic: return Icons.sports_esports;
      case PantoMode.speed: return Icons.flash_on;
      case PantoMode.war: return Icons.local_fire_department;
      case PantoMode.marathon: return Icons.hourglass_bottom;
    }
  }
}

// ==================== PANTOMIME FLOW ====================
class PantoSetupScreen extends StatefulWidget {
  const PantoSetupScreen({super.key});
  @override
  State<PantoSetupScreen> createState() => _PantoSetupScreenState();
}

class _PantoSetupScreenState extends State<PantoSetupScreen> {
  PantoMode _mode = PantoMode.classic;
  int _turns = 10;
  bool _isTeamMode = true;
  String _teamACat = 'عمومی', _teamBCat = 'فیلم و سریال';
  final _teamACtrl = TextEditingController(text: 'تیم قرمز');
  final _teamBCtrl = TextEditingController(text: 'تیم آبی');

  void _showRules() {
    AppSettings.vibrate();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [Icon(_mode.icon, color: _mode.color, size: 30), const SizedBox(width: 10), Text(_mode.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 20),
            Text(_mode.desc, style: const TextStyle(fontSize: 16, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('فهمیدم')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم پانتومیم'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('حالت بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.pantoBlue)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: PantoMode.values.map((m) => ChoiceChip(
                    label: Text(m.title),
                    avatar: Icon(m.icon, size: 18, color: _mode == m ? Colors.white : m.color),
                    selected: _mode == m,
                    selectedColor: m.color,
                    onSelected: (bool selected) {
                      if (selected) {
                        AppSettings.vibrate(); 
                        setState(() => _mode = m);
                      }
                    },
                  )).toList(),
                ),
              ),
              IconButton(icon: const Icon(Icons.info_outline, color: AppColors.gold), onPressed: _showRules)
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('حالت تیمی', style: TextStyle(fontWeight: FontWeight.bold)),
            value: _isTeamMode,
            activeColor: AppColors.purple,
            onChanged: (v) { AppSettings.vibrate(); setState(() => _isTeamMode = v); },
          ),
          if (_isTeamMode) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                TextField(controller: _teamACtrl, decoration: const InputDecoration(labelText: 'نام تیم اول', prefixIcon: Icon(Icons.circle, color: AppColors.spyRed, size: 12))),
                const SizedBox(height: 10),
                TextField(controller: _teamBCtrl, decoration: const InputDecoration(labelText: 'نام تیم دوم', prefixIcon: Icon(Icons.circle, color: AppColors.pantoBlue, size: 12))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('دسته‌بندی کلمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.pantoBlue)),
          const SizedBox(height: 10),
          if (_isTeamMode) ...[
            _buildCatSelector('دسته تیم اول', _teamACat, (v) => setState(() => _teamACat = v)),
            const SizedBox(height: 10),
            _buildCatSelector('دسته تیم دوم', _teamBCat, (v) => setState(() => _teamBCat = v)),
          ] else
            _buildCatSelector('دسته اصلی', _teamACat, (v) => setState(() => _teamACat = v)),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('تعداد دست‌ها', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove, color: AppColors.pantoBlue), onPressed: () => setState(() => _turns = max(_turns - 2, 2))),
                    Text('$_turns', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add, color: AppColors.pantoBlue), onPressed: () => setState(() => _turns += 2)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              AppSettings.vibrate();
              final wordsA = List<PantoWord>.from(pantoData[_teamACat]!)..shuffle();
              final wordsB = List<PantoWord>.from(pantoData[_teamBCat]!)..shuffle();
              Navigator.push(context, MaterialPageRoute(builder: (_) => PantoGameScreen(
                mode: _mode, totalTurns: _turns, wordsA: wordsA, wordsB: wordsB, isTeamMode: _isTeamMode,
                teamAName: _teamACtrl.text.isEmpty ? 'تیم ۱' : _teamACtrl.text,
                teamBName: _teamBCtrl.text.isEmpty ? 'تیم ۲' : _teamBCtrl.text,
              )));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _mode.color, minimumSize: const Size(double.infinity, 55)),
            child: const Text('شروع مسابقه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildCatSelector(String label, String current, Function(String) onSel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: current,
          hint: Text(label),
          items: pantoData.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => onSel(v!),
        ),
      ),
    );
  }
}

class PantoGameScreen extends StatefulWidget {
  final PantoMode mode; final int totalTurns; final List<PantoWord> wordsA, wordsB;
  final bool isTeamMode; final String teamAName, teamBName;
  const PantoGameScreen({super.key, required this.mode, required this.totalTurns, required this.wordsA, required this.wordsB, required this.isTeamMode, required this.teamAName, required this.teamBName});

  @override
  State<PantoGameScreen> createState() => _PantoGameScreenState();
}

class _PantoGameScreenState extends State<PantoGameScreen> with TickerProviderStateMixin {
  int _turn = 1, _teamA_Score = 0, _teamB_Score = 0, _currentTeam = 0;
  int _wordIndex = 0;
  bool _revealed = false, _gameOver = false;
  
  late int _seconds; late int _maxSeconds;
  Timer? _timer;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _setupModeVariables();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
  }

  void _setupModeVariables() {
    switch (widget.mode) {
      case PantoMode.classic: _maxSeconds = 60; break;
      case PantoMode.speed: _maxSeconds = 15; break;
      case PantoMode.war: _maxSeconds = 45; break;
      case PantoMode.marathon: _maxSeconds = 120; break;
    }
    _seconds = _maxSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel(); _shakeController.dispose(); _pulseController.dispose(); _confetti.dispose();
    super.dispose();
  }

  void _startTurn() {
    AppSettings.vibrate();
    setState(() { _revealed = true; _seconds = _maxSeconds; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); }
      else { t.cancel(); _endTurn(success: false); }
    });
  }

  void _endTurn({required bool success}) {
    _timer?.cancel();
    int currentDiff = _currentTeam == 0 ? widget.wordsA[_wordIndex].diff : widget.wordsB[_wordIndex].diff;
    int points = 0;

    if (success) {
      _confetti.play();
      AppSettings.vibrate();
      switch (widget.mode) {
        case PantoMode.classic: points = (currentDiff * 10) + _seconds; break;
        case PantoMode.speed: points = 30; break;
        case PantoMode.war: points = 40; break;
        case PantoMode.marathon: points = (currentDiff * 20) + _seconds; break;
      }
    } else {
      _shakeController.forward(from: 0);
      if (widget.mode == PantoMode.war) points = -20;
    }

    setState(() {
      if (widget.isTeamMode) {
        if (_currentTeam == 0) _teamA_Score += points; else _teamB_Score += points;
      } else {
        _teamA_Score += points;
      }
    });

    if (_turn >= widget.totalTurns) {
      Future.delayed(const Duration(milliseconds: 600), () {
        AppSettings.totalGames++;
        AppSettings.save();
        setState(() => _gameOver = true);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _turn++; _currentTeam = _currentTeam == 0 ? 1 : 0;
          _revealed = false; _seconds = _maxSeconds;
          _wordIndex = (_wordIndex + 1) % min(widget.wordsA.length, widget.wordsB.length);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      bool isDraw = _teamA_Score == _teamB_Score;
      String winner = _teamA_Score > _teamB_Score ? widget.teamAName : widget.teamBName;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 100)),
              Text(isDraw ? 'مساوی!' : '$winner برنده شد!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              if (widget.isTeamMode) ...[
                Text('${widget.teamAName}: $_teamA_Score', style: const TextStyle(fontSize: 22, color: AppColors.spyRed, fontWeight: FontWeight.bold)),
                Text('${widget.teamBName}: $_teamB_Score', style: const TextStyle(fontSize: 22, color: AppColors.pantoBlue, fontWeight: FontWeight.bold)),
              ] else Text('امتیاز شما: $_teamA_Score', style: const TextStyle(fontSize: 22, color: AppColors.gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('بازگشت به خانه')),
            ],
          ),
        ),
      );
    }

    int diff = _currentTeam == 0 ? widget.wordsA[_wordIndex].diff : widget.wordsB[_wordIndex].diff;
    String word = _currentTeam == 0 ? widget.wordsA[_wordIndex].word : widget.wordsB[_wordIndex].word;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final dx = sin(_shakeController.value * pi * 6) * 15 * (1 - _shakeController.value);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('دست $_turn از ${widget.totalTurns}', style: const TextStyle(color: AppColors.textSub)),
                      Text(widget.mode.title, style: TextStyle(color: widget.mode.color, fontWeight: FontWeight.bold, fontSize: 12)),
                    ]),
                    if (widget.isTeamMode) Row(children: [
                      _scoreBadge(widget.teamAName, _teamA_Score, AppColors.spyRed, _currentTeam == 0),
                      const SizedBox(width: 10),
                      _scoreBadge(widget.teamBName, _teamB_Score, AppColors.pantoBlue, _currentTeam == 1),
                    ]) else _scoreBadge('امتیاز', _teamA_Score, AppColors.gold, true),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: !_revealed
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
                              child: Image.asset('assets/images/7.png', width: 100),
                            ),
                            const SizedBox(height: 20),
                            Text('گوشی را به ${_currentTeam == 0 ? widget.teamAName : widget.teamBName} بدهید', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: _startTurn,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('شروع', style: TextStyle(fontSize: 20)),
                              style: ElevatedButton.styleFrom(backgroundColor: widget.mode.color, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 130, height: 130,
                                  child: CircularProgressIndicator(
                                    value: _seconds / _maxSeconds, strokeWidth: 10,
                                    backgroundColor: AppColors.cardBg,
                                    valueColor: AlwaysStoppedAnimation<Color>(_seconds < 10 ? Colors.red : widget.mode.color),
                                  ),
                                ),
                                Text('$_seconds', style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) => Icon(Icons.star, color: i < diff ? AppColors.gold : Colors.grey.shade800, size: 30)),
                            ),
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Text(word, key: ValueKey(word), style: GoogleFonts.vazirmatn(fontSize: 56, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                ),
              ),
              if (_revealed)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                            onPressed: () => _endTurn(success: false),
                            child: const Text('نتونست', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 70,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                            onPressed: () => _endTurn(success: true),
                            child: const Text('درست بود!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreBadge(String name, int score, Color color, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.2) : AppColors.cardBg,
        border: Border.all(color: active ? color : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(name, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.textSub)),
        Text('$score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: active ? color : AppColors.textSub)),
      ]),
    );
  }
}
