import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const PartyGamesApp());

class PartyGamesApp extends StatelessWidget {
  const PartyGamesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بازی دورهمی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
          brightness: Brightness.dark,
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeScreen(),
    );
  }
}

// ==================== HOME ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('🎉', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 10),
                const Text('بازی دورهمی',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
                const Text('برای شب‌های دوستانه',
                    style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 40),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GameCard(
                        emoji: '🕵️',
                        title: 'جاسوس',
                        subtitle: 'کی جاسوسه؟',
                        color: const Color(0xFF6A1B9A),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SpySetupScreen())),
                      ),
                      const SizedBox(height: 16),
                      _GameCard(
                        emoji: '🎭',
                        title: 'پانتومیم',
                        subtitle: 'بی‌صدا بازی کن',
                        color: const Color(0xFF1565C0),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PantoSetupScreen())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.5)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SPY WORDS ====================
const spyCategories = <String, List<String>>{
  'غذا': [
    'پیتزا', 'کباب کوبیده', 'قورمه سبزی', 'آش رشته', 'فسنجان',
    'زرشک پلو', 'عدس پلو', 'سالاد شیرازی', 'املت', 'کتلت'
  ],
  'مکان': [
    'بیمارستان', 'فرودگاه', 'دانشگاه', 'رستوران', 'پارک',
    'کوه', 'جنگل', 'ساحل', 'سینما', 'کتابخانه'
  ],
  'حیوان': [
    'شیر', 'فیل', 'زرافه', 'پنگوئن', 'دلفین',
    'طوطی', 'کوالا', 'گربه', 'خرس', 'کبوتر'
  ],
  'وسیله': [
    'چتر', 'عینک', 'ساعت', 'کیف', 'لپ‌تاپ',
    'صندلی', 'ماشین', 'آینه', 'چاقو', 'کلید'
  ],
  'حرفه': [
    'دکتر', 'معلم', 'خلبان', 'آشپز', 'بازیگر',
    'راننده', 'پلیس', 'نقاش', 'خبرنگار', 'خواننده'
  ],
  'فیلم': [
    'تایتانیک', 'آواتار', 'ماتریکس', 'شرک', 'شیر شاه',
    'هری پاتر', 'فروزن', 'جوراسیک پارک'
  ],
};

// ==================== SPY SETUP ====================
class SpySetupScreen extends StatefulWidget {
  const SpySetupScreen({super.key});
  @override
  State<SpySetupScreen> createState() => _SpySetupScreenState();
}

