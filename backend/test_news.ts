import axios from 'axios';

async function testFetchHackerNews() {
    try {
        const { data: ids } = await axios.get('https://hacker-news.firebaseio.com/v0/topstories.json', { timeout: 8000 });
        const top5 = ids.slice(0, 5);
        const stories = await Promise.all(
            top5.map((id: any) =>
                axios.get(`https://hacker-news.firebaseio.com/v0/item/${id}.json`, { timeout: 5000 })
                    .then(r => r.data)
                    .catch(() => null)
            )
        );
        console.log('HackerNews returned', stories.length, 'items');
    } catch (e: any) {
        console.error('HackerNews error:', e.message);
    }
}

async function testFetchDevTo() {
    try {
        const { data: articles } = await axios.get('https://dev.to/api/articles?per_page=5&top=7', { timeout: 8000 });
        console.log('Dev.to returned', articles.length, 'items');
    } catch (e: any) {
        console.error('Dev.to error:', e.message);
    }
}

async function testFetchReddit() {
    try {
        const { data } = await axios.get('https://www.reddit.com/r/programming/hot.json?limit=5', {
            timeout: 8000,
            headers: { 'User-Agent': 'DevPulse/1.0 (developer-dashboard)' },
        });
        console.log('Reddit returned', data.data.children.length, 'items');
    } catch (e: any) {
        console.error('Reddit error:', e.message);
    }
}

async function runAll() {
    await testFetchHackerNews();
    await testFetchDevTo();
    await testFetchReddit();
}

runAll();
