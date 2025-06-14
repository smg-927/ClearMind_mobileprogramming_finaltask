import 'package:flutter/material.dart';
import '../quotes_provider.dart';
import '../services/sound_service.dart';
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool isOn = true;
  String quote = '';
  String author = '';
  int count = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    final q = await getRandomQuote();
    setState(() {
      quote = q['quote'] ?? '';
      author = q['author'] ?? '';
    });
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('switch_count', count);
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt('switch_count') ?? 0;
    });
  }

  @override
  void dispose() {
    _saveCount();
    super.dispose();
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
                        color: isOn ? Colors.black : Colors.white,
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
              width: 140,
              height: 200,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isOn = !isOn;
                    count++;
                  });
                  if (isOn) {
                    SoundService().playSwitchOnSound();
                  } else {
                    SoundService().playSwitchOffSound();
                  }
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
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: isOn ? Colors.black87 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '- $author',
                          style: TextStyle(
                            fontSize: 16,
                            color: isOn ? Colors.black54 : Colors.white,
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
