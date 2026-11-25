import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const GamePartyApp());
}

// ============================================================
//  COLORS, SETTINGS, STATS
// ============================================================
class AppColors {
  static const bg = Color(0xFF090713);
  static const cardBg = Color(0xFF171128);
  static const purple = Color(0xFF8B35F5);
  static const gold = Color(0xFFFFBF36);
  static const spyRed = Color(0xFFF52D4F);
  static const pantoBlue = Color(0xFF2585FF);
  static const textSub = Color(0xFFA7A0B8);
  static const green = Color(0xFF4CAF50);
  static const orange = Color(0xFFFF9800);

  /// رنگ تیم‌ها در پانتومیم (تا ۶ تیم)
  static const teams = [spyRed, pantoBlue, gold, green, purple, orange];
}

class AppSettings {
  static bool soundOn = true;
  static bool vibrationOn = true;
  static int totalGames = 0;
  static int spyGames = 0;
  static int pantoGames = 0;
  static int citizenWins = 0;
  static int spyWins = 0;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    soundOn = p.getBool('sound') ?? true;
    vibrationOn = p.getBool('vibration') ?? true;
    totalGames = p.getInt('totalGames') ?? 0;
    spyGames = p.getInt('spyGames') ?? 0;
    pantoGames = p.getInt('pantoGames') ?? 0;
    citizenWins = p.getInt('citizenWins') ?? 0;
    spyWins = p.getInt('spyWins') ?? 0;
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('sound', soundOn);
    await p.setBool('vibration', vibrationOn);
    await p.setInt('totalGames', totalGames);
    await p.setInt('spyGames', spyGames);
    await p.setInt('pantoGames', pantoGames);
    await p.setInt('citizenWins', citizenWins);
    await p.setInt('spyWins', spyWins);
  }

  static Future<void> resetStats() async {
    totalGames = spyGames = pantoGames = citizenWins = spyWins = 0;
    await save();
  }

  static void recordSpy(bool citizensWin) {
    totalGames++;
    spyGames++;
    if (citizensWin) {
      citizenWins++;
    } else {
      spyWins++;
    }
    save();
  }

  static void recordPanto() {
    totalGames++;
    pantoGames++;
    save();
  }

  /// بازخورد سبک (لمس، تیک ثانیه‌شمار)
  static void vibrate() {
    if (vibrationOn) HapticFeedback.selectionClick();
    if (soundOn) SystemSound.play(SystemSoundType.click);
  }

  /// بازخورد قوی (پایان زمان، نتیجه)
  static void alert() {
    if (vibrationOn) HapticFeedback.heavyImpact();
    if (soundOn) SystemSound.play(SystemSoundType.alert);
  }
}

// ============================================================
//  SHARED WIDGETS
// ============================================================
class Img extends StatelessWidget {
  final String name;
  final double? width;
  final BoxFit fit;
  const Img(this.name, {super.key, this.width, this.fit = BoxFit.contain});
  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/$name',
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => SizedBox(width: width),
      );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  const AppCard({super.key, required this.child, this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color ?? AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionTitle(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      );
}

class StepperRow extends StatelessWidget {
  final String title, value;
  final Color color;
  final VoidCallback onInc, onDec;
  const StepperRow({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.onInc,
    required this.onDec,
  });
  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: color),
              onPressed: () {
                AppSettings.vibrate();
                onDec();
              },
            ),
            SizedBox(
              width: 48,
              child: Text(value,
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: color),
              onPressed: () {
                AppSettings.vibrate();
                onInc();
              },
            ),
          ],
        ),
      );
}

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color, foreground;
  final IconData icon;
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.purple,
    this.foreground = Colors.white,
    this.icon = Icons.check,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed == null
              ? null
              : () {
                  AppSettings.vibrate();
                  onPressed!();
                },
          icon: Icon(icon, size: 22),
          label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: foreground,
            disabledBackgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
}

Future<bool> confirmExit(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('خروج از بازی؟'),
      content: const Text('پیشرفت این بازی از بین می‌رود.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ادامه بازی')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('خروج', style: TextStyle(color: AppColors.spyRed)),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// قبل از برگشت از وسط بازی تأیید می‌گیرد.
class ExitGuard extends StatelessWidget {
  final Widget child;
  const ExitGuard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final ok = await confirmExit(context);
          if (ok && context.mounted) Navigator.of(context).pop();
        },
        child: child,
      );
}

class RuleSection {
  final String title;
  final List<String> lines;
  const RuleSection(this.title, this.lines);
}

void showRulesSheet(BuildContext context, String title, List<RuleSection> sections) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scroll) => Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textSub, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold)),
            const SizedBox(height: 14),
            for (final s in sections) ...[
              Text(s.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              for (final l in s.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: TextStyle(color: AppColors.purple, fontSize: 16)),
                      Expanded(
                        child: Text(l, style: const TextStyle(color: AppColors.textSub, fontSize: 15, height: 1.6)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    ),
  );
}

// ============================================================
//  SETUP UI KIT (حرفه‌ای‌سازی صفحه‌های تنظیم بازی)
// ============================================================
BoxDecoration _tileDeco() => BoxDecoration(
      color: AppColors.cardBg.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    );

InputDecoration fieldDeco(String label, Color color, {IconData icon = Icons.person_rounded, Color? iconColor}) =>
    InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      prefixIcon: Icon(icon, size: 18, color: iconColor ?? color),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
    );

class GlowBackground extends StatelessWidget {
  final Color color;
  final Widget child;
  const GlowBackground({super.key, required this.color, required this.child});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.1),
            radius: 1.3,
            colors: [color.withOpacity(0.30), AppColors.bg],
            stops: const [0, 0.7],
          ),
        ),
        child: child,
      );
}

class SetupHeader extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onRules;
  const SetupHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onRules,
  });
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [color, Color.lerp(color, AppColors.bg, 0.55)!],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'قوانین',
              icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.18)),
              onPressed: () {
                AppSettings.vibrate();
                onRules();
              },
            ),
          ],
        ),
      );
}

class SetupSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  final Widget? trailing;
  const SetupSection({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: _tileDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoundBtn(this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Material(
        color: color.withOpacity(0.18),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            AppSettings.vibrate();
            onTap();
          },
          child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 20, color: color)),
        ),
      );
}

class CounterTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final VoidCallback onInc, onDec;
  const CounterTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onInc,
    required this.onDec,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _tileDeco(),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundBtn(Icons.remove, color, onDec),
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                _RoundBtn(Icons.add, color, onInc),
              ],
            ),
          ],
        ),
      );
}

class ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;
  const ToggleTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _tileDeco(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSub))),
              ],
            ),
            const SizedBox(height: 6),
            Switch(
              value: value,
              activeColor: color,
              onChanged: (v) {
                AppSettings.vibrate();
                onChanged(v);
              },
            ),
          ],
        ),
      );
}

class Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const Pill({super.key, required this.label, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          AppSettings.vibrate();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected ? LinearGradient(colors: [color, Color.lerp(color, AppColors.bg, 0.35)!]) : null,
            color: selected ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: selected ? color : Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[const Icon(Icons.check, size: 15, color: Colors.white), const SizedBox(width: 5)],
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.white : AppColors.textSub,
                  )),
            ],
          ),
        ),
      );
}

