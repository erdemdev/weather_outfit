import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    const _OnboardingPage(
      emoji: '🌤️',
      titleTR: 'Hava Durumuna Göre\nKombin Önerisi',
      titleEN: 'Weather-Based\nOutfit Suggestions',
      subtitleTR:
          'Günlük hava durumuna göre sana en uygun kıyafet kombinini öneriyoruz.',
      subtitleEN:
          'We suggest the best outfit combination based on daily weather.',
      colors: [Color(0xFF2C6E8A), Color(0xFF3A8FA8)],
    ),
    const _OnboardingPage(
      emoji: '👔',
      titleTR: 'Stilini Seç',
      titleEN: 'Choose Your Style',
      subtitleTR: 'Kadın, erkek veya unisex — sana özel kombin önerileri al.',
      subtitleEN:
          'Female, male, or unisex — get personalized outfit suggestions.',
      colors: [Color(0xFF6B4FCF), Color(0xFF9B7AE8)],
    ),
    const _OnboardingPage(
      emoji: '📱',
      titleTR: 'Haftalık Plan &\nGünlük Bildirim',
      titleEN: 'Weekly Plan &\nDaily Notifications',
      subtitleTR: 'Her sabah kıyafet önerisi al, haftalık planını yap.',
      subtitleEN: 'Get daily outfit suggestions, plan your week ahead.',
      colors: [Color(0xFFE8974A), Color(0xFFF4B062)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _buildPage(_pages[i]),
          ),
          if (_currentPage == _pages.length - 1)
            Positioned(
              bottom: 30,
              left: 40,
              right: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDots(),
                  const SizedBox(height: 20),
                  _buildStyleSelector(),
                ],
              ),
            )
          else
            Positioned(
              bottom: 30,
              left: 40,
              right: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDots(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].colors[0],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppStrings.lang == 'tr' ? 'Devam' : 'Continue',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: _buildLanguageSelector(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: TextButton(
              onPressed: _finish,
              child: Text(
                AppStrings.lang == 'tr' ? 'Atla' : 'Skip',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == i ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == i ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    final isEN = AppStrings.lang == 'en';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.colors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(page.emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 40),
              Text(
                isEN ? page.titleEN : page.titleTR,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEN ? page.subtitleEN : page.subtitleTR,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    final provider = context.read<AppProvider>();
    final isEN = AppStrings.lang == 'en';

    return Column(
      children: [
        Text(
          isEN ? 'Your Style' : 'Stilin',
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _styleBtn('👩', isEN ? 'Female' : 'Kadın', 'female', provider),
            const SizedBox(width: 8),
            _styleBtn('🧑', isEN ? 'Unisex' : 'Unisex', 'unisex', provider),
            const SizedBox(width: 8),
            _styleBtn('👨', isEN ? 'Male' : 'Erkek', 'male', provider),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _finish,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _pages.last.colors[0],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isEN ? 'Get Started' : 'Başla',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    final provider = context.read<AppProvider>();
    final isTR = AppStrings.lang == 'tr';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          _langBtn('TR', 'tr', isTR, provider),
          const SizedBox(width: 4),
          _langBtn('EN', 'en', !isTR, provider),
        ],
      ),
    );
  }

  Widget _langBtn(
      String label, String value, bool selected, AppProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setLanguage(value);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? _pages[_currentPage].colors[0] : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _styleBtn(
      String emoji, String label, String value, AppProvider provider) {
    final selected = provider.stylePreference == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          provider.setStylePreference(value);
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: selected ? null : Border.all(color: Colors.white30),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? _pages.last.colors[0] : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finish() {
    context.read<AppProvider>().completeOnboarding();
  }
}

class _OnboardingPage {
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String subtitleTR;
  final String subtitleEN;
  final List<Color> colors;

  const _OnboardingPage({
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.subtitleTR,
    required this.subtitleEN,
    required this.colors,
  });
}
