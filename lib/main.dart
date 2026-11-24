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
      title: 'گیم پارتی', // اسم اپلیکیشن
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

// ==================== HOME SCREEN (FIXED CARDS, NO SCROLL) ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/6.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
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
              // Logo
              Image.asset('assets/images/1.png', width: 280),
              const SizedBox(height: 20),
              
              // Main Cards (Fixed using Expanded instead of ScrollView)
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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain, // جلوگیری از بریدگی و کشیدگی
          ),
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
            onChanged: (val) {
              setState(() => AppSettings.soundOn = val);
              AppSettings.save();
            },
          ),
          SwitchListTile(
            title: const Text('لرزش (ویبره)'),
            secondary: const Icon(Icons.vibration, color: AppColors.purple),
            activeColor: AppColors.purple,
            value: AppSettings.vibrationOn,
            onChanged: (val) {
              setState(() => AppSettings.vibrationOn = val);
              AppSettings.save();
            },
          ),
          const Divider(color: AppColors.cardBg),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('پاک کردن آمار بازی‌ها', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.cardBg,
                  title: const Text('مطمئنی؟'),
                  content: const Text('تمام آمارهای بازی شما پاک خواهد شد.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
                    TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آمار پاک شد!'))); }, child: const Text('بله، پاک کن', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          ),
          const Divider(color: AppColors.cardBg),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.textSub),
            title: Text('درباره گیم پارتی'),
            subtitle: Text('نسخه 2.0.0 - قوانین کامل و امتیازدهی حرفه‌ای', style: TextStyle(color: AppColors.textSub)),
          ),
        ],
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
  int _players = 5;
  int _spies = 1;
  int _time = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم بازی جاسوس'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSettingRow('تعداد بازیکنان', '$_players', () => setState(() => _players = min(_players + 1, 12)), () => setState(() => _players = max(_players - 1, 3))),
            _buildSettingRow('تعداد جاسوس‌ها', '$_spies', () => setState(() => _spies = min(_spies + 1, 3)), () => setState(() => _spies = max(_spies - 1, 1))),
            _buildSettingRow('زمان بازی (ثانیه)', '$_time', () => setState(() => _time += 30), () => setState(() => _time = max(_time - 30, 60))),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final word = spyWords[Random().nextInt(spyWords.length)];
                Navigator.push(context, MaterialPageRoute(builder: (_) => SpyRevealScreen(totalPlayers: _players, spies: _spies, time: _time, word: word)));
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

const spyWords = ['پیتزا', 'بیمارستان', 'شیر', 'چتر', 'دکتر', 'تایتانیک', 'فرودگاه', 'کتاب', 'آشپز', 'کافه', 'ساحل'];

