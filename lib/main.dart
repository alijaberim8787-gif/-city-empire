import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

// ==================== APP SETTINGS ====================
class AppSettings {
  static bool soundOn = true;
  static bool vibrationOn = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    soundOn = prefs.getBool('sound') ?? true;
    vibrationOn = prefs.getBool('vibration') ?? true;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', soundOn);
    await prefs.setBool('vibration', vibrationOn);
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
        textTheme: GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        useMaterial3: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/6.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
          gradient: RadialGradient(colors: [Color(0xFF2A1548), AppColors.bg], radius: 1.2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(_animation),
                child: Image.asset('assets/images/1.png', width: 280),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 20),
              const Text('در حال بارگذاری...', style: TextStyle(color: AppColors.textSub)),
            ],
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
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/6.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      child: Image.asset('assets/images/4.png', width: 50),
                    ),
                    Image.asset('assets/images/5.png', width: 50),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Image.asset('assets/images/1.png', width: 280),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: _ImageCard(
                          imagePath: 'assets/images/2.png',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpySetupScreen())),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _ImageCard(
                          imagePath: 'assets/images/3.png',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantoSetupScreen())),
                        ),
                      ),
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
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  const _ImageCard({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(imagePath, fit: BoxFit.contain),
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
            onChanged: (val) { setState(() => AppSettings.soundOn = val); AppSettings.save(); },
          ),
          SwitchListTile(
            title: const Text('لرزش (ویبره)'),
            secondary: const Icon(Icons.vibration, color: AppColors.purple),
            activeColor: AppColors.purple,
            value: AppSettings.vibrationOn,
            onChanged: (val) { setState(() => AppSettings.vibrationOn = val); AppSettings.save(); },
          ),
          const Divider(color: AppColors.cardBg),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.textSub),
            title: Text('درباره گیم پارتی'),
            subtitle: Text('نسخه 2.2.0 - پانتومیم نوبت‌محور', style: TextStyle(color: AppColors.textSub)),
          ),
        ],
      ),
    );
  }
}

// ==================== SPY GAME DATA ====================
const spyData = {
  'مکان‌های عمومی': ['بیمارستان', 'فرودگاه', 'دانشگاه', 'رستوران', 'پارک', 'کافه', 'سینما', 'کتابخانه', 'بانک', 'هتل'],
  'سفر و طبیعت': ['کوه', 'جنگل', 'ساحل', 'بیابان', 'جزیره', 'دریاچه', 'تونل', 'ایستگاه قطار', 'کشتی', 'قطار'],
  'غذا و خوراکی': ['پیتزا', 'کباب کوبیده', 'قورمه سبزی', 'آش رشته', 'فسنجان', 'زرشک پلو', 'املت', 'سالاد شیرازی', 'سوشی', 'برگر'],
  'حیوانات': ['شیر', 'فیل', 'زرافه', 'پنگوئن', 'دلفین', 'طوطی', 'کوالا', 'گربه', 'خرس', 'کبوتر'],
  'مشاغل': ['دکتر', 'معلم', 'خلبان', 'آشپز', 'بازیگر', 'راننده', 'پلیس', 'نقاش', 'خبرنگار', 'خواننده'],
  'اشیاء': ['چتر', 'عینک', 'ساعت', 'کیف', 'لپ‌تاپ', 'صندلی', 'ماشین', 'آینه', 'چاقو', 'کلید'],
  'فیلم و سریال': ['تایتانیک', 'آواتار', 'ماتریکس', 'شرک', 'شیر شاه', 'هری پاتر', 'فروزن', 'جوراسیک پارک'],
  'ورزش‌ها': ['فوتبال', 'والیبال', 'بسکتبال', 'شنا', 'شطرنج', 'کاراته', 'تنیس', 'کوهنوردی'],
};

// ==================== SPY GAME FLOW ====================
class SpySetupScreen extends StatefulWidget {
  const SpySetupScreen({super.key});
  @override
  State<SpySetupScreen> createState() => _SpySetupScreenState();
}

