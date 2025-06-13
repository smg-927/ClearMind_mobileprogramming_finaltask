import 'package:flutter/material.dart';
import 'screens/pop_it_screen.dart';
import 'screens/spinner_screen.dart';
import 'screens/switch_screen.dart';
import 'screens/slime_screen.dart';

class ClearMindApp extends StatelessWidget {
  const ClearMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearMind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                style: TextStyle(
                  color: Color(0xFF7CA6F7),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _mainButton(
                context,
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
              _mainButton(
                context,
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
              _mainButton(
                context,
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
              _mainButton(
                context,
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
              _mainButton(
                context,
                label: 'Reset',
                color: const Color(0xFFE57373),
                onTap: () {
                  // TODO: 카운트 리셋 기능 구현 필요
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('아직 구현되지 않았습니다.')),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: SizedBox(
        width: 340,
        height: 64,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(24),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
