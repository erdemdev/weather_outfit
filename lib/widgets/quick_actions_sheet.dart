import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class MenuAction {
  final String value;
  final IconData icon;
  final String label;

  const MenuAction(this.value, this.icon, this.label);
}

class MenuCategory {
  final String title;
  final List<MenuAction> actions;

  const MenuCategory(this.title, this.actions);
}

class QuickActionsSheet extends StatelessWidget {
  final void Function(String action) onAction;

  const QuickActionsSheet({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _menuCategories();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2B35) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          const SizedBox(height: 14),
          Text(
            AppStrings.lang == 'en' ? 'Quick Actions' : 'Hızlı İşlemler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2B35),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildMenuSection(
                  context,
                  AppStrings.lang == 'en' ? 'Quick' : 'Hızlı',
                  [
                    MenuAction('gps', Icons.my_location_rounded,
                        AppStrings.get('gps_location')),
                    MenuAction('history', Icons.history_rounded,
                        AppStrings.get('history')),
                    MenuAction('settings', Icons.settings_rounded,
                        AppStrings.get('settings')),
                  ],
                  isDark,
                ),
                for (final category in categories)
                  _buildMenuSection(
                      context, category.title, category.actions, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<MenuAction> actions,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(10)
            : const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : const Color(0xFF2C6E8A).withAlpha(31),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF2C6E8A),
            ),
          ),
          const SizedBox(height: 8),
          ...actions.map((action) =>
              _buildMenuActionTile(context, action, isDark)),
        ],
      ),
    );
  }

  Widget _buildMenuActionTile(
      BuildContext context, MenuAction action, bool isDark) {
    return Semantics(
      button: true,
      label: action.label,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(action.icon, size: 20, color: const Color(0xFF2C6E8A)),
        title: Text(
          action.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1A2B35),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : Colors.black26),
        onTap: () {
          Navigator.pop(context);
          onAction(action.value);
        },
      ),
    );
  }

  List<MenuCategory> _menuCategories() {
    final isEN = AppStrings.lang == 'en';
    return [
      MenuCategory(
        isEN ? 'Weather' : 'Hava',
        [
          MenuAction('multi_city', Icons.location_city_rounded,
              AppStrings.get('multi_city')),
          MenuAction('weather_alert', Icons.notifications_active_rounded,
              AppStrings.get('weather_alert')),
          MenuAction('weather_note', Icons.note_add_rounded,
              AppStrings.get('weather_note')),
          MenuAction('weather_compare', Icons.compare_arrows_rounded,
              AppStrings.get('weather_compare')),
          MenuAction('weekly_summary', Icons.bar_chart_rounded,
              AppStrings.get('weekly_summary')),
        ],
      ),
      MenuCategory(
        isEN ? 'Wardrobe' : 'Dolap',
        [
          MenuAction(
              'wardrobe', Icons.checkroom_rounded, AppStrings.get('wardrobe')),
          MenuAction('wardrobe_stats', Icons.bar_chart_rounded,
              AppStrings.get('wardrobe_stats')),
          MenuAction('capsule_wardrobe', Icons.checkroom_rounded,
              AppStrings.get('capsule_wardrobe')),
          MenuAction('clothing_tags', Icons.label_rounded,
              AppStrings.get('clothing_tags')),
          MenuAction('care_reminder', Icons.notifications_active_rounded,
              AppStrings.get('care_reminders')),
          MenuAction('laundry', Icons.local_laundry_service_rounded,
              AppStrings.get('laundry')),
        ],
      ),
      MenuCategory(
        isEN ? 'Outfit' : 'Kombin',
        [
          MenuAction('outfit_search', Icons.search_rounded,
              AppStrings.get('outfit_search')),
          MenuAction('combo_generator', Icons.auto_awesome_rounded,
              AppStrings.get('combo_generator')),
          MenuAction('outfit_remix', Icons.refresh_rounded,
              AppStrings.get('outfit_remix')),
          MenuAction('event_outfit', Icons.event_rounded,
              AppStrings.get('event_outfit')),
          MenuAction(
              'mood_outfit', Icons.mood_rounded, AppStrings.get('mood_outfit')),
          MenuAction('location_outfit', Icons.place_rounded,
              AppStrings.get('location_outfit')),
          MenuAction('friend_outfit', Icons.group_rounded,
              AppStrings.get('friend_outfit')),
        ],
      ),
      MenuCategory(
        isEN ? 'Insights' : 'Analiz',
        [
          MenuAction('trend_analysis', Icons.trending_up_rounded,
              AppStrings.get('trend_analysis')),
          MenuAction('style_score', Icons.emoji_events_rounded,
              AppStrings.get('style_score')),
          MenuAction('color_analysis', Icons.color_lens_rounded,
              AppStrings.get('color_analysis')),
          MenuAction('color_trends', Icons.palette_rounded,
              AppStrings.get('color_trends')),
          MenuAction('dashboard', Icons.dashboard_rounded,
              AppStrings.get('dashboard')),
          MenuAction('weekly_report', Icons.summarize_rounded,
              AppStrings.get('weekly_report')),
        ],
      ),
      MenuCategory(
        isEN ? 'Tools' : 'Araçlar',
        [
          MenuAction('travel', Icons.flight_takeoff_rounded,
              AppStrings.get('travel_mode')),
          MenuAction(
              'packing', Icons.luggage_rounded, AppStrings.get('packing')),
          MenuAction('budget', Icons.account_balance_wallet_rounded,
              AppStrings.get('budget')),
          MenuAction('shopping_list', Icons.shopping_cart_rounded,
              AppStrings.get('shopping_list')),
          MenuAction(
              'countdown', Icons.timer_rounded, AppStrings.get('countdown')),
          MenuAction('backup', Icons.backup_rounded, AppStrings.get('backup')),
        ],
      ),
      MenuCategory(
        isEN ? 'Social' : 'Sosyal',
        [
          MenuAction('gallery', Icons.photo_library_rounded,
              AppStrings.get('gallery')),
          MenuAction('ai_assistant', Icons.psychology_rounded,
              AppStrings.get('ai_assistant')),
          MenuAction('fashion_tips', Icons.lightbulb_rounded,
              AppStrings.get('fashion_tips')),
          MenuAction('style_challenge', Icons.emoji_objects_rounded,
              AppStrings.get('style_challenge')),
          MenuAction('recommend_app', Icons.share_rounded,
              AppStrings.get('recommend_app')),
          MenuAction('rate_app', Icons.star_rate_rounded,
              AppStrings.get('rate_app')),
          MenuAction('feedback', Icons.feedback_rounded,
              AppStrings.get('feedback')),
        ],
      ),
      MenuCategory(
        isEN ? 'Personal' : 'Kişisel',
        [
          MenuAction('streak', Icons.local_fire_department_rounded,
              AppStrings.get('streak')),
          MenuAction('achievements', Icons.emoji_events_rounded,
              AppStrings.get('achievements')),
          MenuAction(
              'calendar', Icons.event_rounded, AppStrings.get('calendar')),
          MenuAction('monthly_plan', Icons.calendar_month_rounded,
              AppStrings.get('monthly_plan')),
          MenuAction(
              'comfort', Icons.thermostat_rounded, AppStrings.get('comfort')),
          MenuAction('seasonal_guide', Icons.park_rounded,
              AppStrings.get('seasonal_guide')),
        ],
      ),
    ];
  }
}
