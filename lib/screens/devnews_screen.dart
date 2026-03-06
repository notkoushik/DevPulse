import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/data_provider.dart';
import '../data/models.dart';
import '../widgets/glass_card.dart';

// ══════════════════════════════════════════════════════════════════
//  Source badge color mapping
// ══════════════════════════════════════════════════════════════════

Color _sourceBadgeColor(String source) {
  switch (source.toLowerCase()) {
    case 'hackernews':
    case 'hn':
      return DevPulseColors.warning;
    case 'devto':
    case 'dev.to':
      return DevPulseColors.info;
    case 'github':
      return DevPulseColors.primary;
    case 'reddit':
      return const Color(0xFFFF4500);
    default:
      return DevPulseColors.success;
  }
}

String _sourceBadgeLabel(String source) {
  switch (source.toLowerCase()) {
    case 'hackernews':
    case 'hn':
      return 'HN';
    case 'devto':
    case 'dev.to':
      return 'DEV';
    case 'github':
      return 'GH';
    case 'reddit':
      return 'R/';
    default:
      return source.toUpperCase();
  }
}

// ══════════════════════════════════════════════════════════════════
//  DevNewsScreen
// ══════════════════════════════════════════════════════════════════

class DevNewsScreen extends StatefulWidget {
  const DevNewsScreen({super.key});

  @override
  State<DevNewsScreen> createState() => _DevNewsScreenState();
}

