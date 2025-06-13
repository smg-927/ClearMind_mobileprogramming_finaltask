import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  final Random _random = Random();

  // 팝잇 사운드 파일 목록
  final List<String> _popSounds = [
    'sounds/Popit_1.mp3',
    'sounds/Popit_2.mp3',
    'sounds/Popit_3.mp3',
  ];

  // 팝잇 사운드 재생
  Future<void> playPopSound() async {
    if (_isMuted) return;
    try {
      // 랜덤하게 사운드 선택
      final soundFile = _popSounds[_random.nextInt(_popSounds.length)];
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      // 오류 무시
    }
  }

  // 음소거 토글
  void toggleMute() {
    _isMuted = !_isMuted;
  }

  // 음소거 상태 확인
  bool get isMuted => _isMuted;

  // 리소스 해제
  void dispose() {
    _audioPlayer.dispose();
  }
}
