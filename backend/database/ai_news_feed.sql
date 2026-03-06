-- Run this in your Supabase SQL Editor
CREATE TABLE public.ai_news_feed (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    url TEXT NOT NULL UNIQUE,
    image_url TEXT,
    summary TEXT NOT NULL,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Basic index for fast ordering by publish date
CREATE INDEX idx_ai_news_feed_published_at ON public.ai_news_feed(published_at DESC);