import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GeminiApiException implements Exception {
  final String message;
  const GeminiApiException(this.message);

  @override
  String toString() => message;
}

class GeminiService {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyStorageKey = 'pinka_gemini_api_key';
  static const _model = 'gemini-3.7-flash';

  static Uri get _endpoint => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
      );

  Future<String?> getApiKey() => _storage.read(key: _apiKeyStorageKey);

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.trim().isNotEmpty;
  }

  Future<void> saveApiKey(String value) async {
    final key = value.trim();
    if (key.isEmpty) {
      throw const GeminiApiException('API Key មិនអាចទទេបានទេ');
    }
    await _storage.write(key: _apiKeyStorageKey, value: key);
  }

  Future<void> deleteApiKey() => _storage.delete(key: _apiKeyStorageKey);

  Future<bool> testConnection() async {
    final response = await _generate(
      'Reply with exactly this text and nothing else: PINKA_OK',
    );
    return response.trim().contains('PINKA_OK');
  }

  Future<String> translateSubtitle({
    required String text,
    required String targetLanguage,
  }) async {
    final source = text.trim();
    if (source.isEmpty) {
      throw const GeminiApiException('មិនមាន Subtitle ឬ Script សម្រាប់បកប្រែទេ');
    }

    final prompt = '''
You are the translation engine inside PINKA Ai.
Translate the supplied subtitle/script into $targetLanguage.

Rules:
1. If the input is SRT or VTT, preserve cue numbers, timestamps, WEBVTT headers, blank-line structure, and ordering exactly.
2. Translate only the human-readable dialogue/caption text.
3. Do not add explanations, notes, Markdown fences, or commentary.
4. Keep names and technical terms natural for the target language.
5. Return only the translated subtitle/script.

INPUT START
$source
INPUT END
''';

    return _generate(prompt);
  }

  Future<String> _generate(String prompt) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const GeminiApiException(
        'សូមដាក់ Gemini API Key នៅ Settings ជាមុនសិន',
      );
    }

    final response = await http
        .post(
          _endpoint,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey.trim(),
          },
          body: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.1,
              'thinkingConfig': {'thinkingLevel': 'low'},
            },
          }),
        )
        .timeout(const Duration(seconds: 90));

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data?['error'];
      final message = error is Map<String, dynamic>
          ? error['message']?.toString()
          : null;
      throw GeminiApiException(
        message?.isNotEmpty == true
            ? message!
            : 'Gemini API error (${response.statusCode})',
      );
    }

    final candidates = data?['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const GeminiApiException('Gemini មិនបានផ្ញើចម្លើយត្រឡប់មកទេ');
    }

    final first = candidates.first;
    if (first is! Map<String, dynamic>) {
      throw const GeminiApiException('Gemini response មិនត្រឹមត្រូវ');
    }

    final content = first['content'];
    if (content is! Map<String, dynamic>) {
      throw const GeminiApiException('Gemini response គ្មាន content');
    }

    final parts = content['parts'];
    if (parts is! List) {
      throw const GeminiApiException('Gemini response គ្មាន text');
    }

    final output = parts
        .whereType<Map>()
        .map((part) => part['text']?.toString() ?? '')
        .where((part) => part.isNotEmpty)
        .join();

    if (output.trim().isEmpty) {
      throw const GeminiApiException('Gemini response ទទេ');
    }

    return output.trim();
  }
}
