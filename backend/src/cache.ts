/**
 * Simple in-memory cache with TTL support.
 * Prevents hammering external APIs on every Flutter request.
 */

interface CacheEntry<T> {
    data: T;
    expiry: number;
}

class SimpleCache {
    private store: Map<string, CacheEntry<any>> = new Map();
    private defaultTTL: number;

    constructor(defaultTTLSeconds: number = 900) {
        // Default: 15 minutes
        this.defaultTTL = defaultTTLSeconds * 1000;
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
}

export const cache = new SimpleCache(900); // 15 min default TTL
