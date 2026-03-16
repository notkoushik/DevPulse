import { SimpleCache } from '../cache';

describe('SimpleCache', () => {
  let cache: SimpleCache;

  beforeEach(() => {
    // Reset cache before each test (default TTL 900s, max 5 entries for easy testing)
    cache = new SimpleCache(900, 5);
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should store and retrieve data', () => {
    cache.set('key1', 'value1');
    expect(cache.get('key1')).toBe('value1');
  });

  it('should return null for missing keys', () => {
    expect(cache.get('nonexistent')).toBeNull();
  });

  it('should expire data after TTL', () => {
    cache.set('key1', 'value1', 1); // 1 second TTL
    expect(cache.get('key1')).toBe('value1');

    // Fast-forward time by 1.1 seconds
    jest.advanceTimersByTime(1100);

    expect(cache.get('key1')).toBeNull();
  });

  it('should invalidate specific keys', () => {
    cache.set('key1', 'value1');
    cache.set('key2', 'value2');
    
    cache.invalidate('key1');
    
    expect(cache.get('key1')).toBeNull();
    expect(cache.get('key2')).toBe('value2');
  });

  it('should clear all data', () => {
    cache.set('key1', 'value1');
    cache.set('key2', 'value2');
    
    cache.clear();
    
    expect(cache.get('key1')).toBeNull();
    expect(cache.get('key2')).toBeNull();
    expect(cache.size).toBe(0);
  });

  it('should evict the oldest entry when maxEntries is exceeded (LRU)', () => {
    // Fill the cache to max limit (5)
    cache.set('1', 'a');
    cache.set('2', 'b');
    cache.set('3', 'c');
    cache.set('4', 'd');
    cache.set('5', 'e');

    expect(cache.size).toBe(5);
    expect(cache.get('1')).toBe('a'); // 1 is oldest

    // Add 6th item, should evict '1'
    cache.set('6', 'f');
    
    expect(cache.size).toBe(5);
    expect(cache.get('1')).toBeNull(); // Evicted
    expect(cache.get('2')).toBe('b'); // Now 2 is oldest
    expect(cache.get('6')).toBe('f'); // Newly added

    // Updating an existing key shouldn't evict
    cache.set('3', 'updated');
    expect(cache.size).toBe(5);
    expect(cache.get('2')).toBe('b'); // 2 is still there
  });
});
