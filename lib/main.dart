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

class GamePartyApp extends StatelessWidget {
  const GamePartyApp({super.key});
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
    _glow = Tween(begin: 0.2, end: 0.8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
                    IconButton(icon: Image.asset('assets/images/4.png', width: 40), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                    IconButton(icon: const Icon(Icons.menu_book, color: AppColors.textSub, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()))),
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
                      Expanded(child: _buildCard(context, 'assets/images/2.png', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpySetupScreen())))),
                      const SizedBox(height: 16),
                      Expanded(child: _buildCard(context, 'assets/images/3.png', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantoSetupScreen())))),
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

// ==================== CATEGORIES SCREEN ====================
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('همه دسته‌بندی‌ها'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: pantoData.keys.map((cat) => ExpansionTile(
          title: Text(cat, style: const TextStyle(color: AppColors.pantoBlue, fontWeight: FontWeight.bold)),
          children: pantoData[cat]!.map((w) => ListTile(
            title: Text(w['word']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Icon(Icons.star, size: 16, color: i < w['diff'] ? AppColors.gold : Colors.grey)),
            ),
          )).toList(),
        )).toList(),
      ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات'), backgroundColor: Colors.transparent),
      body: const Center(child: Text('تنظیمات صدا و ویبره در آپدیت بعدی', style: TextStyle(color: AppColors.textSub))),
    );
  }
}

// ==================== SPY GAME DATA & FLOW ====================
const spyData = {
  'مکان‌ها': ['بیمارستان', 'فرودگاه', 'دانشگاه', 'رستوران', 'پارک', 'کافه', 'سینما', 'کتابخانه', 'بانک', 'هتل'],
  'سفر': ['کوه', 'جنگل', 'ساحل', 'بیابان', 'جزیره', 'دریاچه', 'تونل', 'ایستگاه قطار', 'کشتی', 'قطار'],
  'غذا': ['پیتزا', 'کباب', 'قورمه سبزی', 'آش رشته', 'فسنجان', 'املت', 'سالاد', 'سوشی', 'برگر', 'ماکارونی'],
  'حیوانات': ['شیر', 'فیل', 'زرافه', 'پنگوئن', 'دلفین', 'طوطی', 'کوالا', 'گربه', 'خرس', 'کبوتر'],
  'مشاغل': ['دکتر', 'معلم', 'خلبان', 'آشپز', 'بازیگر', 'راننده', 'پلیس', 'نقاش', 'خبرنگار', 'خواننده'],
};

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
          Wrap(spacing: 8, children: spyData.keys.map((c) => ChoiceChip(label: Text(c), selected: _category == c, onSelected: (v) => setState(() => _category = c))).toList()),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
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
              onTap: () => setState(() => _revealed = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200, height: 300,
                decoration: BoxDecoration(
                  color: _revealed ? (_roles[_curr] ? AppColors.spyRed.withOpacity(0.2) : AppColors.cardBg) : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _revealed && _roles[_curr] ? AppColors.spyRed : AppColors.purple, width: 2),
                ),
                child: Center(
                  child: !_revealed ? const Icon(Icons.touch_app, size: 60, color: AppColors.purple) : Column(
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
                if (_curr < widget.total - 1) setState(() { _curr++; _revealed = false; });
                else Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyResultScreen(roles: _roles, word: widget.word)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.spyRed),
              child: Text(_curr < widget.total - 1 ? 'نفر بعدی' : 'پایان و نتیجه'),
            )
          ],
        ),
      ),
    );
  }
}

class SpyResultScreen extends StatelessWidget {
  final List<bool> roles; final String word;
  const SpyResultScreen({super.key, required this.roles, required this.word});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            Text('کلمه اصلی: $word', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            const Text('جاسوس‌ها:', style: TextStyle(color: AppColors.textSub)),
            ...roles.asMap().entries.where((e) => e.value).map((e) => Text('بازیکن ${e.key + 1}', style: const TextStyle(color: AppColors.spyRed, fontSize: 18))),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('خانه')),
          ],
        ),
      ),
    );
  }
}

