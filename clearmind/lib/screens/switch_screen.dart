import 'package:flutter/material.dart';
import '../quotes_provider.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool isOn = true;
  String quote = '';
  String author = '';

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final bgColor = isOn ? const Color(0xFFD6E7FF) : const Color(0xFF222831);
    final switchColor =
        isOn ? const Color(0xFFFFF066) : const Color(0xFFB0B0B0);
    final handleColor = Colors.white;
    final shadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
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
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF7CA6F7),
                    size: 32,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      isOn ? '1' : '0',
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
                    color: Color(0xFF7CA6F7),
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
              width: 140,
              height: 200,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isOn = !isOn;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  width: 140,
                  height: 200,
                  decoration: BoxDecoration(
                    color: switchColor,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: shadow,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        top: isOn ? 28 : 110,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
