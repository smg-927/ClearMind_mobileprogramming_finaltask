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

  // 슬라임 사운드 파일 목록
  final List<String> _slimeSounds = ['sounds/slime.mp3'];

  // 스피너 사운드 파일 목록
  final List<String> _spinnerSounds = ['sounds/Spinner_1.mp3'];

  // 스위치 사운드 파일 목록
  final List<String> _switchSounds = [
    'sounds/Switch_1.mp3',
    'sounds/Switch_2.mp3',
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

  // 슬라임 사운드 재생
  Future<void> playSlimeSound() async {
    if (_isMuted) return;
    try {
      // 랜덤하게 사운드 선택
      final soundFile = _slimeSounds[_random.nextInt(_slimeSounds.length)];
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      // 오류 무시
    }
  }

  // 스피너 사운드 재생
  Future<void> playSpinnerSound() async {
    if (_isMuted) return;
    try {
      // 랜덤하게 사운드 선택
      final soundFile = _spinnerSounds[_random.nextInt(_spinnerSounds.length)];
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      // 오류 무시
    }
  }

  // 스위치 켜기 사운드 재생
  Future<void> playSwitchOnSound() async {
    if (_isMuted) return;
    try {
      await _audioPlayer.play(AssetSource(_switchSounds[0]));
    } catch (e) {
      // 오류 무시
    }
  }

  // 스위치 끄기 사운드 재생
  Future<void> playSwitchOffSound() async {
    if (_isMuted) return;
    try {
      await _audioPlayer.play(AssetSource(_switchSounds[0]));
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