// ==================== PANTOMIME DATA (MASSIVE UPDATE) ====================
const pantoData = {
  'عمومی': [{'word': 'دویدن', 'diff': 1}, {'word': 'شیر', 'diff': 1}, {'word': 'دکتر', 'diff': 1}, {'word': 'چتر', 'diff': 2}, {'word': 'خوشحال', 'diff': 2}],
  'فیلم و سریال': [{'word': 'شرک', 'diff': 2}, {'word': 'آواتار', 'diff': 2}, {'word': 'تایتانیک', 'diff': 2}, {'word': 'هری پاتر', 'diff': 3}],
  'ضرب‌المثل': [{'word': 'آب در هاون کوبیدن', 'diff': 3}, {'word': 'دست و پا چلفتی', 'diff': 3}, {'word': 'خون به جگر شدن', 'diff': 3}],
  'سلبریتی': [{'word': 'مهران مدیری', 'diff': 2}, {'word': 'عادل فردوسی‌پور', 'diff': 2}, {'word': 'جواد خیابانی', 'diff': 2}],
  'حیوانات': [{'word': 'پنگوئن', 'diff': 1}, {'word': 'زرافه', 'diff': 1}, {'word': 'کانگورو', 'diff': 2}, {'word': 'آفتاب‌پرست', 'diff': 3}],
  'ورزش': [{'word': 'فوتبال', 'diff': 1}, {'word': 'شنا', 'diff': 1}, {'word': 'بسکتبال', 'diff': 2}, {'word': 'کاراته', 'diff': 2}],
  'مشاغل': [{'word': 'پلیس', 'diff': 1}, {'word': 'معلم', 'diff': 1}, {'word': 'خلبان', 'diff': 2}, {'word': 'آتش‌نشان', 'diff': 3}],
  'احساسات': [{'word': 'عصبانی', 'diff': 1}, {'word': 'خسته', 'diff': 1}, {'word': 'عاشق', 'diff': 2}, {'word': 'حسود', 'diff': 3}],
  'اشیاء': [{'word': 'چتر', 'diff': 1}, {'word': 'عینک', 'diff': 1}, {'word': 'لپ‌تاپ', 'diff': 2}, {'word': 'آینه', 'diff': 2}],
  'غذا': [{'word': 'پیتزا', 'diff': 1}, {'word': 'کباب', 'diff': 1}, {'word': 'قورمه سبزی', 'diff': 2}, {'word': 'فسنجان', 'diff': 3}],
};

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
      case PantoMode.classic: return 'زمان ۶۰ ثانیه. امتیاز = ارزش کلمه + ثانیه باقی‌مانده.';
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

// ==================== PANTOMIME SETUP ====================
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
          // Mode Selection
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
                    onSelected: (v) => setState(() => _mode = m),
                  )).toList(),
                ),
              ),
              IconButton(icon: const Icon(Icons.info_outline, color: AppColors.gold), onPressed: _showRules)
            ],
          ),
          const SizedBox(height: 20),
          
          // Team Toggle
          SwitchListTile(
            title: const Text('حالت تیمی', style: TextStyle(fontWeight: FontWeight.bold)),
            value: _isTeamMode,
            activeColor: AppColors.purple,
            onChanged: (v) => setState(() => _isTeamMode = v),
          ),
          
          // Team Names
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
          // Categories (Independent)
          const Text('دسته‌بندی کلمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.pantoBlue)),
          const SizedBox(height: 10),
          if (_isTeamMode) ...[
            _buildCatSelector('دسته تیم اول', _teamACat, (v) => setState(() => _teamACat = v)),
            const SizedBox(height: 10),
            _buildCatSelector('دسته تیم دوم', _teamBCat, (v) => setState(() => _teamBCat = v)),
          ] else
            _buildCatSelector('دسته اصلی', _teamACat, (v) => setState(() => _teamACat = v)),

          const SizedBox(height: 20),
          // Turns
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
              final wordsA = List<Map<String, dynamic>>.from(pantoData[_teamACat]!)..shuffle();
              final wordsB = List<Map<String, dynamic>>.from(pantoData[_teamBCat]!)..shuffle();
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

// ==================== PANTOMIME GAME SCREEN (HEAVY ANIMATIONS) ====================
class PantoGameScreen extends StatefulWidget {
  final PantoMode mode; final int totalTurns; final List<Map<String, dynamic>> wordsA, wordsB;
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
    setState(() { _revealed = true; _seconds = _maxSeconds; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); }
      else { t.cancel(); _endTurn(success: false); }
    });
  }

  void _endTurn({required bool success}) {
    _timer?.cancel();
    int currentDiff = _currentTeam == 0 ? widget.wordsA[_wordIndex]['diff'] : widget.wordsB[_wordIndex]['diff'];
    int points = 0;

    if (success) {
      _confetti.play();
      switch (widget.mode) {
        case PantoMode.classic: points = (currentDiff * 10) + _seconds; break;
        case PantoMode.speed: points = 30; break;
        case PantoMode.war: points = 40; break;
        case PantoMode.marathon: points = (currentDiff * 20) + _seconds; break;
      }
    } else {
      _shakeController.forward(from: 0); // SHAKE ANIMATION
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
      Future.delayed(const Duration(milliseconds: 600), () => setState(() => _gameOver = true));
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

    int diff = _currentTeam == 0 ? widget.wordsA[_wordIndex]['diff'] : widget.wordsB[_wordIndex]['diff'];
    String word = _currentTeam == 0 ? widget.wordsA[_wordIndex]['word'] : widget.wordsB[_wordIndex]['word'];

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            // SHAKE EFFECT ON WRONG ANSWER
            final dx = sin(_shakeController.value * pi * 6) * 15 * (1 - _shakeController.value);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Column(
            children: [
              // Header
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
              
              // Buttons
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
