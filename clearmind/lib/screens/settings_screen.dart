import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundOn = true;
  bool vibrationOn = true;

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFD6E7FF);
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
              mainAxisAlignment: MainAxisAlignment.start,
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
                const Expanded(
                  child: Center(
                    child: Text(
                      '설정',
                      style: TextStyle(
                        color: Color(0xFF7CA6F7),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 56), // 오른쪽 여백 맞추기
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  title: const Text(
                    '소리',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: soundOn,
                  onChanged: (val) {
                    setState(() {
                      soundOn = val;
                    });
                  },
                  secondary: const Icon(
                    Icons.volume_up,
                    color: Color(0xFF7CA6F7),
                    size: 36,
                  ),
                  activeColor: Color(0xFF7CA6F7),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  title: const Text(
                    '진동',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: vibrationOn,
                  onChanged: (val) {
                    setState(() {
                      vibrationOn = val;
                    });
                  },
                  secondary: const Icon(
                    Icons.vibration,
                    color: Color(0xFF7CA6F7),
                    size: 36,
                  ),
                  activeColor: Color(0xFF7CA6F7),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
