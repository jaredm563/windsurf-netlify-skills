---
name: netlify-blobs
description: Store and retrieve unstructured data using Netlify Blobs key-value storage. Use for file uploads, caching, user-generated content, session storage, or any binary/JSON data persistence on Netlify.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify Blobs

Netlify Blobs is a built-in key-value store for unstructured data. It's ideal for storing files, JSON, or any binary data without setting up external storage.

## When to Use

- Storing user uploads (images, files, documents)
- Caching API responses or computed data
- Session or state storage
- Persisting background function results
- Deploy-specific data storage
- Rate limiting counters
- Feature flag state

## Installation

```bash
npm install @netlify/blobs
```

**Local development**: If using Vite-based frameworks, install `@netlify/vite-plugin` to automatically configure local environment. For Nuxt, use `@netlify/nuxt` module instead.

## Basic Usage

### Writing Data

```typescript
import { getStore } from "@netlify/blobs";

// Get a store reference (global scope)
const store = getStore("my-store");

// Store a string
await store.set("greeting", "Hello, World!");

// Store JSON (automatically serialized)
await store.setJSON("user", { 
  id: 1, 
  name: "Alice",
  email: "alice@example.com" 
});

// Store binary data (Buffer, ArrayBuffer, Blob)
await store.set("image", imageBuffer);
```

### Reading Data

```typescript
import { getStore } from "@netlify/blobs";

const store = getStore("my-store");

// Get as string (default)
const greeting = await store.get("greeting");
// → "Hello, World!"

// Get as JSON (automatically parsed)
const user = await store.get("user", { type: "json" });
// → { id: 1, name: "Alice", email: "alice@example.com" }

// Get as ArrayBuffer
const imageData = await store.get("image", { type: "arrayBuffer" });

// Get as Blob
const blob = await store.get("image", { type: "blob" });

// Get as Stream
const stream = await store.get("image", { type: "stream" });

// Returns null if key doesn't exist
const missing = await store.get("nonexistent");
// → null
```

### Deleting Data

```typescript
const store = getStore("my-store");

// Delete a single key
await store.delete("old-data");

// Always resolves to undefined, even if key doesn't exist
```

### Listing Keys

```typescript
const store = getStore("my-store");

// List all keys
const { blobs } = await store.list();
for (const blob of blobs) {
  console.log(blob.key, blob.etag);
}

// List with prefix filter
const { blobs: userBlobs } = await store.list({ prefix: "users/" });

// List with directory structure
const { blobs, directories } = await store.list({ 
  prefix: "uploads/",
  directories: true 
});

// Paginate through results
for await (const { blobs } of store.list({ paginate: true })) {
  for (const blob of blobs) {
    console.log(blob.key);
  }
}
```

## Storing Files with Metadata

```typescript
const store = getStore("uploads");

// Store file with metadata
await store.set("profile-123.jpg", imageBuffer, {
  metadata: {
    contentType: "image/jpeg",
    uploadedBy: "user-123",
    originalName: "my-photo.jpg",
    uploadedAt: new Date().toISOString(),
  },
});

// Retrieve with metadata
const { data, metadata, etag } = await store.getWithMetadata("profile-123.jpg", {
  type: "arrayBuffer",
});

console.log(metadata.contentType); // "image/jpeg"
console.log(metadata.uploadedBy);  // "user-123"

// Get only metadata (no data download)
const { metadata, etag } = await store.getMetadata("profile-123.jpg");
```

## Consistency Modes

### Eventual Consistency (Default)

Data is cached at the edge for fast reads. Updates propagate within 60 seconds.

```typescript
const store = getStore("my-store");
// Uses eventual consistency by default
```

### Strong Consistency

For when you need immediate read-after-write consistency:

```typescript
// Store-level strong consistency
const store = getStore({
  name: "my-store",
  consistency: "strong",
});

await store.set("counter", "1");
const value = await store.get("counter"); // Immediately sees "1"
```