class StartBar extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const StartBar({super.key, required this.label, required this.color, required this.onPressed});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.bg.withOpacity(0.95), AppColors.bg],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, Color.lerp(color, AppColors.bg, 0.3)!]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: color.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  AppSettings.vibrate();
                  onPressed();
                },
                child: SizedBox(
                  height: 58,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class SetupScaffold extends StatelessWidget {
  final Color color;
  final String title, startLabel;
  final VoidCallback onStart;
  final List<Widget> children;
  const SetupScaffold({
    super.key,
    required this.color,
    required this.title,
    required this.startLabel,
    required this.onStart,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => GlowBackground(
        color: color,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: Text(title)),
          body: Column(
            children: [
              Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), children: children)),
              StartBar(label: startLabel, color: color, onPressed: onStart),
            ],
          ),
        ),
      );
}

// ============================================================
//  APP + SPLASH + HOME
// ============================================================
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
        useMaterial3: true,
        textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme).apply(bodyColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: ZoomPageTransitionsBuilder()},
        ),
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  late final Animation<double> _scale =
      Tween(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  late final Animation<double> _glow =
      Tween(begin: 0.1, end: 0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.wait([AppSettings.load(), Future.delayed(const Duration(milliseconds: 2800))]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
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
          image: DecorationImage(image: AssetImage('assets/images/6.png'), fit: BoxFit.cover, opacity: 0.5),
          gradient: RadialGradient(colors: [Color(0xFF2A1548), AppColors.bg], radius: 1.2),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(_glow.value), blurRadius: 50, spreadRadius: 20)],
              ),
              child: ScaleTransition(scale: _scale, child: const Img('1.png', width: 250)),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, Widget page) {
    AppSettings.vibrate();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

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
                    IconButton(
                      icon: const Img('4.png', width: 40),
                      onPressed: () => _go(context, const SettingsScreen()),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu_book, color: AppColors.textSub, size: 30),
                          onPressed: () => _go(context, const CategoriesScreen()),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bar_chart, color: AppColors.textSub, size: 30),
                          onPressed: () => _go(context, const StatsScreen()),
                        ),
                      ],
                    ),
                    const Img('5.png', width: 40),
                  ],
                ),
              ),
              const Img('1.png', width: 260),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Expanded(child: _card('2.png', () => _go(context, const SpySetupScreen()))),
                      const SizedBox(height: 16),
                      Expanded(child: _card('3.png', () => _go(context, const PantoSetupScreen()))),
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

  Widget _card(String image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: image,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Img(image)),
        ),
      ),
    );
  }
}

