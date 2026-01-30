---
name: netlify-serverless-functions
description: Create and deploy Netlify serverless functions (synchronous, background, and scheduled). Use for API endpoints, server-side logic, background jobs, scheduled tasks, and integrations on Netlify.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify Serverless Functions

Netlify serverless functions run on-demand using Node.js without managing servers. They support synchronous, background, and scheduled execution patterns.

## When to Use

- API endpoints for frontend applications
- Server-side data processing and validation
- Third-party API integrations (hiding API keys)
- Background/async processing (up to 15 minutes)
- Scheduled jobs (cron-like tasks)
- Database operations and mutations

## Directory Structure

```
project/
├── netlify/
│   └── functions/
│       ├── hello.mts              # → /.netlify/functions/hello
│       ├── api-users.mts          # → /.netlify/functions/api-users
│       ├── process-background.mts # Background function
│       └── daily-cleanup.mts      # Scheduled function
├── netlify.toml
└── package.json
```

**Important**: Use `.mts` extension for modern ES module syntax with TypeScript.

## Installation

```bash
npm install @netlify/functions
```

## Basic Serverless Function

```typescript
// netlify/functions/hello.mts
import type { Context, Config } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const url = new URL(req.url);
  const name = url.searchParams.get("name") || "World";
  
  return new Response(JSON.stringify({ 
    message: `Hello, ${name}!` 
  }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
};

export const config: Config = {
  path: "/api/hello",
};
```

**Default URL**: `/.netlify/functions/hello`  
**Custom path**: `/api/hello` (via config)

## Handling Different HTTP Methods

```typescript
// netlify/functions/items.mts
import type { Context, Config } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const { method } = req;
  
  switch (method) {
    case "GET":
      return handleGet(req, context);
    case "POST":
      return handlePost(req, context);
    case "PUT":
      return handlePut(req, context);
    case "DELETE":
      return handleDelete(req, context);
    default:
      return new Response("Method not allowed", { status: 405 });
  }
};

async function handleGet(req: Request, context: Context) {
  const items = await fetchItems();
  return Response.json(items);
}

async function handlePost(req: Request, context: Context) {
  const body = await req.json();
  const newItem = await createItem(body);
  return Response.json(newItem, { status: 201 });
}

async function handlePut(req: Request, context: Context) {
  const body = await req.json();
  const updatedItem = await updateItem(body);
  return Response.json(updatedItem);
}

async function handleDelete(req: Request, context: Context) {
  const url = new URL(req.url);
  const id = url.searchParams.get("id");
  await deleteItem(id);
  return new Response(null, { status: 204 });
}

export const config: Config = {
  path: "/api/items",
};
```

## Path Parameters

```typescript
// netlify/functions/users.mts
import type { Context, Config } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const { id } = context.params;
  
  const user = await getUser(id);
  
  if (!user) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return Response.json(user);
};

export const config: Config = {
  path: "/api/users/:id",
};
```

## Environment Variables

Access via `Netlify.env.get()` (preferred) or `process.env`:

```typescript
// netlify/functions/api.mts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const apiKey = Netlify.env.get("API_KEY");
  
  if (!apiKey) {
    return new Response("API key not configured", { status: 500 });
  }
  
  const response = await fetch("https://api.example.com/data", {
    headers: { Authorization: `Bearer ${apiKey}` },
  });
  
  const data = await response.json();
  return Response.json(data);
};

export const config = {
  path: "/api/external-data",
};
```

## Background Functions

For long-running tasks (up to 15 minutes):

```typescript
// netlify/functions/process-background.mts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const { data } = await req.json();
  
  // Client receives 202 immediately, this runs in background
  await processLargeDataset(data);
  await sendNotificationEmail(data.email);
  
  console.log("Background processing completed");
  
  // Return value is ignored - client always gets 202 Accepted
};
```

**Critical**: File MUST be named `*-background.mts` (e.g., `process-background.mts`)

**Characteristics**:
- 15-minute timeout (wall clock time)
- Immediately returns 202 status
- Return values are ignored
- Ideal for async processing, email sending, data imports

## Scheduled Functions

Run functions on a schedule using cron expressions:

```typescript
// netlify/functions/daily-cleanup.mts
import type { Config } from "@netlify/functions";

export default async (req: Request) => {
  const { next_run } = await req.json();
  
  console.log("Running cleanup...");
  await cleanupOldRecords();
  await archiveExpiredData();
  
  console.log(`Cleanup completed. Next run: ${next_run}`);
};

export const config: Config = {
  schedule: "0 0 * * *", // Daily at midnight UTC
};
```

**Common cron patterns**:
- `"@hourly"` - Every hour
- `"@daily"` - Daily at midnight
- `"0 */6 * * *"` - Every 6 hours
- `"0 0 * * 0"` - Weekly on Sunday
- `"*/5 * * * *"` - Every 5 minutes (minimum interval: 1 minute)

**Important**:
- Only runs on published deploys (not previews/branches)
- 30-second execution limit
- CRON expressions use UTC timezone
- Test locally with: `netlify functions:invoke daily-cleanup`

## Context Object Properties

