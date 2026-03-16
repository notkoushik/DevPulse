import request from 'supertest';
import express from 'express';
import { newsRouter } from '../../routes/news';
import axios from 'axios';
import { cache } from '../../cache';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

const app = express();
app.use('/api/news', newsRouter);

describe('newsRouter', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        cache.clear();
    });

    describe('GET /feed', () => {
        it('should aggregate news from all sources', async () => {
            // Mock HN
            mockedAxios.get.mockImplementation(async (url: string) => {
                if (url.includes('hacker-news.firebaseio.com/v0/topstories.json')) {
                    return { data: [1] };
                }
                if (url.includes('hacker-news.firebaseio.com/v0/item/1.json')) {
                    return { data: { id: 1, title: 'HN Story', url: 'http://hn.com', score: 100, time: Date.now() / 1000 } };
                }
                if (url.includes('dev.to/api/articles')) {
                    return { data: [{ id: 1, title: 'Dev Article', url: 'http://dev.to', positive_reactions_count: 50, published_at: new Date().toISOString() }] };
                }
                if (url.includes('reddit.com/r/programming')) {
                    return { data: { data: { children: [{ data: { id: 'r1', title: 'Reddit Post', url_overridden_by_dest: 'http://reddit.com', score: 200, created_utc: Date.now() / 1000 } }] } } };
                }
                if (url.includes('reddit.com/r/webdev')) {
                    return { data: { data: { children: [] } } }; // empty to save space
                }
                return { data: {} };
            });

            const res = await request(app).get('/api/news/feed?source=all');

            expect(res.status).toBe(200);
            expect(res.body.items).toBeDefined();
            // Should contain from all sources based on the mocks
            expect(res.body.items.length).toBeGreaterThanOrEqual(3); // 1 HN, 1 Dev, 1 Reddit
            expect(res.body.items.some((i: any) => i.source === 'hackernews')).toBe(true);
            expect(res.body.items.some((i: any) => i.source === 'devto')).toBe(true);
            expect(res.body.items.some((i: any) => i.source === 'reddit')).toBe(true);
        });

        it('should fetch only hacker news if source=hackernews is specified', async () => {
            mockedAxios.get.mockImplementation(async (url: string) => {
                if (url.includes('hacker-news.firebaseio.com/v0/topstories.json')) {
                    return { data: [1] };
                }
                if (url.includes('hacker-news.firebaseio.com/v0/item/1.json')) {
                    return { data: { id: 1, title: 'HN Story', score: 100 } };
                }
                return Promise.reject(new Error('Unexpected URL'));
            });

            const res = await request(app).get('/api/news/feed?source=hackernews');

            expect(res.status).toBe(200);
            expect(res.body.items).toHaveLength(1);
            expect(res.body.items[0].source).toBe('hackernews');
        });

        it('should handle partial source failures (e.g. reddit down)', async () => {
            // Mock HN
            mockedAxios.get.mockImplementation(async (url: string) => {
                if (url.includes('hacker-news.firebaseio.com/v0/topstories.json')) {
                    return { data: [1] };
                }
                if (url.includes('hacker-news.firebaseio.com/v0/item/1.json')) {
                    return { data: { id: 1, title: 'HN Story' } };
                }
                if (url.includes('dev.to/api/articles')) {
                    return { data: [] };
                }
                if (url.includes('reddit.com')) {
                    throw new Error('Reddit API limit');
                }
                return { data: {} };
            });

            const res = await request(app).get('/api/news/feed?source=all');

            expect(res.status).toBe(200);
            // Reddit failed, but HN succeeded
            expect(res.body.items).toHaveLength(1);
            expect(res.body.items[0].source).toBe('hackernews');
        });
    });

    describe('GET /trending', () => {
        it('should return deduplicated GitHub trending repos properly ranked', async () => {
            mockedAxios.get.mockImplementation(async (url: string) => {
                // Mock Established Repos
                if (url.includes('stars:>500')) {
                    return {
                        data: {
                            items: [
                                {
                                    full_name: 'facebook/react',
                                    name: 'react',
                                    stargazers_count: 200000,
                                    language: 'JavaScript',
                                    created_at: '2013-05-24T00:00:00Z',
                                },
                                // Duplicate repository below
                                {
                                    full_name: 'duplicate/repo',
                                    name: 'repo',
                                    stargazers_count: 100,
                                    created_at: '2020-01-01T00:00:00Z',
                                }
                            ]
                        }
                    };
                }
                // Mock Rising Repos
                if (url.includes('stars:>50')) {
                    return {
                        data: {
                            items: [
                                {
                                    full_name: 'new/repo',
                                    name: 'repo',
                                    stargazers_count: 5000,
                                    language: 'Rust',
                                    created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(), // 2 days old
                                },
                                // Same duplicate repo
                                {
                                    full_name: 'duplicate/repo',
                                    name: 'repo',
                                    stargazers_count: 100,
                                    created_at: '2020-01-01T00:00:00Z',
                                }
                            ]
                        }
                    };
                }
                return { data: { items: [] } };
            });

            const res = await request(app).get('/api/news/trending');

            expect(res.status).toBe(200);
            expect(res.body.repos).toHaveLength(3); // Deduplicated from 4 items
            
            // new/repo has 5000 stars in 2 days -> ~2500 per day
            // facebook/react has 200k in 10 years -> ~54 per day
            // duplicate/repo has 100 in 3 years -> ~0 per day
            // Rank should be new/repo, facebook/react, duplicate/repo
            expect(res.body.repos[0].name).toBe('repo');
            expect(res.body.repos[0].language).toBe('Rust');
            expect(res.body.repos[1].name).toBe('react');
        });
    });
});
