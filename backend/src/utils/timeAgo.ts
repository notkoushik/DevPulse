/**
 * Shared utility to format dates as relative time strings (e.g., "2h ago")
 * Used across multiple routes to avoid duplication
 */

/**
 * Format a Date object as a relative time string
 */
export function timeAgo(date: Date): string {
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  return `${weeks}w ago`;
}

/**
 * Format a Unix timestamp (seconds) as a relative time string
 */
export function timeAgoFromUnix(unixSeconds: number): string {
  return timeAgo(new Date(unixSeconds * 1000));
}

/**
 * Format a Date string (ISO 8601 or similar) as a relative time string
 */
export function timeAgoFromString(dateStr: string): string {
  return timeAgo(new Date(dateStr));
}
