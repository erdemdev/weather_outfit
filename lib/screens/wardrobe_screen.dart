import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/wardrobe_service.dart';
import '../l10n/app_localizations.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<WardrobeItem> _items = [];
  String _selectedCategory = 'all';

  final _categories = {
    'all': '📦',
    'üst': '👕',
    'alt': '👖',
    'dış giyim': '🧥',
    'ayakkabı': '👟',
    'aksesuar': '🧢',
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await WardrobeService.getItems();
    setState(() => _items = items);
  }

  List<WardrobeItem> get _filteredItems {
    if (_selectedCategory == 'all') return _items;
    return _items.where((i) => i.category == _selectedCategory).toList();
  }

  Map<String, int> get _categoryCounts {
    final map = <String, int>{};
    for (final item in _items) {
      map[item.category] = (map[item.category] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEN ? 'My Wardrobe' : 'Dolabım'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_items.length} ${isEN ? 'items' : 'parça'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F9FC),
        child: Column(
          children: [
            if (_items.isNotEmpty) _buildSummaryBar(isDark, isEN),
            _buildCategoryFilter(isDark),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧺', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),
                          Text(
                            isEN ? 'Wardrobe is empty' : 'Dolap boş',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isEN ? 'Add your clothes!' : 'Kıyafetlerini ekle!',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (ctx, i) => _buildItemTile(i, isDark),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(isDark),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSummaryBar(bool isDark, bool isEN) {
    final counts = _categoryCounts;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3345), const Color(0xFF253D50)]
              : [const Color(0xFF2C6E8A), const Color(0xFF3D8FAF)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: counts.entries.map((e) {
          return Column(
            children: [
              Text(_categories[e.key] ?? '📦', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text('${e.value}', style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _categories.entries.map((e) {
          final selected = _selectedCategory == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              label: Text('${e.value} ${e.key == 'all' ? (AppStrings.lang == 'en' ? 'All' : 'Tümü') : e.key}'),
              onSelected: (_) => setState(() => _selectedCategory = e.key),
              selectedColor: const Color(0xFF2C6E8A),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                fontSize: 13,
              ),
              backgroundColor: isDark ? const Color(0xFF1E3345) : Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemTile(int index, bool isDark) {
    final item = _filteredItems[index];
    final allIndex = _items.indexOf(item);

    return GestureDetector(
      onTap: () => _showEditDialog(allIndex, item, isDark),
      onLongPress: () => _confirmDelete(allIndex, isDark),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3345) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(item.colorValue).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.imagePath != null && File(item.imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item.imagePath!),
                  width: 56, height: 56,
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final wardrobeDir = Directory('${dir.path}/wardrobe_photos');
    if (!wardrobeDir.existsSync()) wardrobeDir.createSync(recursive: true);
    final fileName = 'wardrobe_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await File(picked.path).copy('${wardrobeDir.path}/$fileName');
    return savedFile.path;
  }

  Widget _buildPhotoPicker(String? currentPath, bool isDark, bool isEN, ValueChanged<String?> onChanged) {
    final hasPhoto = currentPath != null && File(currentPath).existsSync();
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            final path = await _pickImage(ImageSource.gallery);
            if (path != null) onChanged(path);
          },
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(File(currentPath), fit: BoxFit.cover, width: 72, height: 72),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_rounded, color: isDark ? Colors.white38 : Colors.grey, size: 28),
                      const SizedBox(height: 2),
                      Text(isEN ? 'Gallery' : 'Galeri', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey)),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            final path = await _pickImage(ImageSource.camera);
            if (path != null) onChanged(path);
          },
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_rounded, color: isDark ? Colors.white38 : Colors.grey, size: 28),
                const SizedBox(height: 2),
                Text(isEN ? 'Camera' : 'Kamera', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey)),
              ],
            ),
          ),
        ),
        if (hasPhoto) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onChanged(null),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmDelete(int index, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E3345) : Colors.white,
        title: Text(
          AppStrings.lang == 'en' ? 'Remove item?' : 'Kıyafeti sil?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.lang == 'en' ? 'Cancel' : 'İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await WardrobeService.removeItem(index);
              _loadItems();
            },
            child: Text(
              AppStrings.lang == 'en' ? 'Delete' : 'Sil',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index, WardrobeItem item, bool isDark) {
    final isEN = AppStrings.lang == 'en';
    final nameController = TextEditingController(text: item.name);
    String selectedEmoji = item.emoji;
    String selectedCategory = item.category;
    Color selectedColor = Color(item.colorValue);
    String? selectedImagePath = item.imagePath;
    String? nameError;

    final emojis = ['👕', '👚', '👔', '🧥', '👖', '🩳', '👗', '👟', '👢', '👞',
        '🧣', '🧤', '🧢', '👒', '🕶️', '🎒', '👜', '🧦', '🩴', '👠'];
    final colors = [
      const Color(0xFF2C6E8A), Colors.red, Colors.pink, Colors.purple,
      Colors.indigo, Colors.blue, Colors.teal, Colors.green,
      Colors.amber, Colors.orange, Colors.brown, Colors.grey,
      Colors.black, const Color(0xFFE8E8E8),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEN ? 'Edit Clothing' : 'Kıyafeti Düzenle',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onChanged: (_) {
                    if (nameError != null) setModalState(() => nameError = null);
                  },
                  decoration: InputDecoration(
                    hintText: isEN ? 'Name...' : 'İsim...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
                    errorText: nameError,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(isEN ? 'Photo' : 'Fotoğraf', style: TextStyle(
                  fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700],
                )),
                const SizedBox(height: 8),
                _buildPhotoPicker(selectedImagePath, isDark, isEN, (path) {
                  setModalState(() => selectedImagePath = path);
                }),
                const SizedBox(height: 16),
                Text(isEN ? 'Emoji' : 'Emoji', style: TextStyle(
                  fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700],
                )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setModalState(() => selectedEmoji = e),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: selectedEmoji == e ? const Color(0xFF2C6E8A).withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedEmoji == e ? Border.all(color: const Color(0xFF2C6E8A)) : null,
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text(isEN ? 'Category' : 'Kategori', style: TextStyle(
                  fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700],
                )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['üst', 'alt', 'dış giyim', 'ayakkabı', 'aksesuar'].map((c) {
                    final sel = selectedCategory == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: sel,
                      onSelected: (_) => setModalState(() => selectedCategory = c),
                      selectedColor: const Color(0xFF2C6E8A),
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(isEN ? 'Color' : 'Renk', style: TextStyle(
                  fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700],
                )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: colors.map((c) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = c),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: c, shape: BoxShape.circle,
                        border: selectedColor == c
                            ? Border.all(color: isDark ? Colors.white : Colors.black, width: 3)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDelete(index, isDark);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(isEN ? 'Delete' : 'Sil', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            setModalState(() {
                              nameError = isEN
                                  ? 'Please enter a name'
                                  : 'Lütfen isim girin';
                            });
                            return;
                          }
                          await WardrobeService.updateItem(index, WardrobeItem(
                            name: name,
                            emoji: selectedEmoji,
                            category: selectedCategory,
                            colorValue: selectedColor.value,
                            imagePath: selectedImagePath,
                          ));
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadItems();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C6E8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(isEN ? 'Save' : 'Kaydet', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog(bool isDark) {
    final nameController = TextEditingController();
    String selectedEmoji = '👕';
    String selectedCategory = 'üst';
    Color selectedColor = const Color(0xFF2C6E8A);
    String? selectedImagePath;
    String? nameError;

    final emojis = ['👕', '👚', '👔', '🧥', '👖', '🩳', '👗', '👟', '👢', '👞',
        '🧣', '🧤', '🧢', '👒', '🕶️', '🎒', '👜', '🧦', '🩴', '👠'];
    final colors = [
      const Color(0xFF2C6E8A), Colors.red, Colors.pink, Colors.purple,
      Colors.indigo, Colors.blue, Colors.teal, Colors.green,
      Colors.amber, Colors.orange, Colors.brown, Colors.grey,
      Colors.black, const Color(0xFFE8E8E8),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2B35) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.lang == 'en' ? 'Add Clothing' : 'Kıyafet Ekle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onChanged: (_) {
                    if (nameError != null) setModalState(() => nameError = null);
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.lang == 'en' ? 'Name...' : 'İsim...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
                    errorText: nameError,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.lang == 'en' ? 'Photo' : 'Fotoğraf',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildPhotoPicker(selectedImagePath, isDark, AppStrings.lang == 'en', (path) {
                  setModalState(() => selectedImagePath = path);
                }),
                const SizedBox(height: 16),
                Text(
                  AppStrings.lang == 'en' ? 'Emoji' : 'Emoji',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setModalState(() => selectedEmoji = e),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: selectedEmoji == e
                            ? const Color(0xFF2C6E8A).withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedEmoji == e
                            ? Border.all(color: const Color(0xFF2C6E8A))
                            : null,
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.lang == 'en' ? 'Category' : 'Kategori',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['üst', 'alt', 'dış giyim', 'ayakkabı', 'aksesuar'].map((c) {
                    final sel = selectedCategory == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: sel,
                      onSelected: (_) => setModalState(() => selectedCategory = c),
                      selectedColor: const Color(0xFF2C6E8A),
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.lang == 'en' ? 'Color' : 'Renk',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((c) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = c),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selectedColor == c
                            ? Border.all(color: isDark ? Colors.white : Colors.black, width: 3)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        setModalState(() {
                          nameError = AppStrings.lang == 'en'
                              ? 'Please enter a name'
                              : 'Lütfen isim girin';
                        });
                        return;
                      }
                      await WardrobeService.addItem(WardrobeItem(
                        name: name,
                        emoji: selectedEmoji,
                        category: selectedCategory,
                        colorValue: selectedColor.value,
                        imagePath: selectedImagePath,
                      ));
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadItems();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6E8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      AppStrings.lang == 'en' ? 'Add' : 'Ekle',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
