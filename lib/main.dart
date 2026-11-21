import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CityEmpireApp());
}

class CityEmpireApp extends StatelessWidget {
  const CityEmpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Empire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1B2A41),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 10;
  int money = 1000;
  int population = 0;
  List<List<String>> grid =
      List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
  String? selectedBuilding;
  bool loading = true;

  static const Map<String, Map<String, dynamic>> buildings = {
    'house': {'name': 'خانه', 'cost': 100, 'pop': 5, 'color': Color(0xFF8BC34A)},
    'shop': {'name': 'مغازه', 'cost': 250, 'pop': 0, 'color': Color(0xFFFF9800)},
    'park': {'name': 'پارک', 'cost': 50, 'pop': 0, 'color': Color(0xFF4CAF50)},
  };

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('city_grid');
    if (saved != null) {
      final data = jsonDecode(saved) as List;
      grid = List.generate(
          gridSize, (i) => List.generate(gridSize, (j) => data[i][j] as String));
    }
    money = prefs.getInt('money') ?? 1000;
    population = prefs.getInt('population') ?? 0;
    setState(() => loading = false);
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_grid', jsonEncode(grid));
    await prefs.setInt('money', money);
    await prefs.setInt('population', population);
  }

  void _onTileTap(int i, int j) {
    if (grid[i][j].isNotEmpty) {
      setState(() {
        final b = buildings[grid[i][j]]!;
        money += (b['cost'] as int) ~/ 2;
        population -= b['pop'] as int;
        grid[i][j] = '';
      });
      _saveGame();
      return;
    }
    if (selectedBuilding == null) return;
    final b = buildings[selectedBuilding]!;
    final cost = b['cost'] as int;
    if (money < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پول کافی نیست!')),
      );
      return;
    }
    setState(() {
      money -= cost;
      population += b['pop'] as int;
      grid[i][j] = selectedBuilding!;
    });
    _saveGame();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildGrid()),
            _buildBuildBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black.withOpacity(0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('💰', '$money'),
          _stat('🏠', '$population'),
        ],
      ),
    );
  }

  Widget _stat(String icon, String value) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 6),
      Text(value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildGrid() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              final i = index ~/ gridSize;
              final j = index % gridSize;
              final tile = grid[i][j];
              final color = tile.isEmpty
                  ? const Color(0xFF2E4A33)
                  : buildings[tile]!['color'] as Color;
              return GestureDetector(
                onTap: () => _onTileTap(i, j),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: tile.isEmpty
                      ? null
                      : Center(
                          child: Text(
                            tile == 'house'
                                ? '🏠'
                                : tile == 'shop'
                                    ? '🏪'
                                    : '🌳',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBuildBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buildings.entries.map((e) {
          final id = e.key;
          final b = e.value;
          final selected = selectedBuilding == id;
          return GestureDetector(
            onTap: () =>
                setState(() => selectedBuilding = selected ? null : id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Colors.green : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(b['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${b['cost']}💰',
                      style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
