import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// 랜덤 명언과 작가를 반환합니다.
/// 반환값: { 'author': ..., 'quote': ... }
Future<Map<String, String>> getRandomQuote() async {
  // famous_quotes.json 파일을 assets에 등록해야 합니다.
  final String jsonString = await rootBundle.loadString(
    'assets/famous_quotes.json',
  );
  final List<dynamic> quotes = jsonDecode(jsonString);
  final random = Random();
  final idx = random.nextInt(quotes.length);
  final item = quotes[idx];
  return {
    'author': item['author'] ?? '',
    'quote': item['quote_en'] ?? '', // 한글로 원하면 'quote_ko'
  };
}
