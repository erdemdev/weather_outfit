import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/photo_service.dart';
import '../services/outfit_scoring_service.dart';
import '../l10n/app_localizations.dart';

class ClothingPhotoScreen extends StatefulWidget {
  const ClothingPhotoScreen({super.key});

  @override
  State<ClothingPhotoScreen> createState() => _ClothingPhotoScreenState();
}

class _ClothingPhotoScreenState extends State<ClothingPhotoScreen> {
  List<ClothingPhoto> _photos = [];
  bool _loading = true;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await PhotoService.getPhotos();
    setState(() {
      _photos = photos;
      _loading = false;
    });
  }

  Future<void> _pickAndScoreOutfit({required ImageSource source}) async {
    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
    } catch (_) {
      return;
    }
    if (picked == null || !mounted) return;

    // Show category selection dialog (no heavy image decode)
    final result = await _showCategoryDialog(picked.path);
    if (result == null || !mounted) return;

    final categories = result['categories'] as List<String>;
    final itemName = result['name'] as String;

    // Show scoring animation
    bool overlayOpen = true;
    _showScoringOverlay();

    try {
      final score = await OutfitScoringService.scoreOutfit(
        photoPath: picked.path,
        categories: categories,
      );

      if (!mounted) return;
      if (overlayOpen) {
        Navigator.of(context).pop(); // close scoring overlay
        overlayOpen = false;
      }

      // Save photo with score
      await PhotoService.addPhoto(ClothingPhoto(
        itemName: itemName,
        category: categories.join(', '),
        photoPath: picked.path,
        addedDate: DateTime.now(),
        aiScore: score.totalScore,
        aiGrade: score.grade,
        aiTips: AppStrings.lang == 'en' ? score.tipsEN : score.tips,
      ));

      await _loadPhotos();

      if (mounted) {
        _showScoreResult(score, picked.path);
      }
    } catch (e) {
      if (mounted) {
        if (overlayOpen) {
          Navigator.of(context).pop(); // close scoring overlay
          overlayOpen = false;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.lang == 'en'
              ? 'Scoring failed. Photo saved without score.'
              : 'Puanlama başarısız. Fotoğraf puansız kaydedildi.'),
        ));
        await PhotoService.addPhoto(ClothingPhoto(
          itemName: itemName,
          category: categories.join(', '),
          photoPath: picked.path,
          addedDate: DateTime.now(),
        ));
        await _loadPhotos();
      }
    }
  }

  Future<Map<String, dynamic>?> _showCategoryDialog(String photoPath) async {
    final nameCtrl = TextEditingController();
    final isEN = AppStrings.lang == 'en';
    final allCategories = [
      'Üst Giyim',
      'Alt Giyim',
      'Dış Giyim',
      'Ayakkabı',
      'Aksesuar',
    ];
    final allCategoriesEN = [
      'Top',
      'Bottom',
      'Outerwear',
      'Shoes',
      'Accessory',
    ];
    final selected = <int>{};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A2B35) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEN ? 'Outfit Details' : 'Kombin Detayları',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lightweight photo indicator — no Image.file decode here
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C6E8A).withOpacity(0.15)
                        : const Color(0xFF2C6E8A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2C6E8A).withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 36, color: Color(0xFF2C6E8A)),
                        const SizedBox(height: 8),
                        Text(
                          isEN ? 'Photo captured!' : 'Fotoğraf çekildi!',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C6E8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: isEN ? 'Outfit Name' : 'Kombin Adı',
                    labelStyle: TextStyle(color: isDark ? Colors.white54 : null),
                    hintText: isEN ? 'e.g. Casual Friday' : 'ör. Günlük Kombin',
                    hintStyle: TextStyle(color: isDark ? Colors.white30 : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEN ? 'What\'s in this outfit?' : 'Bu kombinde neler var?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF2C6E8A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(allCategories.length, (i) {
                    final isSelected = selected.contains(i);
                    return FilterChip(
                      label: Text(isEN ? allCategoriesEN[i] : allCategories[i]),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2C6E8A).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF2C6E8A),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2C6E8A)
                            : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        setDialogState(() {
                          if (val) {
                            selected.add(i);
                          } else {
                            selected.remove(i);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isEN ? 'Cancel' : 'İptal',
                style: TextStyle(color: isDark ? Colors.white54 : null),
              ),
            ),
            FilledButton.icon(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      Navigator.pop(ctx, {
                        'name': nameCtrl.text.isEmpty
                            ? (isEN ? 'My Outfit' : 'Kombinim')
                            : nameCtrl.text,
                        'categories': selected.map((i) => allCategories[i]).toList(),
                      });
                    },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(isEN ? 'Score with AI' : 'AI ile Puanla'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C6E8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScoringOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A2B35)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    color: Color(0xFF2C6E8A),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.lang == 'en'
                      ? 'AI is analyzing your outfit...'
                      : 'AI kombini analiz ediyor...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.lang == 'en'
                      ? 'Checking colors, style & season match'
                      : 'Renkler, stil ve mevsim uyumu kontrol ediliyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScoreResult(OutfitScore score, String photoPath) {
    final isEN = AppStrings.lang == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Header
                  Text(
                    isEN ? 'AI Score Result' : 'AI Puanlama Sonucu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Photo + Score circle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(photoPath),
                          width: 120,
                          height: 160,
                          fit: BoxFit.cover,
                          cacheWidth: 240,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Score circle
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildScoreCircle(score, isDark),
                            const SizedBox(height: 12),
                            Text(
                              isEN ? score.verdictEN : score.verdict,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1A2B35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dominant colors
                  if (score.dominantColors.isNotEmpty) ...[
                    Text(
                      isEN ? 'Detected Colors' : 'Tespit Edilen Renkler',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF2C6E8A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: score.dominantColors.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Score breakdown
                  Text(
                    isEN ? 'Score Breakdown' : 'Puan Detayları',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF2C6E8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildScoreBar(
                    isEN ? 'Color Harmony' : 'Renk Uyumu',
                    score.colorHarmonyScore,
                    25,
                    Icons.palette_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildScoreBar(
                    isEN ? 'Season Match' : 'Mevsim Uyumu',
                    score.seasonMatchScore,
                    25,
                    Icons.wb_sunny_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildScoreBar(
                    isEN ? 'Completeness' : 'Bütünlük',
                    score.completenessScore,
                    25,
                    Icons.checkroom_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildScoreBar(
                    isEN ? 'Style' : 'Stil',
                    score.styleScore,
                    25,
                    Icons.auto_awesome_rounded,
                    isDark,
                  ),
                  const SizedBox(height: 24),

                  // Tips
                  if ((isEN ? score.tipsEN : score.tips).isNotEmpty) ...[
                    Text(
                      isEN ? 'AI Tips' : 'AI İpuçları',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF2C6E8A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...(isEN ? score.tipsEN : score.tips).map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xFFF4F8FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFF2C6E8A).withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF2A3F4A),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],

                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6E8A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(isEN ? 'Done' : 'Tamam'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(OutfitScore score, bool isDark) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: score.totalScore / 100,
              strokeWidth: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(score.gradeColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.grade,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: score.gradeColor,
                ),
              ),
              Text(
                '${score.totalScore}/100',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(
    String label,
    int value,
    int max,
    IconData icon,
    bool isDark,
  ) {
    final ratio = value / max;
    final color = ratio >= 0.8
        ? const Color(0xFF4CAF50)
        : ratio >= 0.6
            ? const Color(0xFFFFC107)
            : const Color(0xFFFF5722);

    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : const Color(0xFF2C6E8A)),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF2A3F4A),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '$value/$max',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoDetail(ClothingPhoto photo, int index) {
    final isEN = AppStrings.lang == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileExists = File(photo.photoPath).existsSync() &&
        !photo.photoPath.startsWith('placeholder');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (fileExists)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(photo.photoPath),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cacheWidth: 500,
                      ),
                    )
                  else
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.checkroom,
                        size: 56,
                        color: isDark ? Colors.white24 : Colors.grey[400],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    photo.itemName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  if (photo.aiScore != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2C6E8A).withOpacity(0.08),
                            const Color(0xFF3A8FA8).withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2C6E8A).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEN ? 'AI Score' : 'AI Puanı',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C6E8A),
                                  ),
                                ),
                                Text(
                                  '${photo.aiScore}/100 — ${photo.aiGrade ?? ""}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (photo.aiTips != null && photo.aiTips!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...photo.aiTips!.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : const Color(0xFF2A3F4A),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await PhotoService.removePhoto(index);
                      _loadPhotos();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text(isEN ? 'Delete' : 'Sil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
    final isEN = AppStrings.lang == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2B35) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEN ? 'Score Your Outfit' : 'Kombinini Puanla',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A2B35),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEN
                  ? 'Take a photo or pick from gallery'
                  : 'Fotoğraf çek veya galeriden seç',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(
                  Icons.camera_alt_rounded,
                  isEN ? 'Camera' : 'Kamera',
                  isDark,
                  () {
                    Navigator.pop(ctx);
                    _pickAndScoreOutfit(source: ImageSource.camera);
                  },
                ),
                _pickerOption(
                  Icons.photo_library_rounded,
                  isEN ? 'Gallery' : 'Galeri',
                  isDark,
                  () {
                    Navigator.pop(ctx);
                    _pickAndScoreOutfit(source: ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(
    IconData icon,
    String label,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF2C6E8A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF2C6E8A), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'AI Outfit Scorer' : 'AI Kombin Puanlayıcı'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPickerOptions,
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: Text(isEN ? 'Score Outfit' : 'Kombin Puanla'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? _buildEmptyState(isDark, isEN)
              : _buildPhotoGrid(isDark),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isEN) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF2C6E8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Color(0xFF2C6E8A),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEN ? 'AI Outfit Scorer' : 'AI Kombin Puanlayıcı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A2B35),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isEN
                  ? 'Take a photo of your outfit and let AI score it based on color harmony, season match, and style!'
                  : 'Kombininin fotoğrafını çek, AI renk uyumu, mevsim uyumu ve stil açısından puanlasın!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _showPickerOptions,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(isEN ? 'Take First Photo' : 'İlk Fotoğrafı Çek'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C6E8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        final fileExists = File(photo.photoPath).existsSync() &&
            !photo.photoPath.startsWith('placeholder');

        return GestureDetector(
          onTap: () => _showPhotoDetail(photo, index),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: fileExists
                        ? Image.file(
                            File(photo.photoPath),
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                          )
                        : Container(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                            child: Icon(
                              Icons.checkroom,
                              size: 40,
                              color: isDark ? Colors.white24 : Colors.grey[400],
                            ),
                          ),
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A2B35),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        photo.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.grey[500],
                        ),
                      ),
                      if (photo.aiScore != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _gradeColor(photo.aiScore!)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: _gradeColor(photo.aiScore!),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${photo.aiScore}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _gradeColor(photo.aiScore!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              photo.aiGrade ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _gradeColor(photo.aiScore!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _gradeColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFFC107);
    if (score >= 60) return const Color(0xFFFF9800);
    if (score >= 50) return const Color(0xFFFF5722);
    return const Color(0xFFF44336);
  }
}
