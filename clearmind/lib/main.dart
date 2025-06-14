import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pop_it_screen.dart';
import 'screens/spinner_screen.dart';
import 'screens/switch_screen.dart';
import 'screens/slime_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const ClearMindApp());
}

class ClearMindApp extends StatelessWidget {
  const ClearMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'IM_Hyemin',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'IM_Hyemin',
      ),
      home: const MainHomePage(),
    );
  }
}

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  Future<void> _resetAllCounts(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('초기화 확인'),
            content: const Text('모든 카운트가 초기화됩니다.\n정말 초기화하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('확인'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('popit_count');
      await prefs.remove('spinner_count');
      await prefs.remove('switch_count');
      await prefs.remove('slime_count');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 카운트가 초기화되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E7FF),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Text(
                'ClearMind',
                style: const TextStyle(
                  color: Color(0xFF7CA6F7),
                  fontSize: 56,
                  fontFamily: 'IM_Hyemin',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 48),
              _AnimatedMainButton(
                label: 'Pop it',
                color: const Color(0xFF7CA6F7),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PopItScreen(),
                      ),
                    ),
              ),
              _AnimatedMainButton(
                label: 'Spinner',
                color: const Color(0xFFFFA726),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpinnerScreen(),
                      ),
                    ),
              ),
              _AnimatedMainButton(
                label: 'Switch',
                color: const Color(0xFF8BC34A),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SwitchScreen(),
                      ),
                    ),
              ),
              _AnimatedMainButton(
                label: 'Slime',
                color: const Color(0xFF9C27B0),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SlimeScreen(),
                      ),
                    ),
              ),
              _AnimatedMainButton(
                label: 'Reset',
                color: const Color(0xFFE57373),
                onTap: () => _resetAllCounts(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMainButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AnimatedMainButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedMainButton> createState() => _AnimatedMainButtonState();
}

class _AnimatedMainButtonState extends State<_AnimatedMainButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

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
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: SizedBox(
        width: 340,
        height: 64,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Material(
            color: widget.color,
            borderRadius: BorderRadius.circular(24),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _onTap,
              child: Center(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'IM_Hyemin',
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
