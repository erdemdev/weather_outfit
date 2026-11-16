import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/outfit_model.dart';
import '../utils/contrast_utils.dart';

class OutfitCard extends StatelessWidget {
  final OutfitRecommendation outfit;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.onShare,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = ContrastUtils.accentText(outfit.primaryColor, isDark: isDark);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onShare,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: outfit.primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: outfit.primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(isDark, accent),
              _buildItemsGrid(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            outfit.primaryColor.withValues(alpha: isDark ? 0.32 : 0.16),
            isDark
                ? outfit.primaryColor.withValues(alpha: 0.14)
                : outfit.secondaryColor.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.checkroom_rounded, color: accent, size: 20),
          const SizedBox(width: 8),
          Text(
            AppStrings.get('todays_outfit'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const Spacer(),
          if (onShare != null)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onShare,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: outfit.primaryColor.withValues(alpha: isDark ? 0.28 : 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_rounded, size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.get('share_btn'),
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (onShare != null) const SizedBox(width: 8),
          if (onFavorite != null)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onFavorite,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: isFavorite ? Colors.redAccent : accent,
                  ),
                ),
              ),
            ),
          if (onFavorite != null) const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ContrastUtils.isLight(outfit.primaryColor)
                  ? (isDark
                      ? const Color(0xFF2C6E8A)
                      : const Color(0xFF1A2B35))
                  : outfit.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${outfit.items.length} ${AppStrings.get('pieces')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: outfit.items.length,
        itemBuilder: (ctx, i) =>
            _OutfitItemTile(item: outfit.items[i], isDark: isDark),
      ),
    );
  }
}

class _OutfitItemTile extends StatelessWidget {
  final OutfitItem item;
  final bool isDark;

  const _OutfitItemTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final nameColor = ContrastUtils.itemNameColor(item.color, isDark);
    final categoryColor = ContrastUtils.itemCategoryColor(item.color, isDark);

    return Container(
      decoration: BoxDecoration(
        color: ContrastUtils.itemTileFill(item.color, isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ContrastUtils.itemTileBorder(item.color, isDark),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: nameColor,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ContrastUtils.itemCategoryBackground(item.color, isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.category,
              style: TextStyle(
                fontSize: 9,
                color: categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
