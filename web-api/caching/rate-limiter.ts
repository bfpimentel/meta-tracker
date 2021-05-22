import type { NextApiResponse } from "next";
import LRU from "lru-cache";

const createRateLimiter = (interval: number = 60000, uniqueTokenPerInterval: number = 500) => {
  const tokenCache = new LRU({
    max: uniqueTokenPerInterval,
    maxAge: interval
  });

  return {
    check: (response: NextApiResponse, limit: number, token: string) =>
      new Promise<void>((resolve, reject) => {
        const tokenCount = tokenCache.get(token) || [0];
        if (tokenCount[0] === 0) {
          tokenCache.set(token, tokenCount);
        }
        tokenCount[0] += 1;

        const currentUsage = tokenCount[0];
        const isRateLimited = currentUsage >= limit;
        response.setHeader("X-RateLimit-Limit", limit);
        response.setHeader("X-RateLimit-Remaining", isRateLimited ? 0 : limit - currentUsage);

        return isRateLimited ? reject() : resolve();
      })
  };
};

export default createRateLimiter;
