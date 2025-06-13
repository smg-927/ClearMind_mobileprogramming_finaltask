import 'package:flutter/material.dart';
import 'dart:math';
import '../quotes_provider.dart';

class SpinnerScreen extends StatefulWidget {
  const SpinnerScreen({super.key});

  @override
  State<SpinnerScreen> createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0.0;
  double _lastRotation = 0.0;
  double _velocity = 0.0;
  double _totalSpin = 0.0; // 누적 회전량
  Offset? _lastTouchPos;
  double? _lastTouchAngle;
  double _lastDeltaAngle = 0.0;
  String quote = '';
  String author = '';

  @override
  void initState() {
    super.initState();
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
      });
    });
    _loadQuote();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _lastRotation = _rotation;
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
    // 마지막 드래그 각도 변화 방향(부호)로 관성 방향 결정
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
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.purpleAccent,
                    size: 32,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
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
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {},
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
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x335A7ACD), // 반투명 진한 파랑
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 스피너 팔 3개
                        for (int i = 0; i < 3; i++)
                          Transform.rotate(
                            angle: i * 2 * 3.1415926 / 3,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 24,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.32),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        // 중앙 원
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  child: Column(
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
        ],
      ),
    );
  }
}