class SpyRevealScreen extends StatefulWidget {
  final int totalPlayers, spies, time;
  final String word;
  const SpyRevealScreen({super.key, required this.totalPlayers, required this.spies, required this.time, required this.word});
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
                    width: 200, height: 300,
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.spyRed)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 60, color: AppColors.spyRed),
                        SizedBox(height: 16),
                        Text('برای دیدن نقش لمس کن'),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: 200, height: 300,
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
                      Text(isSpy ? 'تو جاسوسی!' : widget.word, style: GoogleFonts.vazirmatn(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
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
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: AppColors.spyRed),
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
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); } else { t.cancel(); }
    });
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
            Text('${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}', style: GoogleFonts.vazirmatn(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.spyRed)),
            const SizedBox(height: 20),
            const Text('به نوبت سوال بپرسید و جاسوس را پیدا کنید.', style: TextStyle(color: AppColors.textSub)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyVotingScreen(roles: widget.roles, word: widget.word))),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, minimumSize: const Size(double.infinity, 50)),
              child: const Text('پایان دور و رأی‌گیری', style: TextStyle(fontSize: 18)),
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('به چه کسی مشکوک هستید؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...widget.roles.asMap().entries.map((e) => Card(
            color: _accusedIndex == e.key ? AppColors.spyRed.withOpacity(0.3) : AppColors.cardBg,
            child: ListTile(
              leading: CircleAvatar(child: Text('${e.key + 1}')),
              title: Text('بازیکن ${e.key + 1}'),
              trailing: _accusedIndex == e.key ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () => setState(() => _accusedIndex = e.key),
            ),
          )),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _accusedIndex == null ? null : () {
              bool accusedIsSpy = widget.roles[_accusedIndex!];
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyResultScreen(
                roles: widget.roles, 
                word: widget.word, 
                accusedIndex: _accusedIndex!,
                accusedIsSpy: accusedIsSpy,
              )));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            child: const Text('تأیید رأی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    String resultText = '';
    Color resultColor = Colors.white;

    if (widget.accusedIsSpy) {
      resultText = 'جاسوس پیدا شد!\nشهروندان ۱ امتیاز گرفتند.';
      resultColor = Colors.green;
    } else {
      resultText = 'اشتباه بود!\nجاسوس برنده شد و ۱ امتیاز گرفت.';
      resultColor = AppColors.spyRed;
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.accusedIsSpy ? '✅' : '❌', style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                Text(resultText, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: resultColor), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Text('کلمه اصلی: ${widget.word}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                const Text('جاسوس‌ها:', style: TextStyle(color: AppColors.textSub)),
                ...widget.roles.asMap().entries.where((e) => e.value).map((e) => Text('🕵️ بازیکن ${e.key + 1}', style: const TextStyle(fontSize: 18, color: AppColors.spyRed))),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                  child: const Text('بازگشت به خانه'),
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

// ==================== PANTOMIME FLOW ====================
class PantoSetupScreen extends StatefulWidget {
  const PantoSetupScreen({super.key});
  @override
  State<PantoSetupScreen> createState() => _PantoSetupScreenState();
}

class _PantoSetupScreenState extends State<PantoSetupScreen> {
  int _time = 60;
  String _category = 'عمومی';
  bool _isTeamMode = true;
  final TextEditingController _teamACtrl = TextEditingController(text: 'تیم قرمز');
  final TextEditingController _teamBCtrl = TextEditingController(text: 'تیم آبی');

  @override
  void dispose() {
    _teamACtrl.dispose();
    _teamBCtrl.dispose();
    super.dispose();
  }

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
                  const Text('حالت بازی', style: TextStyle(fontSize: 16)),
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
                    TextField(controller: _teamACtrl, decoration: const InputDecoration(labelText: 'نام تیم اول')),
                    const SizedBox(height: 10),
                    TextField(controller: _teamBCtrl, decoration: const InputDecoration(labelText: 'نام تیم دوم')),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('دسته‌بندی کلمات', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: pantoCategories.keys.map((cat) {
                      return ChoiceChip(label: Text(cat), selected: _category == cat, onSelected: (val) => setState(() => _category = cat));
                    }).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('زمان (ثانیه)', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove, color: AppColors.pantoBlue), onPressed: () => setState(() => _time = max(_time - 30, 30))),
                      Text('$_time', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add, color: AppColors.pantoBlue), onPressed: () => setState(() => _time += 30)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final words = List<Map<String, dynamic>>.from(pantoCategories[_category]!)..shuffle();
                Navigator.push(context, MaterialPageRoute(builder: (_) => PantoGameScreen(
                  time: _time, 
                  words: words, 
                  isTeamMode: _isTeamMode,
                  teamAName: _teamACtrl.text.isEmpty ? 'تیم قرمز' : _teamACtrl.text,
                  teamBName: _teamBCtrl.text.isEmpty ? 'تیم آبی' : _teamBCtrl.text,
                )));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pantoBlue, minimumSize: const Size(double.infinity, 50)),
              child: const Text('شروع بازی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

const pantoCategories = {
  'عمومی': [
    {'word': 'دویدن', 'diff': 1}, {'word': 'شیر', 'diff': 1}, {'word': 'دکتر', 'diff': 1},
    {'word': 'چتر', 'diff': 2}, {'word': 'خوشحال', 'diff': 2}, {'word': 'رقصیدن', 'diff': 2},
    {'word': 'فیل', 'diff': 3}, {'word': 'آشپز', 'diff': 3}, {'word': 'کتاب', 'diff': 3},
  ],
  'فیلم و سریال': [
    {'word': 'شرک', 'diff': 1}, {'word': 'آواتار', 'diff': 2}, {'word': 'تایتانیک', 'diff': 2},
    {'word': 'ماتریکس', 'diff': 3}, {'word': 'شیر شاه', 'diff': 3}, {'word': 'هری پاتر', 'diff': 3},
  ],
  'ورزش': [
    {'word': 'فوتبال', 'diff': 1}, {'word': 'شنا', 'diff': 1}, {'word': 'والیبال', 'diff': 2},
    {'word': 'بسکتبال', 'diff': 2}, {'word': 'شطرنج', 'diff': 3}, {'word': 'کاراته', 'diff': 3},
  ],
  'مشاغل': [
    {'word': 'پلیس', 'diff': 1}, {'word': 'معلم', 'diff': 1}, {'word': 'خلبان', 'diff': 2},
    {'word': 'نقاش', 'diff': 2}, {'word': 'آتش‌نشان', 'diff': 3}, {'word': 'بازیگر', 'diff': 3},
  ],
};

class PantoGameScreen extends StatefulWidget {
  final int time;
  final List<Map<String, dynamic>> words;
  final bool isTeamMode;
  final String teamAName, teamBName;

  const PantoGameScreen({super.key, required this.time, required this.words, required this.isTeamMode, required this.teamAName, required this.teamBName});

  @override
  State<PantoGameScreen> createState() => _PantoGameScreenState();
}

class _PantoGameScreenState extends State<PantoGameScreen> {
  late int _seconds;
  Timer? _timer;
  
  int _teamA_Score = 0;
  int _teamB_Score = 0;
  int _currentTeam = 0;
  int _index = 0;
  
  bool _started = false;
  bool _roundOver = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.time;
  }

  void _startRound() {
    setState(() { _started = true; _roundOver = false; _seconds = widget.time; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); }
      else { 
        t.cancel(); 
        setState(() { _roundOver = true; _started = false; }); 
      }
    });
  }

  void _nextWord({required bool correct}) {
    if (correct) {
      int points = widget.words[_index]['diff'];
      setState(() {
        if (widget.isTeamMode) {
          if (_currentTeam == 0) _teamA_Score += points; else _teamB_Score += points;
        } else {
          _teamA_Score += points;
        }
      });
    }
    setState(() { _index = (_index + 1) % widget.words.length; });
  }

  void _nextTurn() {
    if (widget.isTeamMode) {
      if (_currentTeam == 0) {
        setState(() { _currentTeam = 1; _roundOver = false; });
      } else {
        setState(() { _gameOver = true; });
      }
    } else {
      setState(() { _gameOver = true; });
    }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_started && !_roundOver && !_gameOver) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/7.png', width: 150),
              const SizedBox(height: 20),
              Text(
                widget.isTeamMode ? (_currentTeam == 0 ? 'نوبت ${widget.teamAName} 🔴' : 'نوبت ${widget.teamBName} 🔵') : 'آماده‌ای؟',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('گوشی را به اجراکننده بدهید', style: TextStyle(color: AppColors.textSub)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startRound, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pantoBlue, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                child: const Text('شروع', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      );
    }

    if (_roundOver) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏰ زمان تمام شد!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('امتیاز تیم شما: ${_currentTeam == 0 ? _teamA_Score : _teamB_Score}', style: const TextStyle(fontSize: 24, color: AppColors.gold)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _nextTurn, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
                child: Text(widget.isTeamMode && _currentTeam == 0 ? 'نوبت تیم بعدی' : 'دیدن نتیجه نهایی', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }

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
              const SizedBox(height: 20),
              if (widget.isTeamMode) ...[
                Text('${widget.teamAName}: $_teamA_Score  |  ${widget.teamBName}: $_teamB_Score', style: const TextStyle(fontSize: 20, color: AppColors.gold)),
              ] else ...[
                Text('امتیاز شما: $_teamA_Score', style: const TextStyle(fontSize: 20, color: AppColors.gold)),
              ],
              const SizedBox(height: 40),
              ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('بازگشت به خانه')),
            ],
          ),
        ),
      );
    }

    int currentDifficulty = widget.words[_index]['diff'];
    String currentWord = widget.words[_index]['word'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isTeamMode ? (_currentTeam == 0 ? '${widget.teamAName} 🔴' : '${widget.teamBName} 🔵') : 'امتیاز: $_teamA_Score', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _currentTeam == 0 ? AppColors.spyRed : AppColors.pantoBlue)
                  ),
                  Text('$_seconds', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _seconds < 10 ? Colors.red : AppColors.pantoBlue)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Icon(
                        Icons.star, 
                        color: i < currentDifficulty ? AppColors.gold : Colors.grey.shade800,
                        size: 30,
                      )),
                    ),
                    const SizedBox(height: 20),
                    Text(currentWord, style: GoogleFonts.vazirmatn(fontSize: 56, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                        onPressed: () => _nextWord(correct: false),
                        child: const Text('رد کردن\n(۰ امتیاز)', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                        onPressed: () => _nextWord(correct: true),
                        child: Text('درست بود\n(+$currentDifficulty امتیاز)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}
