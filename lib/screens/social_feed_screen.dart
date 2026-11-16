import 'package:flutter/material.dart';
import '../services/social_feed_service.dart';
import '../l10n/app_localizations.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  List<SocialPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await SocialFeedService.getPosts();
    setState(() {
      _posts = posts.isEmpty ? SocialFeedService.getDemoPosts() : posts;
      _loading = false;
    });
  }

  Future<void> _likePost(int index) async {
    await SocialFeedService.likePost(index);
    setState(() {
      _posts[index] = _posts[index].copyWith(likes: _posts[index].likes + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEN = AppStrings.lang == 'en';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isEN ? 'Social Feed' : 'Sosyal Duvar'),
        backgroundColor: const Color(0xFF2C6E8A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(child: Text(isEN ? 'No posts yet' : 'Henüz gönderi yok'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return _buildPostCard(post, index, isDark, isEN);
                  },
                ),
    );
  }

  Widget _buildPostCard(SocialPost post, int index, bool isDark, bool isEN) {
    final timeAgo = DateTime.now().difference(post.date);
    String timeText;
    if (timeAgo.inHours < 1) {
      timeText = '${timeAgo.inMinutes}${isEN ? 'm ago' : 'dk önce'}';
    } else if (timeAgo.inHours < 24) {
      timeText = '${timeAgo.inHours}${isEN ? 'h ago' : 'sa önce'}';
    } else {
      timeText = '${timeAgo.inDays}${isEN ? 'd ago' : 'g önce'}';
    }

    return Card(
      color: isDark ? const Color(0xFF1B2A3D) : Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2C6E8A),
                  child: Text(post.username[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      Text('$timeText • ${post.city}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black45)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C6E8A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${post.temperature.round()}°', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C6E8A))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Outfit info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2C6E8A).withValues(alpha: 0.15), const Color(0xFF2C6E8A).withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.outfitTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: post.tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: isDark ? const Color(0xFF243447) : const Color(0xFFEEF2F7),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                InkWell(
                  onTap: () => _likePost(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 20, color: Color(0xFFE53935)),
                        const SizedBox(width: 4),
                        Text('${post.likes}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 18, color: isDark ? Colors.white38 : Colors.black26),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, size: 18, color: isDark ? Colors.white38 : Colors.black26),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