**Use strong consistency when**:
- Reading immediately after writing
- Handling transactions or counters
- Data correctness is critical
- Implementing rate limiting

**Trade-off**: Strong consistency is slower than eventual consistency.

## Deploy-Scoped vs Global Stores

### Global Stores (Default)

Data persists across all deploys and branches:

```typescript
import { getStore } from "@netlify/blobs";

// Global store - shared across all deploys
const store = getStore("uploads");

await store.set("logo.png", logoBuffer);
```

**Important**: Isolate production from non-production data:

```typescript
import { getStore, getDeployStore } from "@netlify/blobs";

function getBlobStore(name: string) {
  // Use global store only in production
  if (Netlify.env.get("CONTEXT") === "production") {
    return getStore(name);
  }
  
  // Use deploy-scoped store for previews/branches
  return getDeployStore(name);
}

const store = getBlobStore("user-uploads");
```

### Deploy-Scoped Stores

Data tied to a specific deploy (cleaned up with deploy):

```typescript
import { getDeployStore } from "@netlify/blobs";

// This store is scoped to the current deploy
const store = getDeployStore("build-cache");

// Data is automatically cleaned up when deploy is deleted
await store.set("compiled-assets", compiledData);
```

**Use deploy stores for**:
- Build-time caching
- Deploy-specific temporary data
- Preview/branch-specific data

## Using in Serverless Functions

```typescript
// netlify/functions/upload.mts
import { getStore } from "@netlify/blobs";
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const store = getStore("uploads");
  
  if (req.method === "POST") {
    const formData = await req.formData();
    const file = formData.get("file") as File;
    
    if (!file) {
      return Response.json({ error: "No file provided" }, { status: 400 });
    }
    
    const key = `${Date.now()}-${file.name}`;
    const buffer = await file.arrayBuffer();
    
    await store.set(key, buffer, {
      metadata: {
        contentType: file.type,
        originalName: file.name,
        size: file.size.toString(),
        uploadedAt: new Date().toISOString(),
      },
    });
    
    return Response.json({ key, message: "Upload successful" });
  }
  
  if (req.method === "GET") {
    const url = new URL(req.url);
    const key = url.searchParams.get("key");
    
    if (!key) {
      return Response.json({ error: "Key required" }, { status: 400 });
    }
    
    const { data, metadata } = await store.getWithMetadata(key, {
      type: "arrayBuffer",
    });
    
    if (!data) {
      return new Response("Not found", { status: 404 });
    }
    
    return new Response(data, {
      headers: {
        "Content-Type": metadata?.contentType || "application/octet-stream",
        "Content-Disposition": `attachment; filename="${metadata?.originalName}"`,
      },
    });
  }
  
  return new Response("Method not allowed", { status: 405 });
};

export const config = {
  path: "/api/files",
};
```

## Using in Edge Functions

```typescript
// netlify/edge-functions/cache.ts
import { getStore } from "@netlify/blobs";
import type { Context } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const url = new URL(req.url);
  const cacheKey = `page-cache:${url.pathname}`;
  
  const store = getStore("page-cache");
  
  // Try to get from cache
  const cached = await store.get(cacheKey, { type: "json" });
  
  if (cached && cached.expires > Date.now()) {
    return new Response(cached.html, {
      headers: { 
        "Content-Type": "text/html",
        "X-Cache": "HIT",
      },
    });
  }
  
  // Get fresh content
  const response = await context.next();
  const html = await response.text();
  
  // Cache for 5 minutes
  await store.setJSON(cacheKey, {
    html,
    expires: Date.now() + 5 * 60 * 1000,
  });
  
  return new Response(html, {
    headers: { 
      "Content-Type": "text/html",
      "X-Cache": "MISS",
    },
  });
};

export const config = {
  path: "/*",
  excludedPath: ["/admin/*", "/api/*"],
};
```

## File-Based Uploads (Build Time)

