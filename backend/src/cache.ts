/**
 * Simple in-memory cache with TTL + LRU eviction support.
 * Prevents hammering external APIs on every Flutter request.
 * maxEntries cap prevents unbounded memory growth under load.
 */

interface CacheEntry<T> {
    data: T;
    expiry: number;
}

export class SimpleCache {
    private store: Map<string, CacheEntry<any>> = new Map();
    private defaultTTL: number;
    private maxEntries: number;

    constructor(defaultTTLSeconds: number = 900, maxEntries: number = 500) {
        // Default: 15 minutes TTL, 500 max entries
        this.defaultTTL = defaultTTLSeconds * 1000;
        this.maxEntries = maxEntries;
    }

    get<T>(key: string): T | null {
        const entry = this.store.get(key);
        if (!entry) return null;
        if (Date.now() > entry.expiry) {
            this.store.delete(key);
            return null;
        }
        return entry.data as T;
    }

    set<T>(key: string, data: T, ttlSeconds?: number): void {
        const ttl = (ttlSeconds ?? this.defaultTTL / 1000) * 1000;

        // LRU eviction: if at capacity, remove the oldest entry
        // Map iterates in insertion order, so the first key is the oldest
        if (this.store.size >= this.maxEntries && !this.store.has(key)) {
            const oldestKey = this.store.keys().next().value;
            if (oldestKey !== undefined) {
                this.store.delete(oldestKey);
            }
        }

        this.store.set(key, {
            data,
            expiry: Date.now() + ttl,
        });
    }

    invalidate(key: string): void {
        this.store.delete(key);
    }

    clear(): void {
        this.store.clear();
    }

    /** Returns the current number of entries (for monitoring/testing) */
    get size(): number {
        return this.store.size;
    }
}

export const cache = new SimpleCache(900, 500); // 15 min TTL, max 500 entries
