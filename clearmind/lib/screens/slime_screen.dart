import 'package:flutter/material.dart';
import 'dart:math';

class SlimeScreen extends StatefulWidget {
  const SlimeScreen({super.key});

  @override
  State<SlimeScreen> createState() => _SlimeScreenState();
}

class _SlimeScreenState extends State<SlimeScreen>
    with SingleTickerProviderStateMixin {
  int count = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  int? _activeVertex;
  Offset? _touchPos;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) async {
    setState(() {
      count++;
      _touchPos = details.localPosition;
    });
    await _controller.forward();
    await _controller.reverse();
    setState(() {
      _touchPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF3FFE3);
    final mainColor = const Color(0xFFA8D672);
    final iconBg = mainColor;
    return Scaffold(
      backgroundColor: bgColor,
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
                    backgroundColor: iconBg,
                    radius: 28 / 2,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: mainColor,
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
                    backgroundColor: iconBg,
                    radius: 28 / 2,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTapDown: _onTapDown,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(scale: _scaleAnim.value, child: child);
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.25),
                    blurRadius: 48,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _HexagonInteractivePainter(
                  mainColor,
                  _controller.value,
                  _touchPos,
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonInteractivePainter extends CustomPainter {
  final Color color;
  final double animValue;
  final Offset? touchPos;
  _HexagonInteractivePainter(this.color, this.animValue, this.touchPos);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final path = Path();
    final n = 6;
    final r = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    int? activeIdx;
    if (touchPos != null) {
      double minDist = double.infinity;
      for (int i = 0; i < n; i++) {
        final angle = (pi / 3) * i - pi / 2;
        final vx = center.dx + r * cos(angle) * 0.92;
        final vy = center.dy + r * sin(angle) * 0.92;
        final d = (touchPos! - Offset(vx, vy)).distance;
        if (d < minDist) {
          minDist = d;
          activeIdx = i;
        }
      }
    }
    for (int i = 0; i < n; i++) {
      final angle = (pi / 3) * i - pi / 2;
      double scale = 0.92;
      if (activeIdx != null && i == activeIdx) {
        scale += 0.13 * animValue;
      }
      final x = center.dx + r * cos(angle) * scale;
      final y = center.dy + r * sin(angle) * scale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexagonInteractivePainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.touchPos != touchPos;
  }
}