Place files in `.netlify/blobs/deploy/` during build for deploy-scoped storage:

```
project/
├── .netlify/
│   └── blobs/
│       └── deploy/
│           ├── assets/
│           │   └── logo.png
│           ├── $assets/logo.png.json  # Metadata file
│           └── config.json
```

Metadata file example (`$assets/logo.png.json`):
```json
{
  "contentType": "image/png",
  "uploadedAt": "2024-01-15T10:00:00Z"
}
```

**Note**: File-based uploads are always deploy-scoped.

## Common Patterns

### Rate Limiting

```typescript
import { getStore } from "@netlify/blobs";

const rateLimits = getStore({ name: "rate-limits", consistency: "strong" });

async function checkRateLimit(ip: string, limit: number, windowMs: number) {
  const key = `rate:${ip}`;
  const now = Date.now();
  
  const data = await rateLimits.get(key, { type: "json" }) as {
    count: number;
    resetAt: number;
  } | null;
  
  if (!data || data.resetAt < now) {
    await rateLimits.setJSON(key, { count: 1, resetAt: now + windowMs });
    return { allowed: true, remaining: limit - 1 };
  }
  
  if (data.count >= limit) {
    return { 
      allowed: false, 
      remaining: 0, 
      resetAt: data.resetAt 
    };
  }
  
  await rateLimits.setJSON(key, { 
    count: data.count + 1, 
    resetAt: data.resetAt 
  });
  
  return { allowed: true, remaining: limit - data.count - 1 };
}

// Usage in function
export default async (req: Request, context: Context) => {
  const rateLimit = await checkRateLimit(context.ip, 100, 60000);
  
  if (!rateLimit.allowed) {
    return Response.json(
      { error: "Rate limit exceeded" },
      { 
        status: 429,
        headers: {
          "X-RateLimit-Remaining": "0",
          "Retry-After": String(Math.ceil((rateLimit.resetAt - Date.now()) / 1000)),
        },
      }
    );
  }
  
  // Continue with request...
  return Response.json({ success: true });
};
```

### Session Storage

```typescript
import { getStore } from "@netlify/blobs";

const sessions = getStore({ name: "sessions", consistency: "strong" });

async function createSession(userId: string) {
  const sessionId = crypto.randomUUID();
  
  await sessions.setJSON(`session:${sessionId}`, {
    userId,
    createdAt: Date.now(),
    expiresAt: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
  });
  
  return sessionId;
}

async function getSession(sessionId: string) {
  const session = await sessions.get(`session:${sessionId}`, { type: "json" });
  
  if (!session || session.expiresAt < Date.now()) {
    return null;
  }
  
  return session;
}

async function deleteSession(sessionId: string) {
  await sessions.delete(`session:${sessionId}`);
}
```

### Background Job Results

```typescript
// Background function writes result
// netlify/functions/process-background.mts
import { getStore } from "@netlify/blobs";
import type { Context } from "@netlify/functions";

const jobResults = getStore("job-results");

export default async (req: Request, context: Context) => {
  const { jobId, data } = await req.json();
  
  await jobResults.setJSON(`job:${jobId}:status`, { status: "processing" });
  
  try {
    // Do long-running work...
    const result = await processData(data);
    
    await jobResults.setJSON(`job:${jobId}:status`, { 
      status: "complete",
      result,
      completedAt: new Date().toISOString(),
    });
  } catch (error) {
    await jobResults.setJSON(`job:${jobId}:status`, { 
      status: "failed",
      error: error.message,
      failedAt: new Date().toISOString(),
    });
  }
};

// Regular function checks status
// netlify/functions/job-status.mts
export default async (req: Request, context: Context) => {
  const url = new URL(req.url);
  const jobId = url.searchParams.get("id");
  
  if (!jobId) {
    return Response.json({ error: "Job ID required" }, { status: 400 });
  }
  
  const store = getStore("job-results");
  const status = await store.get(`job:${jobId}:status`, { type: "json" });
  
  return Response.json(status || { status: "not-found" });
};
```