// ============================================================
//  STATS + SETTINGS + CATEGORIES
// ============================================================
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <(String, int, IconData, Color)>[
      ('کل بازی‌ها', AppSettings.totalGames, Icons.sports_esports, AppColors.gold),
      ('بازی جاسوس', AppSettings.spyGames, Icons.visibility_off, AppColors.spyRed),
      ('بازی پانتومیم', AppSettings.pantoGames, Icons.theater_comedy, AppColors.pantoBlue),
      ('برد شهروندان', AppSettings.citizenWins, Icons.verified_user, AppColors.green),
      ('برد جاسوس‌ها', AppSettings.spyWins, Icons.person_search, AppColors.purple),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('آمار بازی‌ها')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: [
          for (final t in tiles)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.$4.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.$3, size: 36, color: t.$4),
                  const SizedBox(height: 8),
                  Text('${t.$2}', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: t.$4)),
                  const SizedBox(height: 4),
                  Text(t.$1, style: const TextStyle(color: AppColors.textSub)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('مطمئنی؟'),
        content: const Text('تمام آمار بازی‌ها پاک می‌شود. تنظیمات صدا و لرزش دست‌نخورده می‌ماند.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('پاک کن', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AppSettings.resetStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آمار پاک شد.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('صدای بازی'),
            secondary: const Icon(Icons.volume_up, color: AppColors.purple),
            activeColor: AppColors.purple,
            value: AppSettings.soundOn,
            onChanged: (v) {
              setState(() => AppSettings.soundOn = v);
              AppSettings.save();
              AppSettings.vibrate();
            },
          ),
          SwitchListTile(
            title: const Text('لرزش (ویبره)'),
            secondary: const Icon(Icons.vibration, color: AppColors.purple),
            activeColor: AppColors.purple,
            value: AppSettings.vibrationOn,
            onChanged: (v) {
              setState(() => AppSettings.vibrationOn = v);
              AppSettings.save();
              AppSettings.vibrate();
            },
          ),
          const Divider(color: AppColors.cardBg),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('پاک کردن آمار', style: TextStyle(color: Colors.red)),
            onTap: _confirmReset,
          ),
          const Divider(color: AppColors.cardBg),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.textSub),
            title: const Text('درباره گیم پارتی'),
            isThreeLine: true,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 2),
                Text('نسخه 5.1.0', style: TextStyle(color: AppColors.textSub)),
                SizedBox(height: 6),
                Text(
                  'Creator: Mr_Ping',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دسته‌بندی کلمات'),
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            tabs: [Tab(text: 'پانتومیم'), Tab(text: 'جاسوس')],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: pantoData.keys.map((cat) {
                final words = pantoData[cat]!;
                return ExpansionTile(
                  title: Text(cat, style: const TextStyle(color: AppColors.pantoBlue, fontWeight: FontWeight.bold)),
                  subtitle: Text('${words.length} کلمه', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                  children: words
                      .map((w) => ListTile(
                            title: Text(w.word),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                3,
                                (i) => Icon(Icons.star, size: 16, color: i < w.diff ? AppColors.gold : Colors.grey),
                              ),
                            ),
                          ))
                      .toList(),
                );
              }).toList(),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: spyData.keys.map((cat) {
                final words = spyData[cat]!;
                return ExpansionTile(
                  title: Text(cat, style: const TextStyle(color: AppColors.spyRed, fontWeight: FontWeight.bold)),
                  subtitle: Text('${words.length} کلمه', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [for (final w in words) Chip(label: Text(w), backgroundColor: AppColors.cardBg)],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  DATA
// ============================================================
class PantoWord {
  final String word;
  final int diff;
  const PantoWord(this.word, this.diff);
}

const spyData = {
  'مکان‌ها': ['بیمارستان', 'فرودگاه', 'دانشگاه', 'رستوران', 'پارک', 'کافه', 'سینما', 'کتابخانه', 'بانک', 'هتل', 'موزه', 'بازار', 'زندان', 'مدرسه', 'پارکینگ', 'پمپ بنزین', 'داروخانه', 'باشگاه ورزشی', 'استادیوم', 'تئاتر'],
  'سفر': ['کوه', 'جنگل', 'ساحل', 'بیابان', 'جزیره', 'دریاچه', 'تونل', 'ایستگاه قطار', 'کشتی', 'قطار', 'هواپیما', 'اتوبوس', 'مترو', 'تاکسی', 'دوچرخه', 'کوله‌پشتی', 'چادر', 'نقشه', 'قطب‌نما', 'بلیط'],
  'غذا': ['پیتزا', 'کباب', 'قورمه سبزی', 'آش رشته', 'فسنجان', 'املت', 'سالاد', 'سوشی', 'برگر', 'ماکارونی', 'جوجه کباب', 'قیمه', 'عدس پلو', 'زرشک پلو', 'باقالی پلو', 'دلمه', 'کوکو', 'کشک بادمجان', 'میگو', 'ماهی'],
  'حیوانات': ['شیر', 'فیل', 'زرافه', 'پنگوئن', 'دلفین', 'طوطی', 'کوالا', 'گربه', 'خرس', 'کبوتر', 'ببر', 'پلنگ', 'گرگ', 'روباه', 'اسب', 'گاو', 'گوسفند', 'مرغ', 'اردک', 'عقاب'],
  'مشاغل': ['دکتر', 'معلم', 'خلبان', 'آشپز', 'بازیگر', 'راننده', 'پلیس', 'نقاش', 'خبرنگار', 'خواننده', 'مهندس', 'وکیل', 'پرستار', 'آتش‌نشان', 'نجار', 'بنا', 'خیاط', 'آرایشگر', 'عکاس', 'کشاورز'],
  'اشیاء': ['چتر', 'عینک', 'ساعت', 'کیف', 'لپ‌تاپ', 'صندلی', 'ماشین', 'آینه', 'چاقو', 'کلید', 'تلفن', 'دفتر', 'مداد', 'کتاب', 'توپ', 'پنجره', 'در', 'دیوار', 'فرش', 'لامپ'],
  'فیلم': ['تایتانیک', 'آواتار', 'ماتریکس', 'شرک', 'شیر شاه', 'هری پاتر', 'فروزن', 'جوراسیک پارک', 'انتقام‌جویان', 'بتمن', 'سوپرمن', 'مرد عنکبوتی', 'دزدان دریایی', 'جنگ ستارگان', 'ارباب حلقه‌ها', 'هالک', 'آیرون من', 'مرد مورچه‌ای', 'پاندای کونگ‌فوکار', 'ماداگاسکار'],
  'ورزش': ['فوتبال', 'والیبال', 'بسکتبال', 'شنا', 'شطرنج', 'کاراته', 'تنیس', 'کوهنوردی', 'بوکس', 'کشتی', 'ژیمناستیک', 'دوچرخه‌سواری', 'اسکی', 'اسکیت', 'گلف', 'بیسبال', 'هاکی', 'بولینگ', 'تیراندازی', 'شمشیربازی'],
  'احساسات': ['عصبانی', 'خسته', 'ترسیده', 'عاشق', 'مغرور', 'حسود', 'خوشحال', 'غمگین', 'هیجان‌زده', 'نگران', 'شگفت‌زده', 'آرام', 'بی‌حوصله', 'دلواپس', 'شرمنده', 'مضطرب', 'امیدوار', 'ناامید', 'متعجب', 'راضی'],
  'تکنولوژی': ['کامپیوتر', 'موبایل', 'تبلت', 'هدفون', 'دوربین', 'پرینتر', 'مودم', 'فلش', 'هارد', 'کیبورد', 'ماوس', 'مانیتور', 'باتری', 'شارژر', 'رام', 'سی‌پی‌یو', 'کارت گرافیک', 'بلندگو', 'میکروفون', 'ساعت هوشمند'],
};

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

// ============================================================
//  RULES
// ============================================================
const spyRules = <RuleSection>[
  RuleSection('هدف', [
    'همه یک کلمهٔ مخفی را می‌دانند، به‌جز جاسوس که فقط دسته‌بندی را می‌داند (اگر این گزینه روشن باشد).',
    'شهروندان باید جاسوس را پیدا کنند بدون اینکه کلمه را لو بدهند.',
    'جاسوس باید خودش را شبیه بقیه نشان بدهد و کلمه را حدس بزند.',
  ]),
  RuleSection('دیدن نقش', [
    'گوشی به نوبت دست هر بازیکن می‌رسد.',
    'انگشتت را روی کارت نگه دار تا نقشت دیده شود. با برداشتن انگشت کارت پنهان می‌شود.',
    'نقشت را به هیچ‌کس نشان نده.',
  ]),
  RuleSection('بحث', [
    'اپلیکیشن یک نفر را به‌عنوان شروع‌کننده انتخاب می‌کند. او از یک نفر دربارهٔ کلمه سؤال می‌پرسد.',
    'کسی که جواب داده، سؤال بعدی را از نفر دیگری می‌پرسد. سؤال را نمی‌شود بلافاصله به کسی که از تو پرسیده برگرداند.',
    'سؤال نباید خود کلمه را بگوید. جواب نباید آن‌قدر روشن باشد که جاسوس بفهمد، ولی باید آن‌قدر دقیق باشد که شهروندان به تو اعتماد کنند.',
    'جواب بی‌ربط یا «نمی‌دانم» مشکوک است.',
  ]),
  RuleSection('پایان بحث', [
    'با تمام شدن زمان یا زدن «پایان بحث و رأی‌گیری»، بحث تمام می‌شود.',
    'جاسوس می‌تواند هر لحظه با «جاسوس می‌خواهد حدس بزند» بحث را متوقف کند و کلمه را انتخاب کند. درست باشد برنده است، غلط باشد می‌بازد.',
  ]),
  RuleSection('رأی‌گیری', [
    'هر بازیکن مخفیانه به یک نفر رأی می‌دهد. به خودت نمی‌شود رأی داد.',
    'کسی که بیشترین رأی را بیاورد متهم است. اگر چند نفر رأی برابر داشته باشند، کسی متهم نمی‌شود.',
  ]),
  RuleSection('نتیجه', [
    'متهم جاسوس نباشد یا رأی‌ها مساوی شود: جاسوس‌ها برنده‌اند.',
    'متهم جاسوس باشد: او یک فرصت آخر دارد که کلمه را از بین گزینه‌ها انتخاب کند. درست بگوید جاسوس‌ها برنده‌اند، در غیر این صورت شهروندان.',
    'با چند جاسوس هم همین قانون است: فقط نفر متهم فرصت حدس دارد.',
  ]),
  RuleSection('امتیاز', [
    'برد شهروندان: ۱ امتیاز برای هر شهروند.',
    'برد جاسوس‌ها: ۲ امتیاز برای هر جاسوس.',
    'امتیازها بین دورها حفظ می‌شود و با «دور بعد» ادامه پیدا می‌کند.',
  ]),
  RuleSection('تعداد جاسوس', [
    'تا ۴ نفر: ۱ جاسوس. ۵ و ۶ نفر: حداکثر ۲. ۷ نفر به بالا: حداکثر ۳.',
  ]),
];

const pantoRules = <RuleSection>[
  RuleSection('هدف', [
    'هر تیم به نوبت یک کلمه را بدون حرف زدن نشان می‌دهد و هم‌تیمی‌ها حدس می‌زنند.',
    'بعد از آخرین نوبت، تیمی که بیشترین امتیاز را دارد برنده است.',
  ]),
  RuleSection('هر نوبت', [
    'یک نفر از تیم اجراکننده می‌شود و گوشی را فقط خودش می‌بیند.',
    'با زدن «شروع» کلمه و زمان نمایش داده می‌شود.',
    'اگر تیم درست حدس زد، «درست بود!» را بزن. اگر زمان تمام شد یا تیم نتوانست، «نتونست» را بزن.',
    'بعد از هر نوبت، کلمه و امتیاز برای همه نمایش داده می‌شود.',
  ]),
  RuleSection('ممنوعیت‌ها', [
    'حرف زدن و صدا درآوردن ممنوع است.',
    'اشاره به اشیاء اطراف و نوشتن روی هوا یا کف دست ممنوع است.',
    'لب‌خوانی ممنوع است.',
    'اگر قانونی شکسته شد، حریف می‌تواند نوبت را باطل کند و امتیازی ثبت نمی‌شود.',
  ]),
  RuleSection('حالت‌ها', [
    'کلاسیک: ۶۰ ثانیه. امتیاز = سختی × ۱۰ + ثانیهٔ باقی‌مانده.',
    'سرعتی: فقط ۱۵ ثانیه. درست حدس بزنند ۳۰ امتیاز، وگرنه صفر.',
    'جنگی: ۴۵ ثانیه. درست ۴۰+ امتیاز، شکست ۲۰− امتیاز.',
    'ماراتن: ۱۲۰ ثانیه. امتیاز = سختی × ۲۰ + ثانیهٔ باقی‌مانده.',
  ]),
  RuleSection('امتیازهای ویژه', [
    'سری برد: هر تیم که چند نوبت پشت‌سرهم درست حدس بزند، از نوبت دوم ۵ امتیاز پاداش می‌گیرد و هر نوبت ۵ امتیاز بیشتر (حداکثر ۲۰). شکست سری را از نو شروع می‌کند.',
    'عوض کردن کلمه: در حالت کلاسیک و ماراتن، هر نوبت یک بار می‌توانی کلمه را عوض کنی و ۵ امتیاز از دست بدهی.',
  ]),
  RuleSection('پایان', [
    'اگر امتیاز چند تیم برابر شد، همه برندهٔ مشترک‌اند.',
  ]),
];

// ============================================================
//  SPY GAME
// ============================================================
class SpyConfig {
  final List<String> names;
  final int spies, seconds;
  final List<String> categories;
  final bool spyKnowsCategory;
  const SpyConfig({
    required this.names,
    required this.spies,
    required this.seconds,
    required this.categories,
    required this.spyKnowsCategory,
  });
}

class SpySetupScreen extends StatefulWidget {
  const SpySetupScreen({super.key});
  @override
  State<SpySetupScreen> createState() => _SpySetupScreenState();
}

class _SpySetupScreenState extends State<SpySetupScreen> {
  static const _c = AppColors.spyRed;
  int _players = 5, _spies = 1, _time = 180;
  bool _spyHint = true, _namesOpen = false;
  final Set<String> _selected = {'مکان‌ها'};
  final List<TextEditingController> _ctrls =
      List.generate(12, (i) => TextEditingController(text: 'بازیکن ${i + 1}'));

  int get _maxSpies => min(3, max(1, (_players - 1) ~/ 2));

  String _name(int i) {
    final t = _ctrls[i].text.trim();
    return t.isEmpty ? 'بازیکن ${i + 1}' : t;
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _start() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حداقل یک دسته‌بندی انتخاب کن.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpyGameScreen(
          config: SpyConfig(
            names: List.generate(_players, _name),
            spies: _spies,
            seconds: _time,
            categories: _selected.toList(),
            spyKnowsCategory: _spyHint,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = _selected.length == spyData.length;
    return SetupScaffold(
      color: _c,
      title: 'تنظیم جاسوس',
      startLabel: 'شروع بازی',
      onStart: _start,
      children: [
        SetupHeader(
          icon: Icons.visibility_off_rounded,
          title: 'بازی جاسوس',
          subtitle: 'جاسوس را پیدا کن، قبل از اینکه کلمه را حدس بزند',
          color: _c,
          onRules: () => showRulesSheet(context, 'قوانین بازی جاسوس', spyRules),
        ),
        Row(
          children: [
            Expanded(
              child: CounterTile(
                icon: Icons.groups_rounded,
                label: 'بازیکنان',
                value: '$_players',
                color: _c,
                onInc: () => setState(() => _players = min(_players + 1, 12)),
                onDec: () => setState(() {
                  _players = max(_players - 1, 3);
                  _spies = min(_spies, _maxSpies);
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CounterTile(
                icon: Icons.person_search_rounded,
                label: 'جاسوس‌ها',
                value: '$_spies',
                color: _c,
                onInc: () => setState(() => _spies = min(_spies + 1, _maxSpies)),
                onDec: () => setState(() => _spies = max(_spies - 1, 1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CounterTile(
                  icon: Icons.timer_rounded,
                  label: 'زمان بحث',
                  value: '${_time ~/ 60}:${(_time % 60).toString().padLeft(2, '0')}',
                  color: _c,
                  onInc: () => setState(() => _time = min(_time + 30, 600)),
                  onDec: () => setState(() => _time = max(_time - 30, 60)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ToggleTile(
                  icon: Icons.lightbulb_rounded,
                  label: 'جاسوس دسته را ببیند',
                  value: _spyHint,
                  color: _c,
                  onChanged: (v) => setState(() => _spyHint = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SetupSection(
          icon: Icons.category_rounded,
          title: 'دسته‌بندی کلمه',
          color: _c,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                label: 'همه',
                selected: allSelected,
                color: AppColors.gold,
                onTap: () => setState(() {
                  if (allSelected) {
                    _selected.clear();
                  } else {
                    _selected.addAll(spyData.keys);
                  }
                }),
              ),
              for (final cat in spyData.keys)
                Pill(
                  label: cat,
                  selected: _selected.contains(cat),
                  color: _c,
                  onTap: () => setState(() => _selected.contains(cat) ? _selected.remove(cat) : _selected.add(cat)),
                ),
            ],
          ),
        ),
        SetupSection(
          icon: Icons.edit_note_rounded,
          title: 'نام بازیکن‌ها',
          color: _c,
          trailing: TextButton(
            onPressed: () => setState(() => _namesOpen = !_namesOpen),
            child: Text(_namesOpen ? 'بستن' : 'ویرایش', style: const TextStyle(color: _c)),
          ),
          child: _namesOpen
              ? Column(
                  children: [
                    for (int i = 0; i < _players; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(controller: _ctrls[i], decoration: fieldDeco('بازیکن ${i + 1}', _c)),
                      ),
                  ],
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < _players; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_name(i), style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

enum SpyPhase { reveal, discuss, vote, guess, result }

class SpyGameScreen extends StatefulWidget {
  final SpyConfig config;
  const SpyGameScreen({super.key, required this.config});
  @override
  State<SpyGameScreen> createState() => _SpyGameScreenState();
}

class _SpyGameScreenState extends State<SpyGameScreen> {
  final _rand = Random();
  late final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 3));

  SpyConfig get cfg => widget.config;
  int get n => cfg.names.length;

  late List<bool> _isSpy;
  late String _word, _category;
  late List<String> _options;
  late int _starter;
  late final List<int> _scores = List.filled(n, 0);
  int _round = 1;
  SpyPhase _phase = SpyPhase.reveal;

  int _current = 0;
  bool _peeking = false, _seen = false;

  Timer? _timer;
  int _left = 0;
  bool _paused = false;

  int _voter = 0;
  bool _handoff = true;
  int? _choice;
  late List<int> _votes;

  bool _earlyGuess = false, _citizensWin = false;
  String _reason = '';
  int? _accused;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _newRound() {
    _timer?.cancel();
    _category = cfg.categories[_rand.nextInt(cfg.categories.length)];
    final words = spyData[_category]!;
    _word = words[_rand.nextInt(words.length)];
    final others = words.where((w) => w != _word).toList()..shuffle(_rand);
    _options = [_word, ...others.take(7)]..shuffle(_rand);

    final idx = List.generate(n, (i) => i)..shuffle(_rand);
    _isSpy = List.filled(n, false);
    for (int i = 0; i < cfg.spies; i++) {
      _isSpy[idx[i]] = true;
    }
    _starter = _rand.nextInt(n);

    _phase = SpyPhase.reveal;
    _current = 0;
    _peeking = false;
    _seen = false;
    _paused = false;
    _voter = 0;
    _handoff = true;
    _choice = null;
    _votes = List.filled(n, -1);
    _earlyGuess = false;
    _accused = null;
    _reason = '';
  }

  void _nextReveal() {
    if (_current + 1 < n) {
      setState(() {
        _current++;
        _seen = false;
        _peeking = false;
      });
    } else {
      _startDiscuss();
    }
  }

  void _startDiscuss() {
    _left = cfg.seconds;
    _paused = false;
    setState(() => _phase = SpyPhase.discuss);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_paused) return;
      setState(() => _left--);
      if (_left <= 0) {
        t.cancel();
        AppSettings.alert();
        _toVote();
      } else if (_left <= 10) {
        AppSettings.vibrate();
      }
    });
  }

  void _toVote() {
    _timer?.cancel();
    setState(() {
      _phase = SpyPhase.vote;
      _voter = 0;
      _handoff = true;
      _choice = null;
      _votes = List.filled(n, -1);
    });
  }

  void _toEarlyGuess() {
    _timer?.cancel();
    setState(() {
      _earlyGuess = true;
      _phase = SpyPhase.guess;
    });
  }

  void _submitVote() {
    _votes[_voter] = _choice!;
    if (_voter + 1 < n) {
      setState(() {
        _voter++;
        _choice = null;
        _handoff = true;
      });
    } else {
      _tally();
    }
  }

  void _tally() {
    final counts = List.filled(n, 0);
    for (final v in _votes) {
      if (v >= 0) counts[v]++;
    }
    final top = counts.reduce(max);
    final leaders = [for (int i = 0; i < n; i++) if (counts[i] == top) i];

    if (leaders.length == 1 && _isSpy[leaders.first]) {
      setState(() {
        _accused = leaders.first;
        _earlyGuess = false;
        _phase = SpyPhase.guess;
      });
    } else {
      _accused = leaders.length == 1 ? leaders.first : null;
      _finish(
        citizensWin: false,
        reason: leaders.length == 1
            ? '${cfg.names[leaders.first]} بی‌گناه بود و جاسوس لو نرفت.'
            : 'رأی‌ها مساوی شد و کسی متهم نشد.',
      );
    }
  }

  void _pickGuess(String option) {
    final correct = option == _word;
    _finish(
      citizensWin: !correct,
      reason: correct
          ? (_earlyGuess ? 'جاسوس وسط بحث کلمه را درست حدس زد.' : 'جاسوس لو رفت ولی کلمه را درست حدس زد.')
          : (_earlyGuess ? 'جاسوس وسط بحث کلمه را اشتباه حدس زد.' : 'جاسوس لو رفت و کلمه را اشتباه حدس زد.'),
    );
  }

  void _finish({required bool citizensWin, required String reason}) {
    _timer?.cancel();
    for (int i = 0; i < n; i++) {
      if (citizensWin && !_isSpy[i]) _scores[i] += 1;
      if (!citizensWin && _isSpy[i]) _scores[i] += 2;
    }
    AppSettings.recordSpy(citizensWin);
    AppSettings.alert();
    setState(() {
      _citizensWin = citizensWin;
      _reason = reason;
      _phase = SpyPhase.result;
    });
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text('جاسوس · دور $_round'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_book_rounded),
              onPressed: () => showRulesSheet(context, 'قوانین بازی جاسوس', spyRules),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                if (await confirmExit(context) && mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: switch (_phase) {
            SpyPhase.reveal => _buildReveal(),
            SpyPhase.discuss => _buildDiscuss(),
            SpyPhase.vote => _buildVote(),
            SpyPhase.guess => _buildGuess(),
            SpyPhase.result => _buildResult(),
          },
        ),
      ),
    );
  }

  Widget _buildReveal() {
    final spy = _isSpy[_current];
    final last = _current + 1 == n;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('نوبت ${cfg.names[_current]}', style: GoogleFonts.vazirmatn(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('بازیکن ${_current + 1} از $n', style: const TextStyle(color: AppColors.textSub)),
          const Spacer(),
          Listener(
            onPointerDown: (_) => setState(() {
              _peeking = true;
              _seen = true;
            }),
            onPointerUp: (_) => setState(() => _peeking = false),
            onPointerCancel: (_) => setState(() => _peeking = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 250,
              height: 340,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _peeking && spy ? AppColors.spyRed.withOpacity(0.2) : AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _peeking && !spy ? AppColors.purple : AppColors.spyRed, width: 2),
              ),
              child: _peeking
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(spy ? '🕵️' : '👤', style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 14),
                        Text(
                          spy ? 'تو جاسوسی!' : _word,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (!spy || cfg.spyKnowsCategory)
                          Text('دسته: $_category', style: const TextStyle(color: AppColors.textSub, fontSize: 15)),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, size: 72, color: AppColors.spyRed),
                        SizedBox(height: 16),
                        Text('انگشتت را نگه دار\nتا نقشت را ببینی',
                            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSub, fontSize: 16)),
                      ],
                    ),
            ),
          ),
          const Spacer(),
          BigButton(
            label: last ? 'شروع بحث' : 'فهمیدم، نفر بعدی',
            icon: last ? Icons.forum_rounded : Icons.arrow_back_rounded,
            color: AppColors.spyRed,
            onPressed: (_seen && !_peeking) ? _nextReveal : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscuss() {
    final low = _left <= 15;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 210,
                height: 210,
                child: CircularProgressIndicator(
                  value: max(0, _left) / cfg.seconds,
                  strokeWidth: 12,
                  backgroundColor: AppColors.cardBg,
                  valueColor: AlwaysStoppedAnimation<Color>(low ? Colors.red : AppColors.spyRed),
                ),
              ),
              Text(
                '${_left ~/ 60}:${(_left % 60).toString().padLeft(2, '0')}',
                style: GoogleFonts.vazirmatn(fontSize: 54, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => setState(() => _paused = !_paused),
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: AppColors.gold),
            label: Text(_paused ? 'ادامه زمان' : 'مکث', style: const TextStyle(color: AppColors.gold)),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                const Text('شروع‌کننده', style: TextStyle(color: AppColors.textSub)),
                const SizedBox(height: 4),
                Text(cfg.names[_starter],
                    style: GoogleFonts.vazirmatn(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gold)),
                const SizedBox(height: 8),
                const Text('او از یک نفر دربارهٔ کلمه سؤال می‌پرسد، بعد جواب‌دهنده ادامه می‌دهد.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSub, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          BigButton(label: 'پایان بحث و رأی‌گیری', icon: Icons.how_to_vote, onPressed: _toVote),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _toEarlyGuess,
              icon: const Icon(Icons.psychology_alt, color: AppColors.spyRed),
              label: const Text('جاسوس می‌خواهد حدس بزند', style: TextStyle(color: AppColors.spyRed, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.spyRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVote() {
    if (_handoff) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.how_to_vote, size: 70, color: AppColors.gold),
            const SizedBox(height: 20),
            Text('رأی مخفی', style: GoogleFonts.vazirmatn(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('گوشی را به ${cfg.names[_voter]} بدهید',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: AppColors.textSub)),
            const SizedBox(height: 6),
            Text('${_voter + 1} از $n', style: const TextStyle(color: AppColors.textSub)),
            const SizedBox(height: 40),
            BigButton(
              label: 'من ${cfg.names[_voter]} هستم',
              icon: Icons.visibility,
              color: AppColors.gold,
              foreground: Colors.black,
              onPressed: () => setState(() => _handoff = false),
            ),
          ],
        ),
      );
    }
    final candidates = [for (int i = 0; i < n; i++) if (i != _voter) i];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('${cfg.names[_voter]}، به نظرت جاسوس کیست؟',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final i in candidates)
                Card(
                  color: _choice == i ? AppColors.spyRed.withOpacity(0.3) : AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: _choice == i ? AppColors.spyRed : Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.purple, child: Text('${i + 1}')),
                    title: Text(cfg.names[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: _choice == i ? const Icon(Icons.check_circle, color: AppColors.green, size: 28) : null,
                    onTap: () {
                      AppSettings.vibrate();
                      setState(() => _choice = i);
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: BigButton(
            label: 'ثبت رأی',
            color: AppColors.gold,
            foreground: Colors.black,
            onPressed: _choice == null ? null : _submitVote,
          ),
        ),
      ],
    );
  }

  Widget _buildGuess() {
    final title = _earlyGuess ? 'جاسوس می‌خواهد حدس بزند' : '${cfg.names[_accused!]} جاسوس بود!';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🕵️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.spyRed)),
          const SizedBox(height: 8),
          Text(
            _earlyGuess
                ? 'فقط جاسوس گوشی را بگیرد و کلمه را انتخاب کند. دسته: $_category'
                : 'فرصت آخر: کلمهٔ درست کدام است؟ فقط جاسوس گوشی را بگیرد. دسته: $_category',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSub, height: 1.7),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final o in _options)
                ActionChip(
                  label: Text(o, style: const TextStyle(fontSize: 17)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  backgroundColor: AppColors.cardBg,
                  onPressed: () => _pickGuess(o),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final color = _citizensWin ? AppColors.green : AppColors.spyRed;
    final order = List.generate(n, (i) => i)..sort((a, b) => _scores[b].compareTo(_scores[a]));
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(_citizensWin ? '✅' : '🕵️', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 10),
              Text(_citizensWin ? 'شهروندان برنده شدند!' : 'جاسوس‌ها برنده شدند!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text(_reason,
                  textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSub, height: 1.6)),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  children: [
                    const Text('کلمهٔ مخفی', style: TextStyle(color: AppColors.textSub)),
                    Text(_word,
                        style: GoogleFonts.vazirmatn(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gold)),
                    const SizedBox(height: 10),
                    Text(cfg.spies > 1 ? 'جاسوس‌ها' : 'جاسوس', style: const TextStyle(color: AppColors.textSub)),
                    for (int i = 0; i < n; i++)
                      if (_isSpy[i])
                        Text('🕵️ ${cfg.names[i]}',
                            style: const TextStyle(fontSize: 18, color: AppColors.spyRed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('جدول امتیاز'),
                    for (final i in order)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(cfg.names[i], style: const TextStyle(fontSize: 16))),
                            Text('${_scores[i]}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              BigButton(
                label: 'دور بعد',
                icon: Icons.replay,
                color: AppColors.spyRed,
                onPressed: () => setState(() {
                  _round++;
                  _newRound();
                }),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('پایان بازی', style: TextStyle(color: AppColors.textSub, fontSize: 16)),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [AppColors.gold, AppColors.purple, Colors.white],
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  PANTOMIME
// ============================================================
enum PantoMode { classic, speed, war, marathon }

extension PantoModeExt on PantoMode {
  String get title => switch (this) {
        PantoMode.classic => 'کلاسیک (نوبتی)',
        PantoMode.speed => 'سرعتی (چابک)',
        PantoMode.war => 'جنگی (ریسکی)',
        PantoMode.marathon => 'ماراتن (طولانی)',
      };

  String get desc => switch (this) {
        PantoMode.classic => 'زمان ۶۰ ثانیه. امتیاز = (سختی × ۱۰) + ثانیه باقی‌مانده.',
        PantoMode.speed => 'فقط ۱۵ ثانیه! اگر درست بگوید ۳۰ امتیاز، اگر ببازد صفر.',
        PantoMode.war => 'زمان ۴۵ ثانیه. درست: +۴۰ امتیاز. اشتباه: -۲۰ امتیاز (جنگی!)',
        PantoMode.marathon => 'زمان ۱۲۰ ثانیه. امتیاز = (سختی × ۲۰) + ثانیه باقی‌مانده.',
      };

  Color get color => switch (this) {
        PantoMode.classic => AppColors.pantoBlue,
        PantoMode.speed => AppColors.orange,
        PantoMode.war => AppColors.spyRed,
        PantoMode.marathon => AppColors.purple,
      };

  IconData get icon => switch (this) {
        PantoMode.classic => Icons.sports_esports,
        PantoMode.speed => Icons.flash_on,
        PantoMode.war => Icons.local_fire_department,
        PantoMode.marathon => Icons.hourglass_bottom,
      };

  int get seconds => switch (this) {
        PantoMode.classic => 60,
        PantoMode.speed => 15,
        PantoMode.war => 45,
        PantoMode.marathon => 120,
      };

  bool get canSwap => this == PantoMode.classic || this == PantoMode.marathon;

  int get failPenalty => this == PantoMode.war ? 20 : 0;

  int baseScore(int diff, int secondsLeft) => switch (this) {
        PantoMode.classic => diff * 10 + secondsLeft,
        PantoMode.speed => 30,
        PantoMode.war => 40,
        PantoMode.marathon => diff * 20 + secondsLeft,
      };
}

class PantoConfig {
  final PantoMode mode;
  final List<String> teams;
  final int turnsPerTeam;
  final List<PantoWord> pool;
  const PantoConfig({
    required this.mode,
    required this.teams,
    required this.turnsPerTeam,
    required this.pool,
  });
}

class PantoSetupScreen extends StatefulWidget {
  const PantoSetupScreen({super.key});
  @override
  State<PantoSetupScreen> createState() => _PantoSetupScreenState();
}

class _PantoSetupScreenState extends State<PantoSetupScreen> {
  PantoMode _mode = PantoMode.classic;
  int _teams = 2;
  int _turnsPerTeam = 3;
  int _diff = 0; // 0 ترکیبی
  final Set<String> _cats = {'عمومی', 'حیوانات'};
  final _defaults = ['تیم قرمز', 'تیم آبی', 'تیم زرد', 'تیم سبز', 'تیم بنفش', 'تیم نارنجی'];
  late final List<TextEditingController> _ctrls = _defaults.map((e) => TextEditingController(text: e)).toList();

  List<PantoWord> get _pool => [
        for (final c in _cats)
          for (final w in pantoData[c]!)
            if (_diff == 0 || w.diff == _diff) w,
      ];

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _start() {
    final pool = _pool;
    if (pool.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کلمهٔ کافی نیست. دسته‌های بیشتری انتخاب کن یا سختی را روی «ترکیبی» بگذار.')),
      );
      return;
    }
    final names = List.generate(_teams, (i) {
      final t = _ctrls[i].text.trim();
      return t.isEmpty ? _defaults[i] : t;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantoGameScreen(
          config: PantoConfig(mode: _mode, teams: names, turnsPerTeam: _turnsPerTeam, pool: pool),
        ),
      ),
    );
  }

  Widget _modeCard(PantoMode m) {
    final sel = _mode == m;
    return GestureDetector(
      onTap: () {
        AppSettings.vibrate();
        setState(() => _mode = m);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: sel
              ? LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [m.color, Color.lerp(m.color, AppColors.bg, 0.5)!],
                )
              : null,
          color: sel ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? m.color : Colors.white.withOpacity(0.1), width: sel ? 2 : 1),
          boxShadow: sel ? [BoxShadow(color: m.color.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))] : null,
        ),
        child: Row(
          children: [
            Icon(m.icon, size: 28, color: sel ? Colors.white : m.color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title.split(' ').first,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.white70)),
                  const SizedBox(height: 2),
                  Text('${m.seconds} ثانیه',
                      style: TextStyle(fontSize: 12, color: sel ? Colors.white70 : AppColors.textSub)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const diffLabels = ['ترکیبی', 'آسان', 'متوسط', 'سخت'];
    final c = _mode.color;
    final allCats = _cats.length == pantoData.length;
    return SetupScaffold(
      color: c,
      title: 'تنظیم پانتومیم',
      startLabel: 'شروع مسابقه',
      onStart: _start,
      children: [
        SetupHeader(
          icon: Icons.theater_comedy_rounded,
          title: 'بازی پانتومیم',
          subtitle: 'بدون حرف زدن نشان بده، تیمت حدس بزند',
          color: c,
          onRules: () => showRulesSheet(context, 'قوانین بازی پانتومیم', pantoRules),
        ),
        SetupSection(
          icon: Icons.bolt_rounded,
          title: 'حالت بازی',
          color: c,
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.9,
                padding: EdgeInsets.zero,
                children: [for (final m in PantoMode.values) _modeCard(m)],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(_mode),
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.withOpacity(0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: c),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_mode.desc, style: const TextStyle(fontSize: 13.5, height: 1.6))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: CounterTile(
                icon: Icons.groups_rounded,
                label: 'تیم‌ها / بازیکنان',
                value: '$_teams',
                color: c,
                onInc: () => setState(() => _teams = min(_teams + 1, 6)),
                onDec: () => setState(() => _teams = max(_teams - 1, 2)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CounterTile(
                icon: Icons.repeat_rounded,
                label: 'نوبت هر تیم',
                value: '$_turnsPerTeam',
                color: c,
                onInc: () => setState(() => _turnsPerTeam = min(_turnsPerTeam + 1, 10)),
                onDec: () => setState(() => _turnsPerTeam = max(_turnsPerTeam - 1, 1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SetupSection(
          icon: Icons.flag_rounded,
          title: 'نام تیم‌ها',
          color: c,
          child: Column(
            children: [
              for (int i = 0; i < _teams; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == _teams - 1 ? 0 : 10),
                  child: TextField(
                    controller: _ctrls[i],
                    decoration: fieldDeco('تیم ${i + 1}', AppColors.teams[i], icon: Icons.circle, iconColor: AppColors.teams[i]),
                  ),
                ),
            ],
          ),
        ),
        SetupSection(
          icon: Icons.local_fire_department_rounded,
          title: 'سختی کلمه‌ها',
          color: c,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < diffLabels.length; i++)
                Pill(label: diffLabels[i], selected: _diff == i, color: c, onTap: () => setState(() => _diff = i)),
            ],
          ),
        ),
        SetupSection(
          icon: Icons.category_rounded,
          title: 'دسته‌بندی کلمات',
          color: c,
          trailing: Text('${_pool.length} کلمه', style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                label: 'همه',
                selected: allCats,
                color: AppColors.gold,
                onTap: () => setState(() {
                  if (allCats) {
                    _cats.clear();
                  } else {
                    _cats.addAll(pantoData.keys);
                  }
                }),
              ),
              for (final cat in pantoData.keys)
                Pill(
                  label: cat,
                  selected: _cats.contains(cat),
                  color: c,
                  onTap: () => setState(() => _cats.contains(cat) ? _cats.remove(cat) : _cats.add(cat)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum PantoPhase { ready, playing, result, over }

class PantoGameScreen extends StatefulWidget {
  final PantoConfig config;
  const PantoGameScreen({super.key, required this.config});
  @override
  State<PantoGameScreen> createState() => _PantoGameScreenState();
}

class _PantoGameScreenState extends State<PantoGameScreen> with TickerProviderStateMixin {
  final _rand = Random();
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  late final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 2));

  PantoConfig get cfg => widget.config;
  PantoMode get mode => cfg.mode;
  int get teamCount => cfg.teams.length;
  int get totalTurns => teamCount * cfg.turnsPerTeam;
  int get team => _turn % teamCount;
  Color get teamColor => AppColors.teams[team];

  PantoPhase _phase = PantoPhase.ready;
  int _turn = 0;
  late final List<int> _scores = List.filled(teamCount, 0);
  late final List<int> _streaks = List.filled(teamCount, 0);

  late List<PantoWord> _deck = List.of(cfg.pool)..shuffle(_rand);
  int _deckIdx = 0;
  late PantoWord _word = _deck[_deckIdx++];

  Timer? _timer;
  int _left = 0;
  bool _paused = false;
  int _swapsLeft = 0;

  bool _lastOk = false;
  int _lastBase = 0, _lastBonus = 0, _lastPenalty = 0;
  PantoWord? _lastWord;

  @override
  void dispose() {
    _timer?.cancel();
    _shake.dispose();
    _pulse.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _nextWord() {
    if (_deckIdx >= _deck.length) {
      _deck = List.of(cfg.pool)..shuffle(_rand);
      _deckIdx = 0;
    }
    _word = _deck[_deckIdx++];
  }

  void _start() {
    AppSettings.vibrate();
    setState(() {
      _phase = PantoPhase.playing;
      _left = mode.seconds;
      _paused = false;
      _swapsLeft = mode.canSwap ? 1 : 0;
      _nextWord();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_paused) return;
      setState(() => _left--);
      if (_left <= 0) {
        _resolve(false);
      } else if (_left <= 5) {
        AppSettings.vibrate();
      }
    });
  }

  void _swap() {
    if (_paused || _swapsLeft <= 0) return;
    AppSettings.vibrate();
    setState(() {
      _swapsLeft--;
      _scores[team] -= 5;
      _nextWord();
    });
  }

  void _resolve(bool ok) {
    if (_phase != PantoPhase.playing) return;
    _timer?.cancel();
    _lastWord = _word;
    _lastOk = ok;
    _lastBase = 0;
    _lastBonus = 0;
    _lastPenalty = 0;
    if (ok) {
      _lastBase = mode.baseScore(_word.diff, max(0, _left));
      _streaks[team]++;
      _lastBonus = _streaks[team] >= 2 ? min(20, (_streaks[team] - 1) * 5) : 0;
      _scores[team] += _lastBase + _lastBonus;
      _confetti.play();
      AppSettings.alert();
    } else {
      _streaks[team] = 0;
      _lastPenalty = mode.failPenalty;
      _scores[team] -= _lastPenalty;
      _shake.forward(from: 0);
      AppSettings.alert();
    }
    setState(() => _phase = PantoPhase.result);
  }

  void _afterResult() {
    if (_turn + 1 >= totalTurns) {
      AppSettings.recordPanto();
      setState(() => _phase = PantoPhase.over);
      _confetti.play();
    } else {
      setState(() {
        _turn++;
        _phase = PantoPhase.ready;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(mode.title, style: TextStyle(color: mode.color, fontSize: 16, fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_book_rounded),
              onPressed: () => showRulesSheet(context, 'قوانین بازی پانتومیم', pantoRules),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                if (await confirmExit(context) && mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  final dx = sin(_shake.value * pi * 6) * 15 * (1 - _shake.value);
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: switch (_phase) {
                  PantoPhase.ready => _buildReady(),
                  PantoPhase.playing => _buildPlaying(),
                  PantoPhase.result => _buildResult(),
                  PantoPhase.over => _buildOver(),
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [AppColors.gold, AppColors.purple, AppColors.pantoBlue, Colors.white],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreboard({bool showActive = true}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < teamCount; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (showActive && i == team) ? AppColors.teams[i].withOpacity(0.2) : AppColors.cardBg,
              border: Border.all(color: (showActive && i == team) ? AppColors.teams[i] : Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(cfg.teams[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.teams[i])),
                Text('${_scores[i]}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                if (_streaks[i] >= 2)
                  Text('🔥 ${_streaks[i]}', style: const TextStyle(fontSize: 12, color: AppColors.gold)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReady() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('نوبت ${_turn + 1} از $totalTurns', style: const TextStyle(color: AppColors.textSub, fontSize: 16)),
          const SizedBox(height: 14),
          _scoreboard(),
          const SizedBox(height: 36),
          ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
            child: const Img('7.png', width: 100),
          ),
          const SizedBox(height: 16),
          Text(cfg.teams[team],
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(fontSize: 30, fontWeight: FontWeight.bold, color: teamColor)),
          const SizedBox(height: 10),
          const Text('یک نفر اجراکننده شود و گوشی را فقط خودش ببیند.\nبقیهٔ تیم رو به او بنشینند.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: AppColors.textSub, height: 1.7)),
          const SizedBox(height: 10),
          Text('${mode.seconds} ثانیه', style: const TextStyle(color: AppColors.gold, fontSize: 15)),
          const SizedBox(height: 34),
          BigButton(label: 'شروع', icon: Icons.play_arrow_rounded, color: mode.color, onPressed: _start),
        ],
      ),
    );
  }

  Widget _buildPlaying() {
    final low = _left <= 10;
    return Column(
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 10), child: _scoreboard()),
        const Divider(color: AppColors.cardBg),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: max(0, _left) / mode.seconds,
                          strokeWidth: 10,
                          backgroundColor: AppColors.cardBg,
                          valueColor: AlwaysStoppedAnimation<Color>(low ? Colors.red : mode.color),
                        ),
                      ),
                      Text('${max(0, _left)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (_paused) ...[
                    const Icon(Icons.pause_circle_filled, size: 70, color: AppColors.textSub),
                    const SizedBox(height: 10),
                    const Text('متوقف شد', style: TextStyle(fontSize: 22, color: AppColors.textSub)),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Icon(Icons.star, size: 30, color: i < _word.diff ? AppColors.gold : Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Text(
                        _word.word,
                        key: ValueKey('${_word.word}$_deckIdx'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.vazirmatn(fontSize: 50, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => _paused = !_paused),
                        icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: AppColors.gold),
                        label: Text(_paused ? 'ادامه' : 'مکث', style: const TextStyle(color: AppColors.gold)),
                      ),
                      if (mode.canSwap)
                        TextButton.icon(
                          onPressed: (_paused || _swapsLeft <= 0) ? null : _swap,
                          icon: const Icon(Icons.autorenew),
                          label: Text('عوض کردن کلمه (−۵) ($_swapsLeft)'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _paused ? null : () => _resolve(false),
                    child: Text('نتونست${mode.failPenalty > 0 ? ' (−${mode.failPenalty})' : ''}',
                        style: const TextStyle(fontSize: 17, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _paused ? null : () => _resolve(true),
                    child: const Text('درست بود!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final total = _lastOk ? _lastBase + _lastBonus : -_lastPenalty;
    final last = _turn + 1 >= totalTurns;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(_lastOk ? '✅' : '❌', style: const TextStyle(fontSize: 70)),
          const SizedBox(height: 8),
          Text(_lastOk ? 'درست حدس زدند!' : 'این نوبت نشد',
              style: GoogleFonts.vazirmatn(
                  fontSize: 26, fontWeight: FontWeight.bold, color: _lastOk ? AppColors.green : AppColors.spyRed)),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                const Text('کلمه', style: TextStyle(color: AppColors.textSub)),
                Text(_lastWord!.word,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vazirmatn(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.gold)),
                const SizedBox(height: 12),
                if (_lastOk) ...[
                  _line('امتیاز کلمه', '+$_lastBase'),
                  if (_lastBonus > 0) _line('پاداش سری 🔥${_streaks[team]}', '+$_lastBonus'),
                ] else if (_lastPenalty > 0)
                  _line('جریمه', '−$_lastPenalty')
                else
                  _line('امتیاز', '۰'),
                const Divider(color: AppColors.bg),
                _line('مجموع این نوبت', total > 0 ? '+$total' : '$total', bold: true),
              ],
            ),
          ),
          _scoreboard(showActive: false),
          const SizedBox(height: 24),
          BigButton(
            label: last ? 'نمایش نتیجهٔ نهایی' : 'نوبت بعدی',
            icon: last ? Icons.emoji_events : Icons.arrow_back_rounded,
            color: mode.color,
            onPressed: _afterResult,
          ),
        ],
      ),
    );
  }

  Widget _line(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(a, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
            Text(b,
                style: TextStyle(
                    fontSize: bold ? 20 : 16, fontWeight: FontWeight.bold, color: bold ? AppColors.gold : Colors.white)),
          ],
        ),
      );

  Widget _buildOver() {
    final top = _scores.reduce(max);
    final winners = [for (int i = 0; i < teamCount; i++) if (_scores[i] == top) i];
    final order = List.generate(teamCount, (i) => i)..sort((a, b) => _scores[b].compareTo(_scores[a]));
    final title = winners.length == 1
        ? '${cfg.teams[winners.first]} برنده شد!'
        : 'مساوی بین ${winners.map((i) => cfg.teams[i]).join(' و ')}';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 90)),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center, style: GoogleFonts.vazirmatn(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                for (int r = 0; r < order.length; r++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text('${r + 1}', style: const TextStyle(color: AppColors.textSub, fontSize: 18)),
                        ),
                        Expanded(
                          child: Text(cfg.teams[order[r]],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.teams[order[r]])),
                        ),
                        Text('${_scores[order[r]]}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          BigButton(label: 'بازی دوباره', icon: Icons.replay, color: mode.color, onPressed: () => Navigator.of(context).pop()),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('بازگشت به خانه', style: TextStyle(color: AppColors.textSub, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}