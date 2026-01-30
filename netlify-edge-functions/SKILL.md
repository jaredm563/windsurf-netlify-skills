---
name: netlify-edge-functions
description: Create and deploy Netlify Edge Functions for ultra-low latency responses at the edge. Use for personalization, A/B testing, authentication, request/response transformation, and geolocation-based logic.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify Edge Functions

Netlify Edge Functions run on Deno at the edge, closer to users for ultra-low latency. They're ideal for request/response modification, personalization, and lightweight server-side logic.

## When to Use

- Low-latency personalization and A/B testing
- Authentication and authorization checks
- Request/response header manipulation
- Geolocation-based routing or content
- HTML rewriting and injection
- Middleware-style request processing
- Bot detection and rate limiting

## Edge Functions vs Serverless Functions

| Feature | Edge Functions | Serverless Functions |
|---------|---------------|---------------------|
| Location | Global edge network | Single region |
| Timeout | 50ms CPU time | 10s (26s paid) |
| Cold start | Very fast | Can be slow |
| Runtime | Deno | Node.js |
| Use case | Low-latency, lightweight | Heavy computation |
| Middleware | Yes (context.next()) | No |

## Directory Structure

```
project/
├── netlify/
│   └── edge-functions/
│       ├── auth.ts              # Authentication middleware
│       ├── geo.ts               # Geolocation routing
│       └── transform.ts         # Response transformation
├── netlify.toml
└── package.json
```

## Installation

```bash
npm install @netlify/edge-functions
```

## Basic Edge Function

```typescript
// netlify/edge-functions/hello.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const name = new URL(req.url).searchParams.get("name") || "World";
  
  return new Response(JSON.stringify({ 
    message: `Hello from the edge, ${name}!`,
    location: context.geo.city,
  }), {
    headers: { "Content-Type": "application/json" },
  });
};

export const config: Config = {
  path: "/api/hello",
};
```

## Geolocation-Based Logic

```typescript
// netlify/edge-functions/geo.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const { country, city, subdivision } = context.geo;
  
  // Redirect based on country
  if (country?.code === "GB") {
    return Response.redirect("https://uk.example.com");
  }
  
  // Personalize content
  return new Response(JSON.stringify({
    greeting: `Hello from ${city}, ${subdivision?.name}!`,
    country: country?.name,
    timezone: context.geo.timezone,
  }), {
    headers: { "Content-Type": "application/json" },
  });
};

export const config: Config = {
  path: "/geo",
};
```

## Middleware Pattern with context.next()

```typescript
// netlify/edge-functions/auth.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const authHeader = req.headers.get("Authorization");
  
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response("Unauthorized", { status: 401 });
  }
  
  const token = authHeader.substring(7);
  const isValid = await verifyToken(token);
  
  if (!isValid) {
    return new Response("Invalid token", { status: 401 });
  }
  
  // Continue to next handler or origin
  return context.next();
};

export const config: Config = {
  path: "/dashboard/*",
};
```

## HTML Rewriting

```typescript
// netlify/edge-functions/inject-banner.ts
import type { Context, Config } from "@netlify/edge-functions";
import { HTMLRewriter } from "https://ghuc.cc/worker-tools/html-rewriter/index.ts";

export default async (req: Request, context: Context) => {
  const response = await context.next();
  
  // Only process HTML responses
  const contentType = response.headers.get("content-type");
  if (!contentType?.includes("text/html")) {
    return response;
  }
  
  const banner = `
    <div style="background: #f0f0f0; padding: 1rem; text-align: center;">
      🎉 Special offer for visitors from ${context.geo.city}!
    </div>
  `;
  
  return new HTMLRewriter()
    .on("body", {
      element(element) {
        element.prepend(banner, { html: true });
      },
    })
    .transform(response);
};

export const config: Config = {
  path: "/*",
  excludedPath: ["/admin/*", "/api/*"],
};
```

## A/B Testing

```typescript
// netlify/edge-functions/ab-test.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const url = new URL(req.url);
  
  // Check for existing variant cookie
  let variant = context.cookies.get("ab_variant");
  
  if (!variant) {
    // Assign random variant
    variant = Math.random() < 0.5 ? "A" : "B";
    context.cookies.set({
      name: "ab_variant",
      value: variant,
      path: "/",
      httpOnly: true,
      secure: true,
      sameSite: "Lax",
    });
  }
  
  // Rewrite to variant-specific path
  if (variant === "B") {
    url.pathname = `/variants/b${url.pathname}`;
    return context.rewrite(url);
  }
  
  return context.next();
};

export const config: Config = {
  path: "/landing/*",
};
```

## Request Transformation

