import cron from 'node-cron';
import RssParser from 'rss-parser';
import * as cheerio from 'cheerio';
import { supabase } from '../middleware/auth';
import { generateContent } from '../utils/ai';

const parser = new RssParser();

// List of quality tech feeds
const RSS_FEEDS = [
    'https://techcrunch.com/feed/',
    'https://www.theverge.com/rss/frontpage',
    'https://hnrss.org/frontpage',
];

async function fetchAndSummarizeNews() {
    console.log('[NewsWorker] Starting news fetch and summarization cycle...');

    try {
        const allArticles = [];

        // 1. Fetch from all RSS feeds
        for (const feedUrl of RSS_FEEDS) {
            try {
                const feed = await parser.parseURL(feedUrl);
                // Only take the top 3 from each
                const recent = feed.items.slice(0, 3);
                allArticles.push(...recent);
            } catch (err) {
                console.error(`[NewsWorker] Failed to fetch feed ${feedUrl}:`, err);
            }
        }

        // Sort by pubDate descending and pick top 5 total to summarize
        allArticles.sort((a, b) => {
            const dateA = a.pubDate ? new Date(a.pubDate).getTime() : 0;
            const dateB = b.pubDate ? new Date(b.pubDate).getTime() : 0;
            return dateB - dateA;
        });

        const topArticles = allArticles.slice(0, 6);

        for (const article of topArticles) {
            if (!article.link || !article.title) continue;

            // Check if already in DB
            const { data: existing } = await supabase
                .from('ai_news_feed')
                .select('id')
                .eq('url', article.link)
                .single();

            if (existing) {
                console.log(`[NewsWorker] Skipping existing article: ${article.title}`);
                continue;
            }

            // Extract raw text from any content/snippet provided in the RSS
            let rawText = '';
            if (article['content:encoded']) rawText = article['content:encoded'] as string;
            else if (article.content) rawText = article.content;
            else if (article.contentSnippet) rawText = article.contentSnippet;

            const cleanText = cheerio.load(rawText).text().trim();

            // If we don't have enough text, skip
            if (cleanText.length < 50) continue;

            const prompt = `You are a concise tech news summarizer. Write a dense, engaging 3-sentence summary of the following tech news article. Do not use conversational filler, just give the summary directly. \n\nTITLE: ${article.title}\nCONTENT: ${cleanText.substring(0, 3000)}`;

            console.log(`[NewsWorker] Summarizing: ${article.title}`);

            try {
                // We force it to use a very fast/free model if available via OpenRouter inside generateContent
                // Or it will just use the standard configured primary model (Groq)
                const summary = await generateContent(prompt);

                // Attempt to find an image in the content
                let imageUrl = '';
                if (article['content:encoded']) {
                    const $ = cheerio.load(article['content:encoded'] as string);
                    imageUrl = $('img').first().attr('src') || '';
                }

                // Insert into Supabase
                await supabase.from('ai_news_feed').insert({
                    title: article.title,
                    url: article.link,
                    summary: summary,
                    image_url: imageUrl,
                    published_at: article.pubDate ? new Date(article.pubDate).toISOString() : new Date().toISOString()
                });

                console.log(`[NewsWorker] Successfully saved: ${article.title}`);

                // Brief pause to respect API rate limits
                await new Promise(res => setTimeout(res, 2000));

            } catch (err) {
                console.error(`[NewsWorker] Failed to summarize article:`, err);
            }
        }
    } catch (error) {
        console.error('[NewsWorker] Fatal error during cycle:', error);
    }

    console.log('[NewsWorker] Cycle complete.');
}

// Export a function to initialize the cron job
export function initNewsWorker() {
    console.log('[NewsWorker] Initialized - Job scheduled every 1 hour.');
    // Run once immediately on startup for testing/population
    fetchAndSummarizeNews();

    // Schedule to run exactly every 1 hour
    cron.schedule('0 * * * *', () => {
        fetchAndSummarizeNews();
    });
}
