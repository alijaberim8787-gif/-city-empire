import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const GamePartyApp());
}

// ==================== COLORS & THEME ====================
class AppColors {
  static const bg = Color(0xFF090713);
  static const cardBg = Color(0xFF171128);
  static const purple = Color(0xFF8B35F5);
  static const lightPurple = Color(0xFFC45CFF);
  static const gold = Color(0xFFFFBF36);
  static const spyRed = Color(0xFFF52D4F);
  static const pantoBlue = Color(0xFF2585FF);
  static const textMain = Colors.white;
  static const textSub = Color(0xFFA7A0B8);
}

class GamePartyApp extends StatelessWidget {
  const GamePartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Party',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: AppColors.textMain, displayColor: AppColors.textMain),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.gold,
          surface: AppColors.cardBg,
        ),
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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A1548), AppColors.bg],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🕵️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                'Game Party',
                style: GoogleFonts.vazirmatn(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                  shadows: [const Shadow(color: AppColors.gold, blurRadius: 20)],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Play Together • Laugh Together', style: TextStyle(color: AppColors.textSub)),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: AppColors.purple),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.cardBg,
                    child: Icon(Icons.person, color: AppColors.purple),
                  ),
                  Text('Game Party', style: GoogleFonts.vazirmatn(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gold)),
                  const Icon(Icons.settings, color: AppColors.textSub),
                ],
              ),
              const SizedBox(height: 40),
              // Cards
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GameCard(
                      title: 'بازی جاسوس',
                      subtitle: 'ببین چه کسی جاسوس است!',
                      emoji: '🕵️‍♂️',
                      color: AppColors.spyRed,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpySetupScreen())),
                    ),
                    const SizedBox(height: 20),
                    _GameCard(
                      title: 'بازی پانتومیم',
                      subtitle: 'بدون حرف زدن، کلمه را اجرا کن!',
                      emoji: '🎭',
                      color: AppColors.pantoBlue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantoSetupScreen())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, subtitle, emoji;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({required this.title, required this.subtitle, required this.emoji, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10))
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -10,
              bottom: -10,
              child: Text(emoji, style: const TextStyle(fontSize: 100)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: GoogleFonts.vazirmatn(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSub, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('شروع بازی', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.play_arrow, size: 18),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SPY FLOW ====================
class SpySetupScreen extends StatefulWidget {
  const SpySetupScreen({super.key});
  @override
  State<SpySetupScreen> createState() => _SpySetupScreenState();
}

class _SpySetupScreenState extends State<SpySetupScreen> {
  int _players = 4;
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

const spyWords = ['پیتزا', 'بیمارستان', 'شیر', 'چتر', 'دکتر', 'تایتانیک', 'فرودگاه', 'کتاب', 'آشپز'];

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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SpyResultScreen(roles: widget.roles, word: widget.word))),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
              child: const Text('پایان دور و رأی‌گیری'),
            )
          ],
        ),
      ),
    );
  }
}

class SpyResultScreen extends StatefulWidget {
  final List<bool> roles;
  final String word;
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
                const Text('🏆', style: TextStyle(fontSize: 100)),
                const Text('بازی تمام شد!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم پانتومیم'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('زمان (ثانیه)'),
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
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final words = List.from(pantoWords)..shuffle();
                Navigator.push(context, MaterialPageRoute(builder: (_) => PantoGameScreen(time: _time, words: words)));
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

const pantoWords = ['دویدن', 'شیر', 'دکتر', 'چتر', 'خوشحال', 'رقصیدن', 'فیل', 'آشپز', 'کتاب'];

class PantoGameScreen extends StatefulWidget {
  final int time;
  final List<String> words;
  const PantoGameScreen({super.key, required this.time, required this.words});
  @override
  State<PantoGameScreen> createState() => _PantoGameScreenState();
}

class _PantoGameScreenState extends State<PantoGameScreen> {
  late int _seconds;
  Timer? _timer;
  int _score = 0;
  int _index = 0;
  bool _started = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.time;
  }

  void _start() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds > 0) { setState(() => _seconds--); }
      else { t.cancel(); setState(() { _gameOver = true; _started = false; }); }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_started && !_gameOver) {
      return Scaffold(body: Center(child: ElevatedButton(onPressed: _start, child: const Text('شروع'))));
    }
    if (_gameOver) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏰ زمان تمام شد!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('امتیاز شما: $_score', style: TextStyle(fontSize: 24, color: AppColors.gold)),
              const SizedBox(height: 40),
              ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('بازگشت')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('امتیاز: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold)),
                  Text('$_seconds', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _seconds < 10 ? Colors.red : AppColors.pantoBlue)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(widget.words[_index], style: GoogleFonts.vazirmatn(fontSize: 56, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                        onPressed: () => setState(() { _index = (_index + 1) % widget.words.length; }),
                        child: const Text('رد کردن', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                        onPressed: () => setState(() { _score++; _index = (_index + 1) % widget.words.length; }),
                        child: const Text('درست بود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