```typescript
// netlify/edge-functions/add-headers.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  // Add custom headers to request
  const modifiedRequest = new Request(req, {
    headers: {
      ...Object.fromEntries(req.headers),
      "X-User-Country": context.geo.country?.code || "unknown",
      "X-User-IP": context.ip,
      "X-Request-ID": context.requestId,
    },
  });
  
  // Forward modified request
  return context.next({ request: modifiedRequest });
};

export const config: Config = {
  path: "/api/*",
};
```

## Response Transformation

```typescript
// netlify/edge-functions/add-security-headers.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const response = await context.next();
  
  // Clone response and add security headers
  const headers = new Headers(response.headers);
  headers.set("X-Frame-Options", "DENY");
  headers.set("X-Content-Type-Options", "nosniff");
  headers.set("Referrer-Policy", "strict-origin-when-cross-origin");
  headers.set("Permissions-Policy", "geolocation=(), microphone=()");
  
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
};

export const config: Config = {
  path: "/*",
};
```

## Context Object Properties

```typescript
export default async (req: Request, context: Context) => {
  // Geolocation
  context.geo.city;              // "San Francisco"
  context.geo.country.code;      // "US"
  context.geo.country.name;      // "United States"
  context.geo.subdivision.code;  // "CA"
  context.geo.subdivision.name;  // "California"
  context.geo.latitude;          // 37.7749
  context.geo.longitude;         // -122.4194
  context.geo.timezone;          // "America/Los_Angeles"
  
  // Request info
  context.ip;                    // Client IP
  context.requestId;             // Unique request ID
  
  // Site/deploy info
  context.site.id;               // Site ID
  context.site.name;             // Site name
  context.site.url;              // Site URL
  context.deploy.id;             // Deploy ID
  context.deploy.context;        // "production" | "deploy-preview" | "branch-deploy"
  
  // Cookies
  context.cookies.get("session");
  context.cookies.set({ name: "session", value: "abc123" });
  context.cookies.delete("old_session");
  
  // Environment variables
  context.env.get("API_KEY");
  
  // Continue request chain
  context.next();                // Continue to next handler
  context.next({ sendConditionalRequest: true }); // With conditional request
  
  // Rewrite (internal redirect)
  context.rewrite(new URL("/other-path", req.url));
  
  // JSON helper
  context.json({ data: "value" }); // Returns Response with JSON
};
```

## In-Code Configuration

```typescript
export const config: Config = {
  // Path pattern (URLPattern syntax)
  path: "/api/*",
  
  // Exclude specific paths
  excludedPath: "/api/public/*",
  
  // HTTP methods to match
  method: ["POST", "PUT"],
  
  // Error handling
  onError: "bypass", // "bypass" | "fail"
  
  // Manual caching
  cache: "manual",
};
```

**Path patterns**:
- `/api/*` - Wildcard
- `/users/:id` - Path parameter
- `["/v1/*", "/v2/*"]` - Multiple paths
- URLPattern syntax supported

## netlify.toml Configuration

Use when you need precise execution order:

```toml
[[edge_functions]]
  path = "/admin/*"
  function = "auth"

[[edge_functions]]
  path = "/admin/*"
  function = "logger"

[[edge_functions]]
  path = "/*"
  excludedPath = "/public/*"
  function = "security-headers"

# Cached functions run last
[[edge_functions]]
  path = "/api/*"
  function = "cache"
  cache = "manual"
```

**Execution order**:
1. `netlify.toml` functions run first (top to bottom)
2. Framework-generated functions
3. Non-cached before cached
4. Inline-declared functions run alphabetically

## Import Maps

For third-party modules, use import maps:

```json
// import_map.json
{
  "imports": {
    "html-rewriter": "https://ghuc.cc/worker-tools/html-rewriter/index.ts",
    "jwt": "https://deno.land/x/djwt@v2.8/mod.ts"
  }
}
```

Configure in `netlify.toml`:

```toml
[functions]
  deno_import_map = "./import_map.json"
```

Use in code:

```typescript
import { HTMLRewriter } from "html-rewriter";
import { create, verify } from "jwt";
```

## Available Web APIs

Edge functions support standard Web APIs:

- **Fetch API**: `fetch`, `Request`, `Response`, `Headers`, `URL`
- **Encoding**: `TextEncoder`, `TextDecoder`, `atob`, `btoa`
- **Crypto**: `crypto.randomUUID()`, `crypto.getRandomValues()`, `crypto.subtle`
- **Streams**: `ReadableStream`, `WritableStream`, `TransformStream`
- **WebSocket**: `WebSocket` API
- **Timers**: `setTimeout`, `setInterval`, `clearTimeout`, `clearInterval`
- **URLPattern**: For advanced path matching
- **Performance**: `performance.now()`

## Node.js Built-in Modules

Use with `node:` prefix:

