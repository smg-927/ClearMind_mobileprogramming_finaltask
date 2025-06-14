import 'package:flutter/material.dart';
import 'dart:math';
import '../quotes_provider.dart';
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0.0;
  double _velocity = 0.0;
  double _totalSpin = 0.0; // 누적 회전량
  Offset? _lastTouchPos;
  double? _lastTouchAngle;
  double _lastDeltaAngle = 0.0;
  String quote = '';
  String author = '';
  double _hue = 200.0;

  @override
  void initState() {
    super.initState();
    _loadCount();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(() {
      setState(() {
        double prevRotation = _rotation;
        _rotation += _velocity;
        _totalSpin += (_rotation - prevRotation).abs();
        _velocity *= 0.995; // 더 천천히 감쇠
        if (_velocity.abs() < 0.001) {
          _velocity = 0.0;
          _controller.stop();
        }
        _hue = (_hue + 0.7) % 360;
      });
    });
    _loadQuote();
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('spinner_count', _totalSpin);
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSpin = prefs.getDouble('spinner_count') ?? 0.0;
    });
  }

  @override
  void dispose() {
    _saveCount();
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    RenderBox box = context.findRenderObject() as RenderBox;
    _lastTouchPos = box.globalToLocal(details.globalPosition);
    final center = box.size.center(Offset.zero);
    _lastTouchAngle = atan2(
      _lastTouchPos!.dy - center.dy,
      _lastTouchPos!.dx - center.dx,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(details.globalPosition);
    final center = box.size.center(Offset.zero);
    double angle = atan2(localPos.dy - center.dy, localPos.dx - center.dx);
    double deltaAngle = angle - (_lastTouchAngle ?? angle);
    // -pi ~ pi 범위로 정규화
    if (deltaAngle > pi) deltaAngle -= 2 * pi;
    if (deltaAngle < -pi) deltaAngle += 2 * pi;
    setState(() {
      _rotation += deltaAngle;
      _totalSpin += deltaAngle.abs();
      _lastTouchAngle = angle;
      _lastDeltaAngle = deltaAngle;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    double direction = _lastDeltaAngle.sign == 0 ? 1 : _lastDeltaAngle.sign;
    _velocity = direction * details.velocity.pixelsPerSecond.distance * 0.00004;
    _controller.repeat();
    _lastTouchPos = null;
    _lastTouchAngle = null;
    _lastDeltaAngle = 0.0;
  }

  Future<void> _loadQuote() async {
    final q = await getRandomQuote();
    setState(() {
      quote = q['quote'] ?? '';
      author = q['author'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final spinnerColor = HSLColor.fromAHSL(1.0, _hue, 0.7, 0.55).toColor();
    final spinnerColor2 =
        HSLColor.fromAHSL(1.0, (_hue + 60) % 360, 0.7, 0.65).toColor();
    final spinnerColor3 =
        HSLColor.fromAHSL(1.0, (_hue + 120) % 360, 0.7, 0.55).toColor();
    return Scaffold(
      backgroundColor: const Color(0xFF67A6F7),
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
                      _totalSpin.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
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
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 260,
              height: 260,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform.rotate(
                  angle: _rotation,
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: FancySpinnerPainter(
                      color1: spinnerColor,
                      color2: spinnerColor2,
                      color3: spinnerColor3,
                      rotation: _rotation,
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

class FancySpinnerPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final Color color3;
  final double rotation;
  FancySpinnerPainter({
    required this.color1,
    required this.color2,
    required this.color3,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final List<Color> armColors = [color1, color2, color3];
    final List<Color> armShadowColors = [
      color1.withOpacity(0.3),
      color2.withOpacity(0.3),
      color3.withOpacity(0.3),
    ];
    // 팔 3개
    for (int i = 0; i < 3; i++) {
      final angle = i * 2 * pi / 3;
      final armPaint =
          Paint()
            ..shader = LinearGradient(
              colors: [armColors[i], Colors.white.withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromLTWH(center.dx - 12, center.dy - radius, 24, radius),
            );
      final shadowPaint =
          Paint()
            ..color = armShadowColors[i]
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      // 그림자
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-12, -radius, 24, 110),
          const Radius.circular(12),
        ),
        shadowPaint,
      );
      // 팔
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-12, -radius, 24, 110),
          const Radius.circular(12),
        ),
        armPaint,
      );
      // 팔 끝에 작은 원
      final tipColor = Color.lerp(armColors[i], Colors.white, 0.5)!;
      canvas.drawCircle(
        Offset(0, -radius + 110),
        18,
        Paint()..color = tipColor.withOpacity(0.85),
      );
      canvas.restore();
    }
    // 중앙 원 (반짝임 효과)
    final centerGradient = RadialGradient(
      colors: [Colors.white, color1.withOpacity(0.7), color2.withOpacity(0.5)],
      stops: const [0.0, 0.7, 1.0],
    );
    canvas.drawCircle(
      center,
      44 / 2,
      Paint()
        ..shader = centerGradient.createShader(
          Rect.fromCircle(center: center, radius: 22),
        ),
    );
    // 중앙 반짝임 highlight
    canvas.drawCircle(
      center + Offset(-8, -8),
      8,
      Paint()..color = Colors.white.withOpacity(0.18),
    );
    // 외곽 원
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    // 전체 그림자
    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  @override
  bool shouldRepaint(covariant FancySpinnerPainter oldDelegate) {
    return color1 != oldDelegate.color1 ||
        color2 != oldDelegate.color2 ||
        color3 != oldDelegate.color3 ||
        rotation != oldDelegate.rotation;
  }
}
