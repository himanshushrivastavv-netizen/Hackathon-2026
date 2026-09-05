import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A robust image widget that gracefully handles:
/// 1. Remote HTTP/HTTPS URLs (including Supabase Storage)
/// 2. Web blob URLs (`blob:http...`)
/// 3. Base64 Data URIs (`data:image/...;base64,...`) or raw base64
/// 4. Local file paths on mobile/desktop (e.g. `/data/user/0/...` or `C:\...`)
/// 5. Graceful commodity-based fallback icons & gradients
class ProduceImageView extends StatelessWidget {
  final String? imageUrl;
  final String commodity;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProduceImageView({
    super.key,
    required this.imageUrl,
    this.commodity = "Produce",
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final url = imageUrl?.trim() ?? '';

    if (url.isEmpty) {
      content = _buildPlaceholder();
    } else if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
      content = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingShimmer();
        },
      );
    } else if (url.startsWith('data:image') || _isBase64(url)) {
      try {
        final cleanBase64 = url.contains(',') ? url.split(',').last : url;
        final bytes = base64Decode(cleanBase64);
        content = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (_) {
        content = _buildPlaceholder();
      }
    } else if (!kIsWeb && _isLocalFilePath(url)) {
      try {
        final file = File(url);
        if (file.existsSync()) {
          content = Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        } else {
          content = _buildPlaceholder();
        }
      } catch (_) {
        content = _buildPlaceholder();
      }
    } else {
      content = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }

  bool _isBase64(String str) {
    if (str.length < 50) return false;
    return !str.contains(' ') && (str.length % 4 == 0 || str.contains(';base64,'));
  }

  bool _isLocalFilePath(String str) {
    return str.startsWith('/') ||
        str.startsWith('file://') ||
        (str.length > 2 && str[1] == ':'); // e.g. C:\
  }

  Widget _buildPlaceholder() {
    final emoji = getCommodityEmoji(commodity);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight,
            AppTheme.secondaryGreen.withValues(alpha: 0.15),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: (height != null && height! < 80) ? 28 : 42),
          ),
          if (height == null || height! >= 100) ...[
            const SizedBox(height: 4),
            Text(
              commodity,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.primaryLight,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
    );
  }

  static String getCommodityEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('cotton')) return '🌱';
    if (lower.contains('soybean') || lower.contains('soya')) return '🫘';
    if (lower.contains('pomegranate') || lower.contains('anar')) return '🍎';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('wheat') || lower.contains('gehu')) return '🌾';
    if (lower.contains('rice') || lower.contains('paddy')) return '🍚';
    if (lower.contains('mango')) return '🥭';
    if (lower.contains('chilli') || lower.contains('mirchi')) return '🌶️';
    if (lower.contains('garlic') || lower.contains('lahsun')) return '🧄';
    if (lower.contains('ginger') || lower.contains('adrak')) return '🫚';
    if (lower.contains('maize') || lower.contains('corn')) return '🌽';
    return '🌾';
  }
}
