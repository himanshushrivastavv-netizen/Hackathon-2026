import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/ai_result.dart';

typedef AIQualityResult = AIResult;

class AIService {
  static const String _geminiEndpoint25 =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
  static const String _geminiEndpoint15 =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  /// Analyzes produce quality using Google Gemini Flash Vision AI.
  /// Accepts commodity name, photo URLs, and optional raw image bytes.
  /// Falls back to deterministic heuristic if network, quota, or API key fails.
  static Future<AIResult> analyzeProduceQuality({
    required String commodity,
    List<String> photoUrls = const [],
    List<Uint8List> imageBytesList = const [],
  }) async {
    final apiKey = ApiKeys.geminiApiKey.trim();

    // If no valid API key is present, use fallback
    if (apiKey.isEmpty || apiKey == "YOUR_GEMINI_API_KEY") {
      await Future.delayed(const Duration(milliseconds: 600));
      return AIResult.fallbackForCommodity(commodity);
    }

    // Collect image parts in Base64
    final List<Map<String, dynamic>> inlineDataParts = [];

    // 1. Add any raw byte images from camera / gallery
    for (final bytes in imageBytesList.take(3)) {
      if (bytes.isNotEmpty) {
        inlineDataParts.add({
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": base64Encode(bytes),
          }
        });
      }
    }

    // 2. If no raw bytes were provided but photo URLs exist, try fetching bytes for up to 2 images
    if (inlineDataParts.isEmpty && photoUrls.isNotEmpty) {
      for (final url in photoUrls.take(2)) {
        if (url.startsWith('http://') || url.startsWith('https://')) {
          try {
            final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
            if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
              inlineDataParts.add({
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Encode(resp.bodyBytes),
                }
              });
            }
          } catch (_) {
            // Ignore single photo download failures
          }
        }
      }
    }

    const promptText = """
You are an expert Indian agricultural produce quality inspector.
Analyze the provided produce images and return ONLY valid JSON.
Evaluate only visible quality.
Return this exact JSON format:
{
  "grade": "Grade A",
  "confidence": 92,
  "reason": "Bright uniform color, firm texture, minimal skin blemishes."
}
Grade options:
- "Grade A": Excellent visual quality, premium market price
- "Grade B": Good average visual quality, standard market price
- "Grade C": Fair quality / minor defects, discount market price
No markdown ticks. No other text. JSON only.
""";

    final List<Map<String, dynamic>> contentParts = [
      {"text": "Commodity: $commodity\n\n$promptText"}
    ];
    contentParts.addAll(inlineDataParts);

    final requestBody = {
      "contents": [
        {
          "parts": contentParts,
        }
      ],
      "generationConfig": {
        "temperature": 0.2,
        "responseMimeType": "application/json",
      }
    };

    // Try primary endpoint (gemini-2.5-flash) then fallback endpoint (gemini-1.5-flash)
    for (final endpoint in [_geminiEndpoint25, _geminiEndpoint15]) {
      try {
        final response = await http
            .post(
              Uri.parse("$endpoint?key=$apiKey"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 9));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              String rawText = parts[0]['text'] ?? '';
              rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
              final jsonMap = jsonDecode(rawText);
              debugPrint("[Gemini AI] Quality inspection succeeded: $rawText");
              return AIResult.fromJson(jsonMap);
            }
          }
        } else {
          debugPrint("[Gemini AI] Endpoint $endpoint returned ${response.statusCode}: ${response.body}");
        }
      } catch (e) {
        debugPrint("[Gemini AI] Exception on endpoint $endpoint: $e");
      }
    }

    // Return safe fallback on error so farmer is never blocked
    return AIResult.fallbackForCommodity(commodity);
  }
}
