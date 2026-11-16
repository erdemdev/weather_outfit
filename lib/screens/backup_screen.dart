import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/backup_service.dart';
import '../l10n/app_localizations.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  Map<String, int> _stats = {};
  String? _lastBackup;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await BackupService.getDataStats();
    // Check if any backup file exists
    String? lastDate;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync().whereType<File>().where((f) => f.path.contains('hava_kombin_yedek_')).toList();
      if (files.isNotEmpty) {
        files.sort((a, b) => b.path.compareTo(a.path));
        final name = files.first.path.split('/').last.split('\\').last;
        lastDate = name.replaceAll('hava_kombin_yedek_', '').replaceAll('.json', '').replaceAll('T', ' ');
      }
    } catch (_) {}
    setState(() {
      _stats = stats;
      _lastBackup = lastDate;
    });
  }

  Future<void> _export() async {
    final isEN = AppStrings.lang == 'en';
    try {
      await BackupService.exportToFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEN ? 'Backup saved!' : 'Yedek kaydedildi!'),
          backgroundColor: Colors.green,
        ));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEN ? 'Backup failed' : 'Yedekleme başarısız'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _import() async {
    final isEN = AppStrings.lang == 'en';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEN ? 'Restore Backup' : 'Yedeği Geri Yükle'),
        content: Text(isEN
            ? 'This will overwrite your current data. Continue?'
            : 'Mevcut veriler üzerine yazılacak. Devam?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isEN ? 'Cancel' : 'İptal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isEN ? 'Restore' : 'Geri Yükle')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync().whereType<File>().where((f) => f.path.contains('hava_kombin_yedek_')).toList();
      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEN ? 'No backup found' : 'Yedek bulunamadı'),
            backgroundColor: Colors.orange,
          ));
        }
        return;
      }
      files.sort((a, b) => b.path.compareTo(a.path));
      final count = await BackupService.importFromFile(files.first.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(count > 0
              ? (isEN ? 'Restored $count items!' : '$count öğe geri yüklendi!')
              : (isEN ? 'No data to restore' : 'Geri yüklenecek veri yok')),
          backgroundColor: count > 0 ? Colors.green : Colors.orange,
        ));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEN ? 'Restore failed' : 'Geri yükleme başarısız'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Backup & Restore' : 'Yedekleme'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('💾', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isEN ? 'Data Overview' : 'Veri Durumu',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                if (_lastBackup != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${isEN ? 'Last backup:' : 'Son yedek:'} $_lastBackup',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data stats
          if (_stats.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3345) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEN ? '📊 Your Data' : '📊 Verilerin',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._stats.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(_statEmoji(e.key), style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          _statLabel(e.key, isEN),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        )),
                        Text('${e.value}', style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: Color(0xFF2C6E8A),
                        )),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Buttons
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _export,
              icon: const Icon(Icons.upload_rounded),
              label: Text(isEN ? 'Create Backup' : 'Yedek Oluştur'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C6E8A),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _import,
              icon: const Icon(Icons.download_rounded),
              label: Text(isEN ? 'Restore Backup' : 'Yedeği Geri Yükle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2C6E8A),
                side: const BorderSide(color: Color(0xFF2C6E8A)),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statEmoji(String key) => switch (key) {
    'wardrobe' => '👕',
    'history' => '📋',
    'favorites' => '❤️',
    'achievements' => '🏆',
    'gallery' => '🖼️',
    'profiles' => '👤',
    _ => '📦',
  };

  String _statLabel(String key, bool isEN) => switch (key) {
    'wardrobe' => isEN ? 'Wardrobe Items' : 'Dolap Parçaları',
    'history' => isEN ? 'History Records' : 'Geçmiş Kayıtları',
    'favorites' => isEN ? 'Favorites' : 'Favoriler',
    'achievements' => isEN ? 'Achievements' : 'Başarılar',
    'gallery' => isEN ? 'Gallery Items' : 'Galeri Öğeleri',
    'profiles' => isEN ? 'Profiles' : 'Profiller',
    _ => key,
  };
}