```typescript
export default async (req: Request, context: Context) => {
  // Request info
  context.ip;                    // Client IP address
  context.requestId;             // Unique request ID
  context.params;                // URL path parameters (from config.path)
  
  // Deploy info
  context.site.id;               // Site ID
  context.site.url;              // Site URL
  context.deploy.id;             // Deploy ID
  context.deploy.published;      // Is this the published deploy?
  
  // Cookies
  context.cookies.get("session");
  context.cookies.set({ 
    name: "session", 
    value: "abc123",
    httpOnly: true,
    secure: true,
  });
  
  // Environment variables
  context.env.get("API_KEY");
};
```

## In-Code Configuration

```typescript
export const config: Config = {
  // Custom path (supports URLPattern syntax)
  path: "/api/users/:id",
  
  // Exclude specific paths
  excludedPath: "/api/users/admin",
  
  // Prevent overriding static files
  preferStatic: true,
};
```

**Path patterns**:
- `/api/users/:id` - Path parameter
- `/api/*` - Wildcard
- `["/api/v1/*", "/api/v2/*"]` - Multiple paths

## Database Integration (Netlify DB)

```typescript
// netlify/functions/db-query.mts
import { neon } from "@netlify/neon";
import type { Context } from "@netlify/functions";

const sql = neon();

export default async (req: Request, context: Context) => {
  const users = await sql`SELECT * FROM users LIMIT 10`;
  return Response.json(users);
};

export const config = {
  path: "/api/users",
};
```

## Netlify Blobs Integration

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
      },
    });
  }
  
  return new Response("Method not allowed", { status: 405 });
};

export const config = {
  path: "/api/files",
};
```

## CORS Configuration

```typescript
// netlify/functions/api.mts
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
};

export default async (req: Request, context: Context) => {
  // Handle preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  
  // Your logic here
  const data = { message: "Hello" };
  
  return Response.json(data, {
    headers: corsHeaders,
  });
};
```

**Note**: Only add CORS headers when explicitly needed for cross-origin requests.

## Error Handling

```typescript
export default async (req: Request, context: Context) => {
  try {
    const data = await fetchData();
    return Response.json(data);
  } catch (error) {
    console.error("Error:", error);
    
    return Response.json({
      error: "Internal server error",
      message: error instanceof Error ? error.message : "Unknown error",
    }, { 
      status: 500 
    });
  }
};
```

## Local Development

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Run dev server with functions
netlify dev

# Functions available at:
# http://localhost:8888/.netlify/functions/{function-name}
# or custom path if configured

# Invoke function directly
netlify functions:invoke hello --payload '{"name":"World"}'
```

## netlify.toml Configuration

```toml
[build]
  functions = "netlify/functions"

[functions]
  # Node.js version
  node_bundler = "esbuild"
  
  # Include files in function bundle
  included_files = ["data/**", "templates/**"]

# Function-specific settings
[functions."api-*"]
  # Increase memory for API functions
  node_bundler = "esbuild"

# Scheduled function (alternative to in-code config)
[functions."daily-cleanup"]
  schedule = "@daily"
```

## Common Patterns

### Rate Limiting

```typescript
import { getStore } from "@netlify/blobs";

const rateLimits = getStore({ name: "rate-limits", consistency: "strong" });

export default async (req: Request, context: Context) => {
  const ip = context.ip;
  const key = `rate:${ip}`;
  const now = Date.now();
  
  const current = await rateLimits.get(key, { type: "json" }) as {
    count: number;
    resetAt: number;
  } | null;
  
  if (current && current.resetAt > now && current.count >= 100) {
    return Response.json(
      { error: "Rate limit exceeded" },
      { status: 429 }
    );
  }
  
  await rateLimits.setJSON(key, {
    count: (current?.count || 0) + 1,
    resetAt: current?.resetAt > now ? current.resetAt : now + 60000,
  });
  
  // Continue with request...
  return Response.json({ success: true });
};
```

### Authentication

```typescript
export default async (req: Request, context: Context) => {
  const authHeader = req.headers.get("Authorization");
  
  if (!authHeader?.startsWith("Bearer ")) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }
  
  const token = authHeader.substring(7);
  const user = await verifyToken(token);
  
  if (!user) {
    return Response.json({ error: "Invalid token" }, { status: 401 });
  }
  
  // Continue with authenticated request
  return Response.json({ user });
};
```

## Limits

- **Timeout**: 10 seconds (26 seconds on paid plans)
- **Background timeout**: 15 minutes (wall clock)
- **Scheduled timeout**: 30 seconds
- **Payload size**: 6MB request/response
- **Memory**: 1024MB default (configurable in netlify.toml)
- **Concurrent executions**: Unlimited (auto-scales)

## Best Practices

1. **Use `.mts` extension** for TypeScript with ES modules
2. **Export config** for custom paths instead of default `/.netlify/functions/`
3. **Use `Netlify.env.get()`** for environment variables
4. **Don't add global logic** outside the exported function unless wrapped in a function definition
5. **Use background functions** for long-running tasks
6. **Use scheduled functions** for cron-like jobs
7. **Handle errors gracefully** with try-catch blocks
8. **Only add CORS** when explicitly needed
9. **Test locally** with `netlify dev` before deploying
