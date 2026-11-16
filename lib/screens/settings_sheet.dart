import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../l10n/app_localizations.dart';
import 'wardrobe_screen.dart';
import 'history_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  List<ProfileData> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await ProfileService.getProfiles();
    setState(() => _profiles = profiles);
  }

  void _showAddProfile() {
    final controller = TextEditingController();
    final isEN = AppStrings.lang == 'en';
    String style = 'unisex';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEN ? 'Add Profile' : 'Profil Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: isEN ? 'Name' : 'İsim',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ToggleButtons(
                isSelected: [style == 'female', style == 'unisex', style == 'male'],
                onPressed: (i) {
                  setDialogState(() => style = ['female', 'unisex', 'male'][i]);
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF2C6E8A),
                constraints: const BoxConstraints(minWidth: 60, minHeight: 36),
                children: const [Text('👩'), Text('🧑'), Text('👨')],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEN ? 'Cancel' : 'İptal')),
            FilledButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await ProfileService.addProfile(ProfileData(name: controller.text, style: style));
                  await _loadProfiles();
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: Text(isEN ? 'Add' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2B35) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
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
            AppStrings.get('settings'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
          // Theme toggle
          _buildTile(
            icon: isDark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: AppStrings.get('theme'),
            subtitle: isDark
                ? AppStrings.get('dark_mode')
                : AppStrings.get('light_mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => provider.toggleTheme(),
              activeThumbColor: const Color(0xFF2C6E8A),
            ),
            isDark: isDark,
          ),
          // Language toggle
          _buildTile(
            icon: Icons.language_rounded,
            title: AppStrings.get('language'),
            subtitle: provider.language == 'tr' ? 'Türkçe' : 'English',
            trailing: ToggleButtons(
              isSelected: [
                provider.language == 'tr',
                provider.language == 'en',
              ],
              onPressed: (i) => provider.setLanguage(i == 0 ? 'tr' : 'en'),
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: const Color(0xFF2C6E8A),
              color: isDark ? Colors.white54 : Colors.grey,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 32),
              children: const [Text('TR'), Text('EN')],
            ),
            isDark: isDark,
          ),
          // Style preference
          _buildTile(
            icon: Icons.person_rounded,
            title: AppStrings.get('style_pref'),
            subtitle: _styleLabel(provider.stylePreference),
            trailing: ToggleButtons(
              isSelected: [
                provider.stylePreference == 'female',
                provider.stylePreference == 'unisex',
                provider.stylePreference == 'male',
              ],
              onPressed: (i) {
                final styles = ['female', 'unisex', 'male'];
                provider.setStylePreference(styles[i]);
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: const Color(0xFF2C6E8A),
              color: isDark ? Colors.white54 : Colors.grey,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
              children: const [Text('👩'), Text('🧑'), Text('👨')],
            ),
            isDark: isDark,
          ),
          // Theme color
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF5F9FC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_rounded,
                          color: Color(0xFF2C6E8A), size: 24),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.lang == 'en'
                                ? 'Theme Color'
                                : 'Tema Rengi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A2B35),
                            ),
                          ),
                          Text(
                            AppStrings.lang == 'en'
                                ? 'Customize accent color'
                                : 'Vurgu rengini özelleştir',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _colorDot(0xFF2C6E8A, provider, isDark), // Mavi
                      _colorDot(0xFF6B4FCF, provider, isDark), // Mor
                      _colorDot(0xFFE8783A, provider, isDark), // Turuncu
                      _colorDot(0xFF2E7D32, provider, isDark), // Yeşil
                      _colorDot(0xFFC62828, provider, isDark), // Kırmızı
                      _colorDot(0xFF00838F, provider, isDark), // Teal
                      _colorDot(0xFFE91E63, provider, isDark), // Pembe
                      _colorDot(0xFF5C6BC0, provider, isDark), // İndigo
                      _colorDot(0xFF00897B, provider, isDark), // Koyu Teal
                      _colorDot(0xFFFF8F00, provider, isDark), // Amber
                      _colorDot(0xFF6D4C41, provider, isDark), // Kahverengi
                      _colorDot(0xFF546E7A, provider, isDark), // Gri-Mavi
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Notifications toggle
          _buildTile(
            icon: Icons.notifications_rounded,
            title: AppStrings.get('notifications'),
            subtitle: provider.notificationsEnabled
                ? AppStrings.get('notif_on')
                : AppStrings.get('notif_off'),
            trailing: Switch(
              value: provider.notificationsEnabled,
              onChanged: (_) async {
                await provider.toggleNotifications();
                if (provider.notificationsEnabled) {
                  await NotificationService.scheduleDailyNotification();
                } else {
                  await NotificationService.cancelAll();
                }
              },
              activeThumbColor: const Color(0xFF2C6E8A),
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Wardrobe button
          _buildNavTile(
            icon: Icons.checkroom_rounded,
            title: AppStrings.get('wardrobe'),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WardrobeScreen()));
            },
          ),
          // History button
          _buildNavTile(
            icon: Icons.history_rounded,
            title: AppStrings.get('history'),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          // Privacy policy
          _buildNavTile(
            icon: Icons.privacy_tip_rounded,
            title: AppStrings.lang == 'en' ? 'Privacy Policy' : 'Gizlilik Politikası',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          const SizedBox(height: 8),
          // Profile switcher
          _buildProfileSection(provider, isDark),
          const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildProfileSection(AppProvider provider, bool isDark) {
    final isEN = AppStrings.lang == 'en';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F9FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_rounded, color: Color(0xFF2C6E8A), size: 22),
                const SizedBox(width: 10),
                Text(
                  isEN ? 'Profiles' : 'Profiller',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showAddProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C6E8A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+ ${isEN ? 'Add' : 'Ekle'}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF2C6E8A), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(_profiles.length, (i) {
                final p = _profiles[i];
                final isActive = i == provider.activeProfileIndex;
                return GestureDetector(
                  onTap: () => provider.setActiveProfile(i),
                  onLongPress: _profiles.length > 1
                      ? () async {
                          await ProfileService.removeProfile(i);
                          await _loadProfiles();
                          if (i == provider.activeProfileIndex) {
                            provider.setActiveProfile(0);
                          }
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF2C6E8A) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive ? const Color(0xFF2C6E8A) : (isDark ? Colors.white24 : Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.style == 'female' ? '👩' : (p.style == 'male' ? '👨' : '🧑'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(p.name, style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1A2B35)),
                        )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _styleLabel(String style) {
    if (AppStrings.lang == 'en') {
      switch (style) {
        case 'male': return 'Male';
        case 'female': return 'Female';
        default: return 'Unisex';
      }
    }
    switch (style) {
      case 'male': return 'Erkek';
      case 'female': return 'Kadın';
      default: return 'Unisex';
    }
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFF5F9FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2C6E8A), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _colorDot(int colorValue, AppProvider provider, bool isDark) {
    final isSelected = provider.themeColor == Color(colorValue);
    return GestureDetector(
      onTap: () => provider.setThemeColor(colorValue),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5)
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF5F9FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2C6E8A), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
