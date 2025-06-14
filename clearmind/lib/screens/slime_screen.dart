import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'settings_screen.dart';
import '../quotes_provider.dart';
import '../services/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlimeScreen extends StatefulWidget {
  const SlimeScreen({super.key});

  @override
  State<SlimeScreen> createState() => _SlimeScreenState();
}

class _SlimeScreenState extends State<SlimeScreen>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  // 물방울 관련
  final List<SlimeDrop> _drops = [];
  Timer? _dropTimer;
  int count = 0;

  // 명언 관련
  String quote = '';
  String author = '';

  // 슬라임 색상 변화
  double _hue = 90.0; // 시작 색상 (연두)

  @override
  void initState() {
    super.initState();
    _loadCount();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _startDropLoop();
    _startColorLoop();
    _loadQuote();
  }

  void _startColorLoop() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _hue = (_hue + 0.5) % 360;
      });
    });
  }

  Future<void> _loadQuote() async {
    final q = await getRandomQuote();
    setState(() {
      quote = q['quote'] ?? '';
      author = q['author'] ?? '';
    });
  }

  void _startDropLoop() {
    _dropTimer?.cancel();
    _dropTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      bool changed = false;
      for (int i = _drops.length - 1; i >= 0; i--) {
        final drop = _drops[i];
        drop.position += drop.velocity;
        drop.velocity += const Offset(0, 0.3); // 중력
        drop.size *= 0.98;
        drop.opacity -= 0.018;
        if (drop.opacity <= 0 || drop.size < 2) {
          _drops.removeAt(i);
          changed = true;
        } else {
          changed = true;
        }
      }
      if (changed && mounted) setState(() {});
    });
  }

  void _createDrops(Offset center) {
    final random = Random();
    setState(() {
      count++;
    });
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi + random.nextDouble() * 0.5;
      final speed = 3.0 + random.nextDouble() * 2;
      _drops.add(
        SlimeDrop(
          position: center,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          size: 14.0 + random.nextDouble() * 6,
          opacity: 0.7 + random.nextDouble() * 0.3,
          color: HSLColor.fromAHSL(1.0, _hue, 0.7, 0.6).toColor(),
        ),
      );
    }
  }

  void _onPanStart(DragStartDetails details) {
    _controller.forward();
    // 슬라임 중앙 좌표 계산
    final RenderBox box = context.findRenderObject() as RenderBox;
    final slimeCenter = box.size.center(_position);
    _createDrops(slimeCenter);
    // 슬라임 사운드 재생
    SoundService().playSlimeSound();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.reverse();
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('slime_count', count);
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt('slime_count') ?? 0;
    });
  }

  @override
  void dispose() {
    _saveCount();
    _controller.dispose();
    _dropTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slimeColor = HSLColor.fromAHSL(1.0, _hue, 0.7, 0.6).toColor();
    final slimeColorDark = HSLColor.fromAHSL(1.0, _hue, 0.7, 0.45).toColor();
    return Scaffold(
      backgroundColor: const Color(0xFFF3FFE3),
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
                      style: TextStyle(
                        color: slimeColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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
          // 물방울 그리기
          ..._drops.map(
            (drop) => Positioned(
              left: drop.position.dx,
              top: drop.position.dy,
              child: Opacity(
                opacity: drop.opacity,
                child: Container(
                  width: drop.size,
                  height: drop.size,
                  decoration: BoxDecoration(
                    color: drop.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: _position,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnim.value,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: SimpleHexagonPainter(
                      color: slimeColor,
                      colorDark: slimeColorDark,
                    ),
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

class SlimeDrop {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;
  SlimeDrop({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

class SimpleHexagonPainter extends CustomPainter {
  final Color color;
  final Color colorDark;
  SimpleHexagonPainter({required this.color, required this.colorDark});
  @override
  void paint(Canvas canvas, Size size) {
    final n = 12;
    final r = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    for (int i = 0; i < n; i++) {
      final angle12 = (2 * pi / n) * i - pi / 2;
      final x = center.dx + r * cos(angle12) * 0.92;
      final y = center.dy + r * sin(angle12) * 0.92;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // 1. 슬라임 기본 색상 그라데이션
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: [color, colorDark],
      stops: const [0.5, 1.0],
    );
    final rect = Rect.fromCircle(center: center, radius: r * 0.92);
    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // 2. 하이라이트(윤기) 효과: 반투명 흰색 타원
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final highlightRect = Rect.fromCenter(
      center: center + Offset(-r * 0.28, -r * 0.28),
      width: r * 0.9,
      height: r * 0.38,
    );
    canvas.drawOval(highlightRect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