class _SpySetupScreenState extends State<SpySetupScreen> {
  int _players = 5;
  int _spies = 1;
  int _time = 120;
  String _category = 'مکان‌های عمومی';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم بازی جاسوس'), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSettingRow('تعداد بازیکنان', '$_players', () => setState(() => _players = min(_players + 1, 12)), () => setState(() => _players = max(_players - 1, 3))),
            _buildSettingRow('تعداد جاسوس‌ها', '$_spies', () => setState(() => _spies = min(_spies + 1, 3)), () => setState(() => _spies = max(_spies - 1, 1))),
            _buildSettingRow('زمان بازی (ثانیه)', '$_time', () => setState(() => _time += 30), () => setState(() => _time = max(_time - 30, 60))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('دسته‌بندی مکان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: spyData.keys.map((cat) {
                      return ChoiceChip(label: Text(cat), selected: _category == cat, onSelected: (val) => setState(() => _category = cat));
                    }).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final wordList = spyData[_category]!;
                final word = wordList[Random().nextInt(wordList.length)];
                Navigator.push(context, MaterialPageRoute(builder: (_) => SpyRevealScreen(totalPlayers: _players, spies: _spies, time: _time, word: word, category: _category)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.spyRed, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('شروع بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, VoidCallback inc, VoidCallback dec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.spyRed), onPressed: dec),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.spyRed), onPressed: inc),
            ],
          )
        ],
      ),
    );
  }
}

class SpyRevealScreen extends StatefulWidget {
  final int totalPlayers, spies, time;
  final String word, category;
  const SpyRevealScreen({super.key, required this.totalPlayers, required this.spies, required this.time, required this.word, required this.category});
  @override
  State<SpyRevealScreen> createState() => _SpyRevealScreenState();
}

class _SpyRevealScreenState extends State<SpyRevealScreen> {
  int _current = 0;
  bool _revealed = false;
  late List<bool> _roles;

  @override
  void initState() {
    super.initState();
    _roles = List.generate(widget.totalPlayers, (_) => false);
    for (int i = 0; i < widget.spies; i++) _roles[i] = true;
    _roles.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    bool isSpy = _roles[_current];
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('بازیکن ${_current + 1}', style: GoogleFonts.vazirmatn(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              if (!_revealed)
                GestureDetector(
                  onTap: () => setState(() => _revealed = true),
                  child: Container(
                    width: 220, height: 320,
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.spyRed)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 60, color: AppColors.spyRed),
                        SizedBox(height: 16),
                        Text('برای دیدن نقش لمس کن', style: TextStyle(color: AppColors.textSub)),
                      ],
                    ),
                  ),
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    width: 220, height: 320,
                    decoration: BoxDecoration(
                      color: isSpy ? AppColors.spyRed.withOpacity(0.2) : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSpy ? AppColors.spyRed : AppColors.purple, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isSpy ? '🕵️' : '👤', style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text(isSpy ? 'تو جاسوسی!' : widget.word, style: GoogleFonts.vazirmatn(fontSize: 26, fontWeight: FontWeight.bold)),
                        if (isSpy) ...[
                          const SizedBox(height: 10),
                          Text('راهنما: ${widget.category}', style: const TextStyle(color: AppColors.textSub, fontSize: 14)),
                        ]
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              if (_revealed)
                ElevatedButton(
                  onPressed: () {
                    if (_current + 1 < widget.totalPlayers) {
                      setState(() { _current++; _revealed = false; });
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyTimerScreen(time: widget.time, roles: _roles, word: widget.word)));
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: AppColors.spyRed),
                  child: Text(_current + 1 < widget.totalPlayers ? 'نفر بعدی' : 'شروع بحث', style: const TextStyle(fontSize: 18)),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class SpyTimerScreen extends StatefulWidget {
  final int time;
  final List<bool> roles;
  final String word;
  const SpyTimerScreen({super.key, required this.time, required this.roles, required this.word});
  @override
  State<SpyTimerScreen> createState() => _SpyTimerScreenState();
}

class _SpyTimerScreenState extends State<SpyTimerScreen> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.time;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); }
      else { t.cancel(); _endRound(); }
    });
  }

  void _endRound() {
    _timer?.cancel();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyVotingScreen(roles: widget.roles, word: widget.word)));
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بحث و گفتگو'), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200, height: 200,
                  child: CircularProgressIndicator(
                    value: _seconds / widget.time,
                    strokeWidth: 12,
                    backgroundColor: AppColors.cardBg,
                    valueColor: AlwaysStoppedAnimation<Color>(_seconds < 15 ? Colors.red : AppColors.spyRed),
                  ),
                ),
                Text('${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}', style: GoogleFonts.vazirmatn(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 30),
            const Text('به نوبت سوال بپرسید و جاسوس را پیدا کنید.', style: TextStyle(color: AppColors.textSub, fontSize: 16)),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: _endRound,
              icon: const Icon(Icons.how_to_vote),
              label: const Text('پایان بحث و رأی‌گیری', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
            )
          ],
        ),
      ),
    );
  }
}

