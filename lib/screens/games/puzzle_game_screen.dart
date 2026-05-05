import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../results_screen.dart';

/// Sliding puzzle game — 3×3 grid (8 tiles + blank).
class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen>
    with TickerProviderStateMixin {
  static const int _size = 3;
  static const int _total = _size * _size;

  late List<int> _tiles; // 0 = blank, 1-8 = tiles
  int _moves = 0;
  bool _won = false;
  late ConfettiController _confetti;
  late AnimationController _winnerAnimController;
  late AnimationController _tileAnimController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    
    // Winner animation controller
    _winnerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Tile animation controller
    _tileAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 0.15).animate(
      CurvedAnimation(parent: _tileAnimController, curve: Curves.easeInOut),
    );
    
    _newGame();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _winnerAnimController.dispose();
    _tileAnimController.dispose();
    super.dispose();
  }

  void _newGame() {
    _tiles = List.generate(_total, (i) => i);
    _shuffle();
    _moves = 0;
    _won = false;
  }

  /// Shuffle by making random valid moves (ensures solvability).
  void _shuffle() {
    final rng = Random();
    for (int k = 0; k < 200; k++) {
      final blank = _tiles.indexOf(0);
      final neighbors = _validNeighbors(blank);
      final target = neighbors[rng.nextInt(neighbors.length)];
      _tiles[blank] = _tiles[target];
      _tiles[target] = 0;
    }
  }

  List<int> _validNeighbors(int idx) {
    final row = idx ~/ _size, col = idx % _size;
    final result = <int>[];
    if (row > 0) result.add((row - 1) * _size + col);
    if (row < _size - 1) result.add((row + 1) * _size + col);
    if (col > 0) result.add(row * _size + (col - 1));
    if (col < _size - 1) result.add(row * _size + (col + 1));
    return result;
  }

  void _onTileTap(int idx) {
    if (_won) return;
    final blank = _tiles.indexOf(0);
    if (!_validNeighbors(blank).contains(idx)) return;

    HapticFeedback.selectionClick();
    setState(() {
      _tiles[blank] = _tiles[idx];
      _tiles[idx] = 0;
      _moves++;
      if (_checkWin()) {
        _won = true;
        HapticFeedback.heavyImpact();
        _confetti.play();
        
        // Trigger winner animations
        _winnerAnimController.forward();
        _tileAnimController.forward();
        
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          _showWinnerModal();
        });
      }
    });
  }

  void _showWinnerModal() {
    final score = max(10, 100 - _moves * 2);
    final accuracy = max(30, 100 - _moves);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.elasticOut,
          ),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: AppColors.primary.withOpacity(0.95),
          title: const Text(
            '🎉 Congratulations! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Points Earned',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem('Moves', '$_moves', AppColors.purple),
                  _StatItem('Accuracy', '$accuracy%', AppColors.starGold),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthProvider>().addScore(score);
                context.read<ProfileProvider>().addScoreToToday(score);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultsScreen(
                      score: score,
                      accuracy: accuracy.clamp(0, 100),
                      gameName: 'Sliding Puzzle',
                      won: true,
                      onRetry: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PuzzleGameScreen()));
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _checkWin() {
    for (int i = 0; i < _total; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      appBar: AppBar(
        title: const Text('Sliding Puzzle'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.purple),
            onPressed: () => setState(_newGame),
            tooltip: 'Shuffle',
          ),
        ],
      ),
      body: Stack(children: [
        Column(children: [
          // Moves counter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoTile('Moves', '$_moves', AppColors.purple),
                _InfoTile('Goal', 'In order\n1→8', AppColors.primary),
                _InfoTile('Status', _won ? '🎉 Solved!' : 'Playing...', AppColors.green),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Puzzle grid
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _size,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _total,
                      itemBuilder: (_, i) {
                        final val = _tiles[i];
                        return AnimatedBuilder(
                          animation: _won ? _tileAnimController : AlwaysStoppedAnimation(0.0),
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _won ? _rotateAnimation.value * sin(i.toDouble()) : 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                                child: GestureDetector(
                                  onTap: () => _onTileTap(i),
                                  child: val == 0
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F5F5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: _won
                                                  ? [AppColors.green, AppColors.primaryDark]
                                                  : [AppColors.purple, AppColors.primaryDark],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _won
                                                    ? AppColors.green.withOpacity(0.4)
                                                    : AppColors.purple.withOpacity(0.3),
                                                blurRadius: _won ? 12 : 6,
                                                offset: const Offset(0, 3),
                                              )
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$val',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: GestureDetector(
              onTap: () => setState(_newGame),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                ),
                child: const Text('New Puzzle',
                    style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ),
        ]),

        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [AppColors.purple, AppColors.primary, AppColors.starGold],
            numberOfParticles: 30,
          ),
        ),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
    ]);
  }
}
