import 'package:flutter/material.dart';
import 'dart:math';
import '../services/sound_service.dart';
import '../quotes_provider.dart';
import 'settings_screen.dart';

class PopItScreen extends StatefulWidget {
  const PopItScreen({super.key});

  @override
  State<PopItScreen> createState() => _PopItScreenState();
}

class _PopItScreenState extends State<PopItScreen> {
  static const int rows = 5;
  static const int columns = 5;
  late List<List<bool>> bubbles;
  final SoundService _soundService = SoundService();
  final List<Color> bubbleColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
  ];
  final Random _random = Random();
  late List<List<Color>> bubbleColorMap;
  int count = 0;
  String quote = '';
  String author = '';

  @override
  void initState() {
    super.initState();
    bubbles = List.generate(rows, (_) => List.generate(columns, (_) => false));
    // 각 버블마다 랜덤 색상 지정
    bubbleColorMap = List.generate(
      rows,
      (_) => List.generate(
        columns,
        (_) => bubbleColors[_random.nextInt(bubbleColors.length)],
      ),
    );
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    final q = await getRandomQuote();
    setState(() {
      quote = q['quote'] ?? '';
      author = q['author'] ?? '';
    });
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  void _toggleBubble(int row, int col) {
    setState(() {
      bubbles[row][col] = !bubbles[row][col];
      count++;
    });
    _soundService.playPopSound();
  }

  @override
  Widget build(BuildContext context) {
    // 각 행별 색상 지정 (빨강, 주황, 노랑, 초록, 보라)
    final List<Color> rowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.purple,
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF67A6F7), // 연한 파랑 배경
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 28,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.black,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 28,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 340,
              height: 340,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED957), // 연두색
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.black, width: 5),
                  ),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(rows, (row) {
                      return Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(columns, (col) {
                            final isPopped = bubbles[row][col];
                            final color = rowColors[row];
                            final poppedColor =
                                HSLColor.fromColor(color)
                                    .withLightness(
                                      (HSLColor.fromColor(color).lightness *
                                              0.7)
                                          .clamp(0.0, 1.0),
                                    )
                                    .toColor();
                            return Flexible(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () => _toggleBubble(row, col),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: isPopped ? 32 : 40,
                                      height: isPopped ? 32 : 40,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isPopped ? poppedColor : color,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 3,
                                        ),
                                        boxShadow:
                                            isPopped
                                                ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                                : [
                                                  BoxShadow(
                                                    color: color.withValues(
                                                      alpha: 0.2,
                                                    ),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                      ),
                                      child:
                                          !isPopped
                                              ? Center(
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 16,
                  left: 24,
                  right: 24,
                  top: 8,
                ),
                child: GestureDetector(
                  onHorizontalDragEnd: (_) => _loadQuote(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder:
                        (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                    child: Column(
                      key: ValueKey('$quote-$author'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '"$quote"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '- $author',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PopItBubble extends StatelessWidget {
  final bool popped;
  final Color color;
  final VoidCallback onTap;
  const PopItBubble({
    super.key,
    required this.popped,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 44,
        height: 44,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: PopItBubblePainter(color: color, popped: popped),
        ),
      ),
    );
  }
}

class PopItBubblePainter extends CustomPainter {
  final Color color;
  final bool popped;
  PopItBubblePainter({required this.color, required this.popped});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // 입체감 있는 버블 그라데이션
    final gradient = RadialGradient(
      center: popped ? const Alignment(0.2, 0.2) : const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors:
          popped
              ? [color.withOpacity(0.7), color.withOpacity(0.95)]
              : [Colors.white.withOpacity(0.85), color],
      stops: const [0.0, 1.0],
    );
    final paint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: r),
          )
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, paint);
    // 하이라이트(윤기) 효과
    if (!popped) {
      final highlightPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(-r * 0.25, -r * 0.25),
          width: r * 1.1,
          height: r * 0.45,
        ),
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PopItBubblePainter oldDelegate) {
    return color != oldDelegate.color || popped != oldDelegate.popped;
  }
}

class PopItBoard extends StatelessWidget {
  final List<List<bool>> state;
  final List<List<Color>> colors;
  final void Function(int, int) onBubbleTap;
  const PopItBoard({
    super.key,
    required this.state,
    required this.colors,
    required this.onBubbleTap,
  });

  static final List<BoxShadow> _boardShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xFFD6E7FF),
        boxShadow: _boardShadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < state.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int j = 0; j < state[i].length; j++)
                  PopItBubble(
                    popped: state[i][j],
                    color: colors[i][j],
                    onTap: () => onBubbleTap(i, j),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
