import 'package:flutter/material.dart';
import '../services/care_reminder_service.dart';
import '../l10n/app_localizations.dart';

class CareReminderScreen extends StatefulWidget {
  const CareReminderScreen({super.key});

  @override
  State<CareReminderScreen> createState() => _CareReminderScreenState();
}

class _CareReminderScreenState extends State<CareReminderScreen> {
  List<CareReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reminders = await CareReminderService.getReminders();
    setState(() => _reminders = reminders);
  }

  void _addReminder() {
    final nameCtrl = TextEditingController();
    String careType = 'wash';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    final isEN = AppStrings.lang == 'en';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEN ? 'Add Reminder' : 'Hatırlatıcı Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isEN ? 'Item name' : 'Kıyafet adı',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: careType,
                decoration: InputDecoration(
                  labelText: isEN ? 'Care type' : 'Bakım türü',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'wash', child: Text(isEN ? '🧺 Wash' : '🧺 Yıkama')),
                  DropdownMenuItem(value: 'dry_clean', child: Text(isEN ? '🧹 Dry Clean' : '🧹 Kuru Temizleme')),
                  DropdownMenuItem(value: 'iron', child: Text(isEN ? '♨️ Iron' : '♨️ Ütüleme')),
                  DropdownMenuItem(value: 'repair', child: Text(isEN ? '🪡 Repair' : '🪡 Tamir')),
                ],
                onChanged: (v) => setDialogState(() => careType = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text('${dueDate.day}.${dueDate.month}.${dueDate.year}'),
                subtitle: Text(isEN ? 'Due date' : 'Tarih'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setDialogState(() => dueDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEN ? 'Cancel' : 'İptal')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  await CareReminderService.addReminder(CareReminder(
                    itemName: nameCtrl.text,
                    careType: careType,
                    dueDate: dueDate,
                  ));
                  await _loadData();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';
    final overdue = _reminders.where((r) => r.isOverdue).toList();
    final upcoming = _reminders.where((r) => !r.completed && !r.isOverdue).toList();
    final done = _reminders.where((r) => r.completed).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Care Reminders' : 'Bakım Hatırlatıcı'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: const Color(0xFF2C6E8A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _reminders.isEmpty
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧺', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  isEN ? 'No care reminders yet' : 'Henüz hatırlatıcı yok',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                ),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (overdue.isNotEmpty) ...[
                  _sectionTitle(isEN ? '⚠️ Overdue' : '⚠️ Gecikmiş', Colors.red, isDark),
                  ...overdue.map((r) => _reminderTile(r, isDark, isEN)),
                  const SizedBox(height: 12),
                ],
                if (upcoming.isNotEmpty) ...[
                  _sectionTitle(isEN ? '📅 Upcoming' : '📅 Yaklaşan', const Color(0xFF2C6E8A), isDark),
                  ...upcoming.map((r) => _reminderTile(r, isDark, isEN)),
                  const SizedBox(height: 12),
                ],
                if (done.isNotEmpty) ...[
                  _sectionTitle(isEN ? '✅ Completed' : '✅ Tamamlanan', Colors.green, isDark),
                  ...done.map((r) => _reminderTile(r, isDark, isEN)),
                ],
              ],
            ),
    );
  }

  Widget _sectionTitle(String title, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600, color: color,
      )),
    );
  }

  Widget _reminderTile(CareReminder reminder, bool isDark, bool isEN) {
    final idx = _reminders.indexOf(reminder);
    final daysLeft = reminder.dueDate.difference(DateTime.now()).inDays;

    return Dismissible(
      key: ValueKey('${reminder.itemName}_${reminder.dueDate}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await CareReminderService.removeReminder(idx);
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3345) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: reminder.isOverdue ? Border.all(color: Colors.red.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                await CareReminderService.toggleComplete(idx);
                _loadData();
              },
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reminder.completed
                      ? Colors.green.withValues(alpha: 0.15)
                      : (isDark ? Colors.white10 : Colors.grey[100]),
                ),
                child: Icon(
                  reminder.completed ? Icons.check_rounded : Icons.circle_outlined,
                  size: 18,
                  color: reminder.completed ? Colors.green : (isDark ? Colors.white38 : Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(reminder.careEmojiTR, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.itemName, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A2B35),
                    decoration: reminder.completed ? TextDecoration.lineThrough : null,
                  )),
                  Text(
                    isEN ? reminder.careNameEN() : reminder.careNameTR(),
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              reminder.isOverdue
                  ? (isEN ? 'Overdue!' : 'Gecikti!')
                  : (daysLeft == 0 ? (isEN ? 'Today' : 'Bugün') : '$daysLeft ${isEN ? 'days' : 'gün'}'),
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: reminder.isOverdue ? Colors.red : (daysLeft <= 2 ? Colors.orange : (isDark ? Colors.white54 : Colors.grey[600])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
