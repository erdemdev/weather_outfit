import 'package:flutter/material.dart';
import '../services/color_analysis_service.dart';
import '../l10n/app_localizations.dart';

class ColorAnalysisScreen extends StatefulWidget {
  const ColorAnalysisScreen({super.key});

  @override
  State<ColorAnalysisScreen> createState() => _ColorAnalysisScreenState();
}

class _ColorAnalysisScreenState extends State<ColorAnalysisScreen> {
  ColorSeason? _result;
  int _currentQuestion = 0;
  final List<int> _answers = [];
  bool _loading = true;
  bool _quizMode = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await ColorAnalysisService.getSavedResult();
    setState(() {
      _result = saved;
      _loading = false;
    });
  }

  void _answerQuestion(int optionIndex) {
    _answers.add(optionIndex);
    if (_currentQuestion < ColorAnalysisService.questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      // Calculate result
      final season = ColorAnalysisService.calculateSeason(_answers);
      ColorAnalysisService.saveResult(season.id);
      setState(() {
        _result = season;
        _quizMode = false;
      });
    }
  }

  void _startQuiz() {
    setState(() {
      _quizMode = true;
      _currentQuestion = 0;
      _answers.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Color Analysis' : 'Renk Analizi'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quizMode
              ? _buildQuiz(isDark, isEN)
              : _result != null
                  ? _buildResult(isDark, isEN)
                  : _buildStart(isDark, isEN),
    );
  }

  Widget _buildStart(bool isDark, bool isEN) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎨', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isEN ? 'Discover Your Color Season' : 'Renk Mevsimini Keşfet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isEN
                  ? 'Answer 5 quick questions to find out which colors complement you best!'
                  : '5 hızlı soruya cevap ver ve sana en çok yakışan renkleri öğren!',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white60 : Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _startQuiz,
              icon: const Icon(Icons.play_arrow),
              label: Text(isEN ? 'Start Quiz' : 'Teste Başla'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C6E8A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz(bool isDark, bool isEN) {
    final q = ColorAnalysisService.questions[_currentQuestion];
    final options = q['options'] as List;
    final progress = (_currentQuestion + 1) / ColorAnalysisService.questions.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF2C6E8A)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${isEN ? 'Question' : 'Soru'} ${_currentQuestion + 1}/${ColorAnalysisService.questions.length}',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Text(
          isEN ? q['en'] as String : q['tr'] as String,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(options.length, (i) {
          final opt = options[i] as Map;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _answerQuestion(i),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C6E8A).withValues(alpha: 0.2)),
                ),
                child: Text(
                  isEN ? opt['en'] as String : opt['tr'] as String,
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResult(bool isDark, bool isEN) {
    final season = _result!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Result header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [season.palette.first.withValues(alpha: 0.8), season.palette[1].withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(season.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(
                isEN ? season.nameEN : season.nameTR,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                isEN ? 'Your Color Season' : 'Senin Renk Mevsimin',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                isEN ? season.descEN : season.descTR,
                style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Your colors
        Text(isEN ? 'Your Best Colors' : 'Sana En Yakışan Renkler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: season.palette.map((c) => Expanded(
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
        // Avoid colors
        Text(isEN ? 'Colors to Avoid' : 'Kaçınılacak Renkler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: season.avoid.map((c) => Expanded(
            child: Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.close, color: Colors.white54, size: 20)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 32),
        // Retake quiz
        Center(
          child: OutlinedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.refresh),
            label: Text(isEN ? 'Retake Quiz' : 'Testi Tekrarla'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2C6E8A)),
          ),
        ),
      ],
    );
  }
}