class _DevNewsScreenState extends State<DevNewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DataProvider>();
      provider.loadAiNewsFeed();
      provider.loadNewsFeed();
      provider.loadTrendingRepos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final provider = context.watch<DataProvider>();

    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 120.0,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Dev News',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    color: theme.text,
                  ),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    'AI DEV INFO',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                ),
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            tabBar: TabBar(
              controller: _tabController,
              labelColor: theme.text,
              unselectedLabelColor: theme.textMuted,
              indicatorColor: DevPulseColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              tabs: const [
                Tab(text: 'AI Digest'),
                Tab(text: 'Dev.to'),
                Tab(text: 'Reddit'),
                Tab(text: 'Trending'),
              ],
            ),
            theme: theme,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: AI Digest Summary
          _buildAiDigestList(
            theme: theme,
            items: provider.aiNewsFeed,
            isLoading: provider.isLoadingNews,
            emptyLabel: 'No AI summaries yet',
          ),

          // Tab 2: Dev.to
          _buildNewsList(
            theme: theme,
            items: provider.newsFeed
                .where((n) =>
                    n.source.toLowerCase() == 'devto' ||
                    n.source.toLowerCase() == 'dev.to')
                .toList(),
            isLoading: provider.isLoadingNews,
            emptyLabel: 'No Dev.to articles yet',
          ),

          // Tab 3: Reddit
          _buildNewsList(
            theme: theme,
            items: provider.newsFeed
                .where((n) => n.source.toLowerCase() == 'reddit')
                .toList(),
            isLoading: provider.isLoadingNews,
            emptyLabel: 'No Reddit posts yet',
          ),

          // Tab 4: Trending repos
          _buildTrendingList(
            theme: theme,
            repos: provider.trendingRepos,
            isLoading: provider.isLoadingNews,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  AI DIGEST LIST (Tab 1)
  // ══════════════════════════════════════════════════════════════

  Widget _buildAiDigestList({
    required DevPulseTheme theme,
    required List<AiNewsItem> items,
    required bool isLoading,
    required String emptyLabel,
  }) {
    if (isLoading && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: DevPulseColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing latest tech news...',
              style: TextStyle(fontSize: 12, color: theme.textMuted),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 40,
              color: DevPulseColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAiDigestCard(theme, item),
        )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: (50 * index).ms,
            )
            .slideY(begin: 0.1);
      },
    );
  }

  Widget _buildAiDigestCard(DevPulseTheme theme, AiNewsItem item) {
    return GlassCard(
      onTap: () => _openUrl(item.url),
      padding: const EdgeInsets.all(20),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ai Badge Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DevPulseColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: DevPulseColors.primary.withOpacity(0.3),
                            width: 1,
                          )
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 12, color: DevPulseColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'AI DIGEST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: DevPulseColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Optional: Show source or 'AI Generated' tag here
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Image if present
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                  ],

                  // Title
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // AI Summary Text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.fill2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.borderSubtle,
                      )
                    ),
                    child: Text(
                      item.summary,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Footer: Read more link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Read full article',
                        style: TextStyle(
                          fontSize: 12,
                          color: DevPulseColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: DevPulseColors.primary,
                      ),
                    ],
                  )
                ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  NEWS LIST (Tabs 2 & 3)
  // ══════════════════════════════════════════════════════════════

  Widget _buildNewsList({
    required DevPulseTheme theme,
    required List<NewsItem> items,
    required bool isLoading,
    required String emptyLabel,
  }) {
    if (isLoading && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: DevPulseColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading stories...',
              style: TextStyle(fontSize: 12, color: theme.textMuted),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 40,
              color: theme.textDim,
            ),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNewsCard(theme, item),
        )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: (50 * index).ms,
            )
            .slideY(begin: 0.1);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SINGLE NEWS CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildNewsCard(DevPulseTheme theme, NewsItem item) {
    final badgeColor = _sourceBadgeColor(item.source);
    final badgeLabel = _sourceBadgeLabel(item.source);

    return GlassCard(
      onTap: () => _openUrl(item.url),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Source badge + time ──
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: badgeColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.timeAgo,
                  style: TextStyle(fontSize: 10, color: theme.textGhost),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Title ──
            Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.text,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // ── Tags ──
            if (item.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.tags.take(3).map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.fill2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(fontSize: 9, color: theme.textMuted),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            // ── Author + stats row ──
            Row(
              children: [
                if (item.author != null && item.author!.isNotEmpty) ...[
                  Icon(Icons.person_outline,
                      size: 12, color: theme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    item.author!,
                    style: TextStyle(fontSize: 11, color: theme.textMuted),
                  ),
                  const SizedBox(width: 14),
                ],
                Icon(Icons.arrow_upward_rounded,
                    size: 12, color: DevPulseColors.warning),
                const SizedBox(width: 3),
                Text(
                  '${item.points}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
                Icon(Icons.chat_bubble_outline,
                    size: 11, color: theme.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${item.comments}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: theme.textDim,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TRENDING LIST (Tab 3)
  // ══════════════════════════════════════════════════════════════

  Widget _buildTrendingList({
    required DevPulseTheme theme,
    required List<TrendingRepo> repos,
    required bool isLoading,
  }) {
    if (isLoading && repos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: DevPulseColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading trending repos...',
              style: TextStyle(fontSize: 12, color: theme.textMuted),
            ),
          ],
        ),
      );
    }

    if (repos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              size: 40,
              color: theme.textDim,
            ),
            const SizedBox(height: 12),
            Text(
              'No trending repos yet',
              style: TextStyle(fontSize: 13, color: theme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTrendingCard(theme, repo),
        )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: (50 * index).ms,
            )
            .slideY(begin: 0.1);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SINGLE TRENDING CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildTrendingCard(DevPulseTheme theme, TrendingRepo repo) {
    // Parse language color from hex string
    Color langColor;
    try {
      final hex = repo.languageColor.replaceAll('#', '');
      langColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      langColor = DevPulseColors.primary;
    }

    return GlassCard(
      onTap: () => _openUrl(repo.url),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Repo name + author ──
            Row(
              children: [
                Icon(Icons.book_outlined, size: 14, color: theme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${repo.author} / ',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textMuted,
                          ),
                        ),
                        TextSpan(
                          text: repo.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Description ──
            if (repo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  repo.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // ── Language + stars + open button ──
            Row(
              children: [
                // Language dot + label
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: langColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  repo.language,
                  style: TextStyle(fontSize: 11, color: theme.textMuted),
                ),
                const SizedBox(width: 16),

                // Total stars
                Icon(Icons.star_border, size: 13, color: DevPulseColors.warning),
                const SizedBox(width: 3),
                Text(
                  _formatCount(repo.stars),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),

                // Today stars
                Icon(Icons.trending_up, size: 12, color: DevPulseColors.success),
                const SizedBox(width: 3),
                Text(
                  '+${repo.todayStars} today',
                  style: TextStyle(
                    fontSize: 10,
                    color: DevPulseColors.success,
                  ),
                ),

                const Spacer(),

                // Open button
                GestureDetector(
                  onTap: () => _openUrl(repo.url),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DevPulseColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DevPulseColors.primary.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: DevPulseColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          size: 10,
                          color: DevPulseColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}

// ══════════════════════════════════════════════════════════════════
//  Persistent tab-bar header delegate
// ══════════════════════════════════════════════════════════════════

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final DevPulseTheme theme;

  _TabBarDelegate({required this.tabBar, required this.theme});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: theme.bg.withValues(alpha: 0.85),
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
