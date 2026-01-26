import 'package:flutter/material.dart';

/// A glass morphism badge that displays the post type (Event or Promotion)
/// with a nice contrasting color scheme:
/// - Events: Purple with lighter purple text
/// - Promotions: Orange with lighter orange text
class PostTypeBadge extends StatelessWidget {
  final String postType;
  final double? fontSize;
  final EdgeInsets? padding;

  const PostTypeBadge({
    super.key,
    required this.postType,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isPromotion = postType.toLowerCase() == 'promotion';

    // Define colors for events (purple) and promotions (orange)
    final Color backgroundColor =
        isPromotion
            ? const Color(0xFFFF6B35) // Vibrant orange for promotions
            : const Color(0xFF7C3AED); // Vibrant purple for events

    final Color textColor =
        isPromotion
            ? const Color(0xFFFFD4C4) // Light peachy orange (glass effect)
            : const Color(0xFFE0D4FF); // Light lavender purple (glass effect)

    final String displayText = isPromotion ? 'PROMO' : 'EVENT';
    final IconData icon =
        isPromotion ? Icons.local_offer_rounded : Icons.event_rounded;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withValues(alpha: 0.95),
            backgroundColor.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: (fontSize ?? 11) + 2, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact version of the badge for smaller spaces
class PostTypeBadgeCompact extends StatelessWidget {
  final String postType;

  const PostTypeBadgeCompact({super.key, required this.postType});

  @override
  Widget build(BuildContext context) {
    final isPromotion = postType.toLowerCase() == 'promotion';

    final Color backgroundColor =
        isPromotion ? const Color(0xFFFF6B35) : const Color(0xFF7C3AED);

    final Color textColor =
        isPromotion ? const Color(0xFFFFD4C4) : const Color(0xFFE0D4FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPromotion ? 'PROMO' : 'EVENT',
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
