import 'package:flutter/material.dart';
import '../services/weather_note_service.dart';
import '../l10n/app_localizations.dart';

class WeatherNoteScreen extends StatefulWidget {
  final String? city;
  final double? temperature;
  final String? condition;
  const WeatherNoteScreen({super.key, this.city, this.temperature, this.condition});

  @override
  State<WeatherNoteScreen> createState() => _WeatherNoteScreenState();
}

class _WeatherNoteScreenState extends State<WeatherNoteScreen> {
  List<WeatherNote> _notes = [];
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await WeatherNoteService.getNotes();
    setState(() => _notes = notes);
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await WeatherNoteService.addNote(WeatherNote(
      date: dateStr,
      note: _noteController.text.trim(),
      city: widget.city ?? '',
      temperature: widget.temperature ?? 0,
      condition: widget.condition ?? '',
    ));
    _noteController.clear();
    await _loadNotes();
  }

  Future<void> _deleteNote(int index) async {
    await WeatherNoteService.removeNote(index);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Weather Notes' : 'Hava Notları'),
        backgroundColor: isDark ? const Color(0xFF1A2B35) : const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3345) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              children: [
                if (widget.city != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(_emoji(widget.condition ?? ''), style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text('${widget.city} — ${widget.temperature?.round() ?? 0}°C',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF2C6E8A))),
                      ],
                    ),
                  ),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: isEN ? 'Write your weather note...' : 'Hava notunu yaz...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add),
                    label: Text(isEN ? 'Add Note' : 'Not Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6E8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? Center(child: Text(isEN ? 'No notes yet' : 'Henüz not yok', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) => _buildNoteCard(_notes[i], i, isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(WeatherNote note, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3345) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_emoji(note.condition), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('${note.city} — ${note.temperature.round()}°C',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF2C6E8A))),
              const Spacer(),
              Text(note.date, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _deleteNote(index),
                child: Icon(Icons.close, size: 16, color: isDark ? Colors.white38 : Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.note, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A2B35))),
        ],
      ),
    );
  }

  String _emoji(String condition) {
    switch (condition) {
      case 'clear': return '☀️';
      case 'clouds': return '⛅';
      case 'rain': return '🌧️';
      case 'snow': return '❄️';
      default: return '🌤️';
    }
  }
}
