import { Router } from 'express';
import axios from 'axios';
import { cache } from '../cache';
import { supabase } from '../middleware/auth';

export const newsRouter = Router();

// ─── Types ───

interface NewsItem {
  id: string;
  title: string;
  url: string;
  source: string;
  author: string | null;
  points: number;
  comments: number;
  timeAgo: string;
  tags: string[];
}

interface TrendingRepo {
  name: string;
  author: string;
  description: string;
  language: string;
  languageColor: string;
  stars: number;
  todayStars: number;
  url: string;
}

// ─── Helpers ───

function timeAgo(timestamp: number): string {
  const seconds = Math.floor((Date.now() / 1000) - timestamp);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

// ─── HackerNews ───

async function fetchHackerNews(): Promise<NewsItem[]> {
  const cached = cache.get<NewsItem[]>('news_hackernews');
  if (cached) return cached;

  const { data: ids } = await axios.get<number[]>(
    'https://hacker-news.firebaseio.com/v0/topstories.json',
    { timeout: 8000 }
  );

  const top30 = ids.slice(0, 30);
  const stories = await Promise.all(
    top30.map(id =>
      axios.get(`https://hacker-news.firebaseio.com/v0/item/${id}.json`, { timeout: 5000 })
        .then(r => r.data)
        .catch(() => null)
    )
  );

  const items: NewsItem[] = stories
    .filter((s: any) => s && s.title)
    .map((s: any) => ({
      id: `hn_${s.id}`,
      title: s.title,
      url: s.url || `https://news.ycombinator.com/item?id=${s.id}`,
      source: 'hackernews',
      author: s.by || null,
      points: s.score || 0,
      comments: s.descendants || 0,
      timeAgo: timeAgo(s.time),
      tags: [],
    }));

  cache.set('news_hackernews', items, 600);
  return items;
}

// ─── Dev.to ───

async function fetchDevTo(): Promise<NewsItem[]> {
  const cached = cache.get<NewsItem[]>('news_devto');
  if (cached) return cached;

  const { data: articles } = await axios.get(
    'https://dev.to/api/articles?per_page=20&top=7',
    { timeout: 8000 }
  );

  const items: NewsItem[] = (articles as any[]).map((a: any) => ({
    id: `devto_${a.id}`,
    title: a.title,
    url: a.url,
    source: 'devto',
    author: a.user?.name || a.user?.username || null,
    points: a.positive_reactions_count || 0,
    comments: a.comments_count || 0,
    timeAgo: _devtoTimeAgo(a.published_at),
    tags: a.tag_list || [],
  }));

  cache.set('news_devto', items, 300); // 5 min cache for fresher content
  return items;
}

function _devtoTimeAgo(dateStr: string): string {
  const seconds = Math.floor((Date.now() - new Date(dateStr).getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

// ─── GitHub Trending ───

const LANGUAGE_COLORS: Record<string, string> = {
  'JavaScript': '#f1e05a',
  'TypeScript': '#3178c6',
  'Python': '#3572A5',
  'Java': '#b07219',
  'Go': '#00ADD8',
  'Rust': '#dea584',
  'C++': '#f34b7d',
  'C': '#555555',
  'C#': '#178600',
  'Ruby': '#701516',
  'PHP': '#4F5D95',
  'Swift': '#F05138',
  'Kotlin': '#A97BFF',
  'Dart': '#00B4AB',
  'Scala': '#c22d40',
  'Shell': '#89e051',
  'Lua': '#000080',
  'Vue': '#41b883',
  'HTML': '#e34c26',
  'CSS': '#563d7c',
  'SCSS': '#c6538c',
  'Jupyter Notebook': '#DA5B0B',
  'R': '#198CE7',
  'Elixir': '#6e4a7e',
  'Haskell': '#5e5086',
  'Zig': '#ec915c',
};

async function fetchGitHubTrending(): Promise<TrendingRepo[]> {
  const cached = cache.get<TrendingRepo[]>('news_trending');
  if (cached) return cached;

  const headers: Record<string, string> = {
    'Accept': 'application/vnd.github.v3+json',
  };
  if (process.env.GITHUB_PAT) {
    headers['Authorization'] = `Bearer ${process.env.GITHUB_PAT}`;
  }

  const oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
  const oneDayAgo = new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

  // Query 1: Established popular repos pushed recently
  const [established, rising] = await Promise.all([
    axios.get(
      `https://api.github.com/search/repositories?q=stars:>500+pushed:>${oneDayAgo}&sort=stars&order=desc&per_page=10`,
      { timeout: 8000, headers }
    ).catch(() => ({ data: { items: [] } })),
    // Query 2: New repos with rapid star growth
    axios.get(
      `https://api.github.com/search/repositories?q=created:>${oneWeekAgo}+stars:>50&sort=stars&order=desc&per_page=10`,
      { timeout: 8000, headers }
    ).catch(() => ({ data: { items: [] } })),
  ]);

  // Merge and deduplicate
  const allRepos = new Map<string, any>();
  for (const r of [...(established.data.items || []), ...(rising.data.items || [])]) {
    if (!allRepos.has(r.full_name)) {
      allRepos.set(r.full_name, r);
    }
  }

  const repos: TrendingRepo[] = Array.from(allRepos.values())
    .slice(0, 20)
    .map((r: any) => {
      // Estimate daily stars based on repo age
      const createdAt = new Date(r.created_at).getTime();
      const ageInDays = Math.max(1, Math.floor((Date.now() - createdAt) / (24 * 60 * 60 * 1000)));
      const estimatedDailyStars = Math.round(r.stargazers_count / ageInDays);

      return {
        name: r.name,
        author: r.owner?.login || '',
        description: r.description || '',
        language: r.language || 'Unknown',
        languageColor: LANGUAGE_COLORS[r.language] || '#888888',
        stars: r.stargazers_count || 0,
        todayStars: Math.min(estimatedDailyStars, r.stargazers_count),
        url: r.html_url,
      };
    });

  // Sort by estimated daily stars for a trending feel
  repos.sort((a, b) => b.todayStars - a.todayStars);

  cache.set('news_trending', repos, 600);
  return repos;
}

// ─── Reddit ───

async function fetchReddit(): Promise<NewsItem[]> {
  const cached = cache.get<NewsItem[]>('news_reddit');
  if (cached) return cached;

  const subreddits = ['programming', 'webdev'];
  const allItems: NewsItem[] = [];

  for (const sub of subreddits) {
    try {
      const { data } = await axios.get(
        `https://www.reddit.com/r/${sub}/hot.json?limit=15`,
        {
          timeout: 8000,
          headers: {
            'User-Agent': 'DevPulse/1.0 (developer-dashboard)',
          },
        }
      );

      const posts = data?.data?.children || [];
      const items: NewsItem[] = posts
        .filter((p: any) => p.data && !p.data.stickied)
        .map((p: any) => {
          const d = p.data;
          return {
            id: `reddit_${d.id}`,
            title: d.title,
            url: d.url_overridden_by_dest || `https://reddit.com${d.permalink}`,
            source: 'reddit',
            author: d.author || null,
            points: d.score || 0,
            comments: d.num_comments || 0,
            timeAgo: _redditTimeAgo(d.created_utc),
            tags: [sub],
          };
        });
      allItems.push(...items);
    } catch (e: any) {
      console.error(`Reddit r/${sub} fetch error:`, e.message);
    }
  }

  cache.set('news_reddit', allItems, 300); // 5 min cache
  return allItems;
}

function _redditTimeAgo(utcTimestamp: number): string {
  const seconds = Math.floor(Date.now() / 1000 - utcTimestamp);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

// ─── Routes ───

// GET /api/news/ai-feed
newsRouter.get('/ai-feed', async (_req, res) => {
  try {
    const { data, error } = await supabase
      .from('ai_news_feed')
      .select('*')
      .order('published_at', { ascending: false })
      .limit(20);

    if (error) throw error;

    res.json({
      items: data || [],
      lastUpdated: new Date().toISOString(),
    });
  } catch (err: any) {
    console.error('AI News feed error:', err.message);
    res.status(500).json({ error: 'Failed to fetch AI news feed' });
  }
});

// GET /api/news/feed?source=all|hackernews|devto
newsRouter.get('/feed', async (req, res) => {
  try {
    const source = (req.query.source as string) || 'all';

    let items: NewsItem[] = [];

    if (source === 'all' || source === 'hackernews') {
      try {
        const hn = await fetchHackerNews();
        items.push(...hn);
      } catch (e: any) {
        console.error('HackerNews fetch error:', e.message);
      }
    }

    if (source === 'all' || source === 'devto') {
      try {
        const devto = await fetchDevTo();
        items.push(...devto);
      } catch (e: any) {
        console.error('Dev.to fetch error:', e.message);
      }
    }

    if (source === 'all' || source === 'reddit') {
      try {
        const reddit = await fetchReddit();
        items.push(...reddit);
      } catch (e: any) {
        console.error('Reddit fetch error:', e.message);
      }
    }

    // Sort by points descending for combined feed
    if (source === 'all') {
      items.sort((a, b) => b.points - a.points);
    }

    res.json({
      items,
      lastUpdated: new Date().toISOString(),
    });
  } catch (err: any) {
    console.error('News feed error:', err.message);
    res.status(500).json({ error: 'Failed to fetch news feed' });
  }
});

// GET /api/news/trending
newsRouter.get('/trending', async (_req, res) => {
  try {
    const repos = await fetchGitHubTrending();
    res.json({ repos });
  } catch (err: any) {
    console.error('Trending fetch error:', err.message);
    res.status(500).json({ error: 'Failed to fetch trending repos' });
  }
});