class _SpySetupScreenState extends State<SpySetupScreen> {
  final List<String> _players = ['بازیکن ۱', 'بازیکن ۲', 'بازیکن ۳'];
  final TextEditingController _nameCtrl = TextEditingController();
  int _spyCount = 1;
  String _category = 'غذا';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _players.add(name);
      _nameCtrl.clear();
    });
  }

  void _start() {
    if (_players.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل ۳ بازیکن لازم است')),
      );
      return;
    }
    final maxSpies = (_players.length ~/ 2).clamp(1, 5);
    final spies = _spyCount.clamp(1, maxSpies);
    final wordList = spyCategories[_category]!;
    final word = wordList[Random().nextInt(wordList.length)];
    final players = List<String>.from(_players)..shuffle();
    final spyIndices = <int>{};
    while (spyIndices.length < spies) {
      spyIndices.add(Random().nextInt(players.length));
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpyRevealScreen(
          players: players,
          spyIndices: spyIndices,
          word: word,
          category: _category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxSpies = (_players.length ~/ 2).clamp(1, 5);
    return Scaffold(
      appBar: AppBar(title: const Text('🕵️ تنظیم بازی جاسوس')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('بازیکن‌ها',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'نام بازیکن',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addPlayer(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                  onPressed: _addPlayer, icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _players.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value),
                onDeleted: _players.length > 3
                    ? () => setState(() => _players.removeAt(e.key))
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('تعداد جاسوس',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(
                maxSpies,
                (i) => ChoiceChip(
                      label: Text('${i + 1}'),
                      selected: _spyCount == i + 1,
                      onSelected: (_) => setState(() => _spyCount = i + 1),
                    )),
          ),
          const SizedBox(height: 24),
          const Text('دستهٔ کلمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: spyCategories.keys
                .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('شروع بازی', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SPY REVEAL ====================
class SpyRevealScreen extends StatefulWidget {
  final List<String> players;
  final Set<int> spyIndices;
  final String word, category;
  const SpyRevealScreen({
    super.key,
    required this.players,
    required this.spyIndices,
    required this.word,
    required this.category,
  });
  @override
  State<SpyRevealScreen> createState() => _SpyRevealScreenState();
}

class _SpyRevealScreenState extends State<SpyRevealScreen> {
  int _current = 0;
  bool _revealed = false;

  void _next() {
    if (_current + 1 < widget.players.length) {
      setState(() {
        _current++;
        _revealed = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => SpyDiscussionScreen(
                  players: widget.players,
                  spyIndices: widget.spyIndices,
                  word: widget.word,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpy = widget.spyIndices.contains(_current);
    final name = widget.players[_current];
    return Scaffold(
      appBar: AppBar(
        title: Text('نقش ${_current + 1} از ${widget.players.length}'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('گوشی را به این شخص بده',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 40),
              if (!_revealed)
                GestureDetector(
                  onTap: () => setState(() => _revealed = true),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.touch_app, size: 60, color: Colors.amber),
                        SizedBox(height: 8),
                        Text('برای دیدن نقش لمس کن',
                            style: TextStyle(color: Colors.amber)),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isSpy ? Colors.red.shade900 : Colors.green.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(isSpy ? '🕵️' : '👤',
                          style: const TextStyle(fontSize: 60)),
                      const SizedBox(height: 12),
                      if (isSpy) ...[
                        const Text('تو جاسوسی!',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('دستهٔ کلمه: ${widget.category}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('وانمود کن می‌دونی کلمه چیه!',
                            textAlign: TextAlign.center),
                      ] else ...[
                        const Text('کلمهٔ تو:',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(widget.word,
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('دسته: ${widget.category}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              if (_revealed)
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_back),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: Text(
                        _current + 1 < widget.players.length
                            ? 'نفر بعدی'
                            : 'شروع بحث',
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SPY DISCUSSION ====================
class SpyDiscussionScreen extends StatefulWidget {
  final List<String> players;
  final Set<int> spyIndices;
  final String word;
  const SpyDiscussionScreen({
    super.key,
    required this.players,
    required this.spyIndices,
    required this.word,
  });
  @override
  State<SpyDiscussionScreen> createState() => _SpyDiscussionScreenState();
}

class _SpyDiscussionScreenState extends State<SpyDiscussionScreen> {
  Timer? _timer;
  int _seconds = 180;
  bool _timerRunning = false;

  void _toggleTimer() {
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
    } else {
      setState(() => _timerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_seconds <= 0) {
          t.cancel();
          setState(() => _timerRunning = false);
        } else {
          setState(() => _seconds--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بحث و گفتگو')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
              'به نوبت دربارهٔ کلمه صحبت کنید و جاسوس را پیدا کنید!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(_timeStr,
                    style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: _toggleTimer,
                  icon: Icon(_timerRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_timerRunning ? 'توقف' : 'شروع تایمر'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('رأی‌گیری',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('روی کسی که فکر می‌کنید جاسوسه بزنید:',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 12),
          ...widget.players.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${e.key + 1}')),
                    title: Text(e.value),
                    trailing:
                        const Icon(Icons.arrow_back_ios_new, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SpyResultScreen(
                                    players: widget.players,
                                    spyIndices: widget.spyIndices,
                                    word: widget.word,
                                    accused: e.key,
                                  )));
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ==================== SPY RESULT ====================
class SpyResultScreen extends StatelessWidget {
  final List<String> players;
  final Set<int> spyIndices;
  final String word;
  final int accused;
  const SpyResultScreen({
    super.key,
    required this.players,
    required this.spyIndices,
    required this.word,
    required this.accused,
  });

  @override
  Widget build(BuildContext context) {
    final accusedIsSpy = spyIndices.contains(accused);
    return Scaffold(
      appBar: AppBar(title: const Text('نتیجه')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(accusedIsSpy ? '✅' : '❌',
                  style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                accusedIsSpy ? 'درست حدس زدید!' : 'اشتباه بود!',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('کلمهٔ اصلی:',
                          style: TextStyle(color: Colors.white54)),
                      Text(word,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber)),
                      const SizedBox(height: 16),
                      const Text('جاسوس‌ها:',
                          style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 4),
                      ...spyIndices.map((i) => Text('🕵️ ${players[i]}',
                          style: const TextStyle(fontSize: 18))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                icon: const Icon(Icons.home),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text('بازی جدید', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PANTOMIME WORDS ====================
const pantoWords = <String, List<String>>{
  'افعال': [
    'دویدن', 'پریدن', 'خندیدن', 'گریه کردن', 'رقصیدن',
    'آواز خواندن', 'شنا کردن', 'خوابیدن', 'غذا خوردن', 'مسواک زدن'
  ],
  'حیوانات': [
    'شیر', 'فیل', 'میمون', 'پنگوئن', 'خرگوش',
    'مار', 'عقاب', 'اسب', 'گاو', 'سگ'
  ],
  'حرفه‌ها': [
    'دکتر', 'معلم', 'خلبان', 'آشپز', 'بازیگر',
    'راننده', 'پلیس', 'نقاش', 'خبرنگار', 'خواننده'
  ],
  'اشیا': [
    'چتر', 'عینک', 'ساعت', 'تلفن', 'صندلی',
    'ماشین', 'آینه', 'چاقو', 'کتاب', 'توپ'
  ],
  'احساسات': [
    'خوشحال', 'عصبانی', 'خسته', 'ترسیده',
    'گیج', 'هیجان‌زده', 'ناراحت', 'مغرور'
  ],
};

// ==================== PANTO SETUP ====================
class PantoSetupScreen extends StatefulWidget {
  const PantoSetupScreen({super.key});
  @override
  State<PantoSetupScreen> createState() => _PantoSetupScreenState();
}

class _PantoSetupScreenState extends State<PantoSetupScreen> {
  String _category = 'افعال';
  int _duration = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎭 تنظیم پانتومیم')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('دستهٔ کلمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pantoWords.keys
                .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('مدت زمان هر دور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [30, 60, 90, 120]
                .map((s) => ChoiceChip(
                      label: Text('$s ثانیه'),
                      selected: _duration == s,
                      onSelected: (_) => setState(() => _duration = s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              final words = List<String>.from(pantoWords[_category]!)
                ..shuffle();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PantoGameScreen(
                            words: words,
                            duration: _duration,
                          )));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('شروع بازی', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PANTO GAME ====================
class PantoGameScreen extends StatefulWidget {
  final List<String> words;
  final int duration;
  const PantoGameScreen(
      {super.key, required this.words, required this.duration});
  @override
  State<PantoGameScreen> createState() => _PantoGameScreenState();
}

class _PantoGameScreenState extends State<PantoGameScreen> {
  late List<String> _words;
  Timer? _timer;
  int _seconds = 0;
  int _score = 0;
  int _skipped = 0;
  int _index = 0;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _words = List<String>.from(widget.words);
    _seconds = widget.duration;
  }

  void _start() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() {
          _seconds = 0;
          _finished = true;
        });
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _next({required bool correct}) {
    setState(() {
      if (correct) {
        _score++;
      } else {
        _skipped++;
      }
      _index++;
      if (_index >= _words.length) {
        _words.shuffle();
        _index = 0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy, size: 100, color: Colors.amber),
              const SizedBox(height: 24),
              const Text('گوشی را بگیر',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${widget.duration} ثانیه فرصت داری',
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow),
                label: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text('شروع', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_finished) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 80)),
                const Text('زمان تمام شد!',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          const Text('✅', style: TextStyle(fontSize: 40)),
                          Text('$_score',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          const Text('درست'),
                        ]),
                        Column(children: [
                          const Text('⏭️', style: TextStyle(fontSize: 40)),
                          Text('$_skipped',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                          const Text('رد شده'),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  icon: const Icon(Icons.home),
                  label: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text('بازی جدید',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _seconds < 10
                  ? Colors.red.shade900
                  : const Color(0xFF1565C0),
              const Color(0xFF0D47A1)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _pill('$_score', Colors.green, 'درست'),
                    _pill(_seconds.toString(),
                        _seconds < 10 ? Colors.red : Colors.amber, 'ثانیه'),
                    _pill('$_skipped', Colors.orange, 'رد'),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _words[_index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange.shade700),
                          onPressed: () => _next(correct: false),
                          icon: const Icon(Icons.skip_next),
                          label: const Text('رد کن',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 70,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.green.shade700),
                          onPressed: () => _next(correct: true),
                          icon: const Icon(Icons.check),
                          label: const Text('درست',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
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

  Widget _pill(String value, Color color, String label) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