### Caching API Responses

```typescript
import { getStore } from "@netlify/blobs";

const apiCache = getStore("api-cache");

async function fetchWithCache(url: string, ttlMs: number = 300000) {
  const cacheKey = `cache:${url}`;
  
  // Check cache
  const cached = await apiCache.get(cacheKey, { type: "json" });
  
  if (cached && cached.expires > Date.now()) {
    return cached.data;
  }
  
  // Fetch fresh data
  const response = await fetch(url);
  const data = await response.json();
  
  // Store in cache
  await apiCache.setJSON(cacheKey, {
    data,
    expires: Date.now() + ttlMs,
  });
  
  return data;
}
```

### User-Generated Content

```typescript
import { getStore } from "@netlify/blobs";

const userContent = getStore("user-content");

export default async (req: Request, context: Context) => {
  const userId = context.cookies.get("user_id");
  
  if (!userId) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  if (req.method === "POST") {
    const { content } = await req.json();
    const postId = crypto.randomUUID();
    
    await userContent.setJSON(`posts:${userId}:${postId}`, {
      content,
      createdAt: new Date().toISOString(),
      userId,
    });
    
    return Response.json({ postId });
  }
  
  if (req.method === "GET") {
    // List user's posts
    const { blobs } = await userContent.list({ prefix: `posts:${userId}:` });
    
    const posts = await Promise.all(
      blobs.map(async ({ key }) => {
        const post = await userContent.get(key, { type: "json" });
        return { id: key.split(":")[2], ...post };
      })
    );
    
    return Response.json({ posts });
  }
  
  return new Response("Method not allowed", { status: 405 });
};
```

## Listing Stores

```typescript
import { listStores } from "@netlify/blobs";

// List all stores
const { stores } = await listStores();
console.log(stores); // ["uploads", "cache", "sessions"]

// Paginate through stores
for await (const { stores } of listStores({ paginate: true })) {
  console.log(stores);
}
```

## ETags and Conditional Requests

```typescript
const store = getStore("my-store");

// Get with ETag
const { data, etag } = await store.getWithMetadata("key");

// Only fetch if ETag changed
const updated = await store.getWithMetadata("key", { etag });

if (updated === null) {
  console.log("Data hasn't changed");
} else {
  console.log("Data was updated:", updated.data);
}
```

## Limits

- **Key length**: 600 bytes max
- **Value size**: 5GB max per blob
- **Metadata**: 64KB max per blob
- **Store names**: 64 bytes max, alphanumeric with hyphens/underscores
- **Consistency**: Eventual by default (60s propagation), strong available

## Best Practices

1. **Use strong consistency** for rate limiting, counters, and transactions
2. **Use eventual consistency** for caching and non-critical data (faster)
3. **Isolate production data** from preview/branch deploys
4. **Use deploy stores** for build-time caching
5. **Use global stores** for persistent user data
6. **Add metadata** for file uploads (content type, original name, etc.)
7. **Use prefixes** for logical grouping (e.g., `users:123:profile`)
8. **Paginate** when listing large numbers of blobs
9. **Handle null returns** - `get()` returns null if key doesn't exist
10. **Clean up old data** periodically with scheduled functions

## Troubleshooting

**Error: "Environment has not been configured to use Netlify Blobs"**
- Install `@netlify/vite-plugin` for Vite-based projects
- For Nuxt, use `@netlify/nuxt` module
- This configures local development environment automatically

**Data not persisting across deploys**
- Ensure you're using `getStore()` (global), not `getDeployStore()` (deploy-scoped)
- Check that you're not in a preview/branch deploy with isolated data

**Slow reads**
- Consider using eventual consistency (default) instead of strong
- Cache frequently accessed data in memory or edge functions

**Data not updating immediately**
- Use strong consistency if you need immediate read-after-write
- Eventual consistency can take up to 60 seconds to propagate