class SpyVotingScreen extends StatefulWidget {
  final List<bool> roles;
  final String word;
  const SpyVotingScreen({super.key, required this.roles, required this.word});
  @override
  State<SpyVotingScreen> createState() => _SpyVotingScreenState();
}

class _SpyVotingScreenState extends State<SpyVotingScreen> {
  int? _accusedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رأی‌گیری'), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('همه با هم به چه کسی مشکوک هستند؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.roles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Card(
                    color: _accusedIndex == index ? AppColors.spyRed.withOpacity(0.3) : AppColors.cardBg,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: _accusedIndex == index ? AppColors.spyRed : Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.purple, child: Text('${index + 1}')),
                      title: Text('بازیکن ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: _accusedIndex == index ? const Icon(Icons.check_circle, color: Colors.green, size: 30) : null,
                      onTap: () => setState(() => _accusedIndex = index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _accusedIndex == null ? null : () {
                bool accusedIsSpy = widget.roles[_accusedIndex!];
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyResultScreen(
                  roles: widget.roles, word: widget.word, accusedIndex: _accusedIndex!, accusedIsSpy: accusedIsSpy,
                )));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
              child: const Text('تأیید رأی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class SpyResultScreen extends StatefulWidget {
  final List<bool> roles;
  final String word;
  final int accusedIndex;
  final bool accusedIsSpy;
  const SpyResultScreen({super.key, required this.roles, required this.word, required this.accusedIndex, required this.accusedIsSpy});
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
    String resultText = widget.accusedIsSpy ? 'جاسوس پیدا شد!\nشهروندان برنده شدند.' : 'اشتباه بود!\nجاسوس برنده شد.';
    Color resultColor = widget.accusedIsSpy ? AppColors.green : AppColors.spyRed;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.accusedIsSpy ? '✅' : '❌', style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                Text(resultText, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: resultColor), textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const Text('کلمه اصلی:', style: TextStyle(color: AppColors.textSub)),
                      Text(widget.word, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      const Text('جاسوس‌ها:', style: TextStyle(color: AppColors.textSub)),
                      ...widget.roles.asMap().entries.where((e) => e.value).map((e) => Text('🕵️ بازیکن ${e.key + 1}', style: const TextStyle(fontSize: 18, color: AppColors.spyRed, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
                  child: const Text('بازگشت به خانه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _controller, blastDirectionality: BlastDirectionality.explosive, colors: const [AppColors.gold, AppColors.purple, Colors.white])),
        ],
      ),
    );
  }
}

// ==================== PANTOMIME DATA ====================
const pantoData = {
  'عمومی (ساده)': [
    {'word': 'دویدن', 'diff': 1}, {'word': 'شیر', 'diff': 1}, {'word': 'دکتر', 'diff': 1},
    {'word': 'چتر', 'diff': 1}, {'word': 'خوشحال', 'diff': 1}, {'word': 'رقصیدن', 'diff': 1},
  ],
  'فیلم و سریال': [
    {'word': 'شرک', 'diff': 2}, {'word': 'آواتار', 'diff': 2}, {'word': 'تایتانیک', 'diff': 2},
    {'word': 'ماتریکس', 'diff': 2}, {'word': 'شیر شاه', 'diff': 2}, {'word': 'هری پاتر', 'diff': 2},
  ],
  'ضرب‌المثل‌ها (سخت)': [
    {'word': 'آب در هاون کوبیدن', 'diff': 3}, {'word': 'دست و پا چلفتی', 'diff': 3}, 
    {'word': 'خون به جگر شدن', 'diff': 3}, {'word': 'چشم و همچشمی', 'diff': 3},
  ],
  'سلبریتی‌ها': [
    {'word': 'مهران مدیری', 'diff': 2}, {'word': 'عادل فردوسی‌پور', 'diff': 2}, 
    {'word': 'جواد خیابانی', 'diff': 2}, {'word': 'نوید محمدزاده', 'diff': 2},
  ],
  'حیوانات': [
    {'word': 'پنگوئن', 'diff': 1}, {'word': 'زرافه', 'diff': 1}, {'word': 'کانگورو', 'diff': 1},
    {'word': 'هشت‌پا', 'diff': 2}, {'word': 'خفاش', 'diff': 2}, {'word': 'آفتاب‌پرست', 'diff': 2},
  ],
  'ورزش': [
    {'word': 'فوتبال', 'diff': 1}, {'word': 'شنا', 'diff': 1}, {'word': 'والیبال', 'diff': 1},
    {'word': 'بسکتبال', 'diff': 2}, {'word': 'شطرنج', 'diff': 2}, {'word': 'کاراته', 'diff': 2},
  ],
  'مشاغل': [
    {'word': 'پلیس', 'diff': 1}, {'word': 'معلم', 'diff': 1}, {'word': 'خلبان', 'diff': 2},
    {'word': 'نقاش', 'diff': 2}, {'word': 'آتش‌نشان', 'diff': 2}, {'word': 'بازیگر', 'diff': 3},
  ],
};

// ==================== PANTOMIME FLOW (NEW TURN-BASED) ====================
class PantoSetupScreen extends StatefulWidget {
  const PantoSetupScreen({super.key});
  @override
  State<PantoSetupScreen> createState() => _PantoSetupScreenState();
}

class _PantoSetupScreenState extends State<PantoSetupScreen> {
  int _totalTurns = 10;
  String _category = 'عمومی (ساده)';
  bool _isTeamMode = true;
  final TextEditingController _teamACtrl = TextEditingController(text: 'تیم قرمز');
  final TextEditingController _teamBCtrl = TextEditingController(text: 'تیم آبی');

  @override
  void dispose() { _teamACtrl.dispose(); _teamBCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم بازی پانتومیم'), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('حالت بازی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      ChoiceChip(label: const Text('انفرادی'), selected: !_isTeamMode, onSelected: (val) => setState(() => _isTeamMode = false)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('تیمی'), selected: _isTeamMode, onSelected: (val) => setState(() => _isTeamMode = true)),
                    ],
                  )
                ],
              ),
            ),
            if (_isTeamMode) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    TextField(controller: _teamACtrl, decoration: const InputDecoration(labelText: 'نام تیم اول', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: _teamBCtrl, decoration: const InputDecoration(labelText: 'نام تیم دوم', border: OutlineInputBorder())),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Total Turns selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تعداد کل دست‌ها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.pantoBlue), onPressed: () => setState(() => _totalTurns = max(_totalTurns - 2, 2))),
                      Text('$_totalTurns', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.pantoBlue), onPressed: () => setState(() => _totalTurns += 2)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('دسته‌بندی کلمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: pantoData.keys.map((cat) {
                      return ChoiceChip(label: Text(cat), selected: _category == cat, onSelected: (val) => setState(() => _category = cat));
                    }).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final words = List<Map<String, dynamic>>.from(pantoData[_category]!)..shuffle();
                Navigator.push(context, MaterialPageRoute(builder: (_) => PantoGameScreen(
                  totalTurns: _totalTurns, 
                  words: words, 
                  isTeamMode: _isTeamMode,
                  teamAName: _teamACtrl.text.isEmpty ? 'تیم قرمز' : _teamACtrl.text,
                  teamBName: _teamBCtrl.text.isEmpty ? 'تیم آبی' : _teamBCtrl.text,
                  category: _category,
                )));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pantoBlue, minimumSize: const Size(double.infinity, 55)),
              child: const Text('شروع بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class PantoGameScreen extends StatefulWidget {
  final int totalTurns;
  final List<Map<String, dynamic>> words;
  final bool isTeamMode;
  final String teamAName, teamBName, category;

  const PantoGameScreen({super.key, required this.totalTurns, required this.words, required this.isTeamMode, required this.teamAName, required this.teamBName, required this.category});

  @override
  State<PantoGameScreen> createState() => _PantoGameScreenState();
}

