import 'package:flutter/material.dart';
import 'dart:math';
import '../services/sound_service.dart';

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
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  void _toggleBubble(int row, int col) {
    setState(() {
      bubbles[row][col] = !bubbles[row][col];
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
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.purpleAccent,
                    size: 32,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
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
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF7ED957), // 연두색
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black, width: 5),
            ),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(rows, (row) {
                return SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(columns, (col) {
                      final isPopped = bubbles[row][col];
                      final color = rowColors[row];
                      // 진한 색상 계산 (isPopped일 때 더 진하게)
                      final poppedColor =
                          HSLColor.fromColor(color)
                              .withLightness(
                                (HSLColor.fromColor(color).lightness * 0.7)
                                    .clamp(0.0, 1.0),
                              )
                              .toColor();
                      return Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => _toggleBubble(row, col),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            width: isPopped ? 28 : 36,
                            height: isPopped ? 28 : 36,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPopped ? poppedColor : color,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child:
                                !isPopped
                                    ? Center(
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                    : null,
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
    );
  }
}