```typescript
import { randomBytes } from "node:crypto";
import { Buffer } from "node:buffer";

export default async (req: Request, context: Context) => {
  const token = randomBytes(32).toString("hex");
  return Response.json({ token });
};
```

## npm Packages (Beta)

Install and import npm packages:

```bash
npm install lodash
```

```typescript
import _ from "lodash";

export default async (req: Request, context: Context) => {
  const data = _.chunk([1, 2, 3, 4], 2);
  return Response.json(data);
};
```

**Note**: Some packages with native binaries or dynamic imports may not work.

## Environment Variables

```typescript
export default async (req: Request, context: Context) => {
  // Preferred method
  const apiKey = Netlify.env.get("API_KEY");
  
  // Alternative
  const secret = context.env.get("SECRET");
  
  return Response.json({ configured: !!apiKey });
};
```

## Caching Responses

```typescript
// netlify/edge-functions/cache.ts
import type { Context, Config } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  const url = new URL(req.url);
  const cacheKey = url.pathname;
  
  // Try cache first
  const cache = await caches.open("edge-cache");
  const cached = await cache.match(req);
  
  if (cached) {
    return new Response(cached.body, {
      ...cached,
      headers: {
        ...Object.fromEntries(cached.headers),
        "X-Cache": "HIT",
      },
    });
  }
  
  // Generate response
  const response = await context.next();
  
  // Cache for 5 minutes
  const cacheResponse = new Response(response.body, {
    ...response,
    headers: {
      ...Object.fromEntries(response.headers),
      "Cache-Control": "public, max-age=300",
    },
  });
  
  await cache.put(req, cacheResponse.clone());
  
  return new Response(cacheResponse.body, {
    ...cacheResponse,
    headers: {
      ...Object.fromEntries(cacheResponse.headers),
      "X-Cache": "MISS",
    },
  });
};

export const config: Config = {
  path: "/api/*",
  cache: "manual",
};
```

## Local Development

```bash
# Run with Netlify Dev
netlify dev

# Edge functions available at configured paths
# Logs show in terminal
```

## Common Patterns

### Bot Detection

```typescript
export default async (req: Request, context: Context) => {
  const userAgent = req.headers.get("user-agent") || "";
  
  const botPatterns = [
    /bot/i,
    /crawler/i,
    /spider/i,
    /scraper/i,
  ];
  
  const isBot = botPatterns.some(pattern => pattern.test(userAgent));
  
  if (isBot) {
    return new Response("Forbidden", { status: 403 });
  }
  
  return context.next();
};
```

### Rate Limiting

```typescript
import { getStore } from "@netlify/blobs";

const rateLimits = getStore({ name: "edge-rate-limits", consistency: "strong" });

export default async (req: Request, context: Context) => {
  const ip = context.ip;
  const key = `rate:${ip}`;
  const now = Date.now();
  
  const current = await rateLimits.get(key, { type: "json" }) as {
    count: number;
    resetAt: number;
  } | null;
  
  if (current && current.resetAt > now && current.count >= 100) {
    return new Response("Rate limit exceeded", { 
      status: 429,
      headers: {
        "Retry-After": String(Math.ceil((current.resetAt - now) / 1000)),
      },
    });
  }
  
  await rateLimits.setJSON(key, {
    count: (current?.count || 0) + 1,
    resetAt: current?.resetAt > now ? current.resetAt : now + 60000,
  });
  
  return context.next();
};
```

### Feature Flags

```typescript
export default async (req: Request, context: Context) => {
  const featureEnabled = Netlify.env.get("FEATURE_NEW_UI") === "true";
  
  if (featureEnabled) {
    const url = new URL(req.url);
    url.pathname = `/new-ui${url.pathname}`;
    return context.rewrite(url);
  }
  
  return context.next();
};
```

## Limitations

- **CPU time**: 50ms per request
- **Code size**: 20MB compressed per deployment
- **Memory**: 512MB per deployment
- **Response timeout**: 40 seconds for headers
- **Not compatible with**:
  - Netlify split testing
  - Custom headers from `_headers` or `netlify.toml` on same path
  - Netlify prerendering on same path
- **Restrictions**:
  - Can only rewrite to same-site URLs
  - Cached functions override static files
  - No local caching in development

## Best Practices

1. **Keep functions lightweight** - 50ms CPU limit
2. **Use context.next()** for middleware patterns
3. **Cache responses** when appropriate with `cache: "manual"`
4. **Check content-type** before transforming responses
5. **Use geolocation** for personalization
6. **Handle errors gracefully** with `onError` config
7. **Test locally** with `netlify dev`
8. **Monitor performance** - edge functions should be fast
9. **Use import maps** for third-party dependencies
10. **Avoid heavy computation** - use serverless functions instead