class _PantoGameScreenState extends State<PantoGameScreen> {
  // Game State
  int _currentTurn = 1;
  int _teamA_Score = 0;
  int _teamB_Score = 0;
  int _currentTeam = 0; // 0 = Team A, 1 = Team B
  int _wordIndex = 0;
  
  // Turn State
  bool _wordRevealed = false;
  bool _gameOver = false;
  
  // Timer State
  late int _seconds;
  Timer? _timer;
  final int _maxSeconds = 60; // 60 seconds per turn

  @override
  void initState() {
    super.initState();
    _seconds = _maxSeconds;
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _startTurn() {
    setState(() { _wordRevealed = true; _seconds = _maxSeconds; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); }
      else { 
        t.cancel(); 
        _endTurn(points: 0, success: false); // Time's up
      }
    });
  }

  void _endTurn({required int points, required bool success}) {
    _timer?.cancel();
    
    if (success) {
      setState(() {
        if (widget.isTeamMode) {
          if (_currentTeam == 0) _teamA_Score += points; else _teamB_Score += points;
        } else {
          _teamA_Score += points;
        }
      });
    }

    // Next Turn Logic
    if (_currentTurn >= widget.totalTurns) {
      setState(() => _gameOver = true);
    } else {
      setState(() {
        _currentTurn++;
        _currentTeam = _currentTeam == 0 ? 1 : 0; // Swap teams
        _wordRevealed = false;
        _seconds = _maxSeconds;
        _wordIndex = (_wordIndex + 1) % widget.words.length;
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
              Text(isDraw ? 'مساوی شد!' : '$winner برنده شد!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    if (widget.isTeamMode) ...[
                      Text('${widget.teamAName}: $_teamA_Score', style: const TextStyle(fontSize: 22, color: AppColors.spyRed, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('${widget.teamBName}: $_teamB_Score', style: const TextStyle(fontSize: 22, color: AppColors.pantoBlue, fontWeight: FontWeight.bold)),
                    ] else ...[
                      Text('امتیاز شما: $_teamA_Score', style: const TextStyle(fontSize: 22, color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
                child: const Text('بازگشت به خانه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    int currentDifficulty = widget.words[_wordIndex]['diff'];
    String currentWord = widget.words[_wordIndex]['word'];
    // Base points: 10 per difficulty star
    int basePoints = currentDifficulty * 10;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Scores and Turn)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('دست $_currentTurn از ${widget.totalTurns}', style: const TextStyle(color: AppColors.textSub, fontSize: 16)),
                  const SizedBox(height: 10),
                  if (widget.isTeamMode) Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreCard(widget.teamAName, _teamA_Score, AppColors.spyRed, _currentTeam == 0),
                      _buildScoreCard(widget.teamBName, _teamB_Score, AppColors.pantoBlue, _currentTeam == 1),
                    ],
                  ) else
                    Text('امتیاز: $_teamA_Score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gold)),
                ],
              ),
            ),
            
            const Divider(color: AppColors.cardBg),
            
            Expanded(
              child: Center(
                child: !_wordRevealed
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/7.png', width: 120),
                          const SizedBox(height: 20),
                          Text(
                            widget.isTeamMode ? 'گوشی را به ${_currentTeam == 0 ? widget.teamAName : widget.teamBName} بدهید' : 'گوشی را به اجراکننده بدهید',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: _startTurn,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('نمایش کلمه', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Timer
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120, height: 120,
                                child: CircularProgressIndicator(
                                  value: _seconds / _maxSeconds,
                                  strokeWidth: 8,
                                  backgroundColor: AppColors.cardBg,
                                  valueColor: AlwaysStoppedAnimation<Color>(_seconds < 10 ? Colors.red : AppColors.pantoBlue),
                                ),
                              ),
                              Text('$_seconds', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 30),
                          
                          // Difficulty Stars
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) => Icon(
                              Icons.star, 
                              color: i < currentDifficulty ? AppColors.gold : Colors.grey.shade800,
                              size: 30,
                            )),
                          ),
                          const SizedBox(height: 15),
                          
                          // The Single Word
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              currentWord,
                              key: ValueKey(currentWord),
                              style: GoogleFonts.vazirmatn(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('ارزش پایه: $basePoints امتیاز + پاداش سرعت', style: const TextStyle(color: AppColors.textSub)),
                        ],
                      ),
              ),
            ),
            
            // Action Buttons (Only visible when word is revealed)
            if (_wordRevealed)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed: () => _endTurn(points: 0, success: false),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, color: Colors.red),
                              Text('نتونست (صفر)', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 80,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed: () {
                            // Points = Base Points + Seconds Remaining
                            int totalPoints = basePoints + _seconds;
                            _endTurn(points: totalPoints, success: true);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Colors.white),
                              Text('درست حدس زد! (+${basePoints + _seconds})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String name, int score, Color color, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(color: isActive ? color : Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? color : AppColors.textSub)),
          Text('$score', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isActive ? Colors.white : AppColors.textSub)),
        ],
      ),
    );
  }
}
