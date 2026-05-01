import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../results_screen.dart';

/// All emoji pairs used for the memory match cards.
const _kEmojis = ['🦁', '🐯', '🦊', '🐻', '🐼', '🐨', '🦄', '🐙'];

class _CardData {
  final int id;
  final String emoji;
  bool isFaceUp;
  bool isMatched;

  _CardData({
    required this.id,
    required this.emoji,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

/// Fully playable memory card match game.
class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  List<_CardData> _cards = [];
  List<int> _flipped = []; // indices of currently face-up unmatched cards
  bool _processing = false;
  int _matchCount = 0;
  int _score = 0;
  int _moves = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _gameStarted = false;
  bool _gameOver = false;

  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _initCards();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _initCards() {
    final emojis = [..._kEmojis, ..._kEmojis];
    emojis.shuffle();
    _cards =
        List.generate(emojis.length, (i) => _CardData(id: i, emoji: emojis[i]));
    _flipped = [];
    _matchCount = 0;
    _score = 0;
    _moves = 0;
    _timeLeft = 60;
    _gameStarted = false;
    _gameOver = false;
    _timer?.cancel();
  }

  void _startTimer() {
    _gameStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame(won: false);
        }
      });
    });
  }

  void _onCardTap(int index) {
    if (!_gameStarted) _startTimer();
    final card = _cards[index];
    if (_processing || card.isFaceUp || card.isMatched || _gameOver) return;
    HapticFeedback.lightImpact();

    if (!_gameStarted) setState(() => _gameStarted = true);

    setState(() {
      card.isFaceUp = true;
      _flipped.add(index);
      if (_flipped.length == 2) _checkMatch();
    });
  }

  void _checkMatch() {
    _processing = true;
    _moves++;
    final a = _cards[_flipped[0]];
    final b = _cards[_flipped[1]];

    if (a.emoji == b.emoji) {
      // Match!
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          a.isMatched = true;
          b.isMatched = true;
          _flipped.clear();
          _score += 10;
          _matchCount++;
          _processing = false;
          if (_matchCount == _kEmojis.length) _endGame(won: true);
        });
      });
    } else {
      // No match — flip back after delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          a.isFaceUp = false;
          b.isFaceUp = false;
          _flipped.clear();
          _processing = false;
        });
      });
    }
  }

  void _endGame({required bool won}) {
    _timer?.cancel();
    _gameOver = true;
    if (won) {
      HapticFeedback.heavyImpact();
      _confetti.play();
    }
    // Navigate to results after brief delay
    Future.delayed(Duration(milliseconds: won ? 1200 : 400), () {
      if (!mounted) return;
      final accuracy = _cards.isNotEmpty
          ? ((_matchCount * 2) / _cards.length * 100).round()
          : 0;
      context.read<AuthProvider>().addScore(_score);
      context.read<ProfileProvider>().addScoreToToday(_score);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            score: _score,
            accuracy: accuracy,
            gameName: 'Memory Match',
            won: won,
            onRetry: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MemoryGameScreen()));
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _timeLeft <= 10 ? Colors.red : AppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      appBar: AppBar(
        title: const Text('Memory Match'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Timer display
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Icon(Icons.timer_outlined, color: timerColor, size: 16),
                  const SizedBox(width: 4),
                  Text('${_timeLeft}s',
                      style: TextStyle(
                          color: timerColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ]),
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        Column(children: [
          // Score bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                    label: 'Score', value: '$_score', color: AppColors.primary),
                _InfoChip(
                    label: 'Matches',
                    value: '$_matchCount / ${_kEmojis.length}',
                    color: AppColors.green),
                _InfoChip(
                    label: 'Moves', value: '$_moves', color: AppColors.purple),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Cards grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _cards.length,
                itemBuilder: (_, i) {
                  final card = _cards[i];
                  return _MemoryCard(
                    key: ValueKey(card.id),
                    emoji: card.emoji,
                    isFaceUp: card.isFaceUp,
                    isMatched: card.isMatched,
                    onTap: () => _onCardTap(i),
                  );
                },
              ),
            ),
          ),

          if (!_gameStarted)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('Tap any card to start!',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ),
        ]),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              AppColors.primary,
              AppColors.orange,
              AppColors.purple,
              AppColors.starGold,
            ],
            numberOfParticles: 30,
          ),
        ),
      ]),
    );
  }
}

/// Single flip card widget with 3D rotation animation.
class _MemoryCard extends StatefulWidget {
  final String emoji;
  final bool isFaceUp;
  final bool isMatched;
  final VoidCallback onTap;

  const _MemoryCard({
    super.key,
    required this.emoji,
    required this.isFaceUp,
    required this.isMatched,
    required this.onTap,
  });

  @override
  State<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<_MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rot;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rot = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isFaceUp) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_MemoryCard old) {
    super.didUpdateWidget(old);
    if (widget.isFaceUp != old.isFaceUp) {
      if (widget.isFaceUp) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _rot,
        builder: (_, __) {
          final angle = _rot.value * pi;
          final isShowingFront = _rot.value >= 0.5;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isShowingFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _FrontFace(
                        emoji: widget.emoji, isMatched: widget.isMatched),
                  )
                : _BackFace(),
          );
        },
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  final String emoji;
  final bool isMatched;
  const _FrontFace({required this.emoji, required this.isMatched});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMatched ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMatched ? AppColors.primary : AppColors.divider,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? AppColors.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: const Center(
        child: Icon(Icons.psychology_rounded, color: Colors.white70, size: 28),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
    ]);
  }
}
