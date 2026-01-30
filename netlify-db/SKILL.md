---
name: netlify-db
description: Use Netlify DB (powered by Neon Postgres) for relational data storage. Use when you need SQL databases, relational structures, transactions, or search capabilities on Netlify.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify DB

Netlify DB provides serverless Postgres databases powered by Neon. Databases are automatically provisioned and require no manual setup or Neon account.

## When to Use

- Relational data structures (users, posts, orders, etc.)
- SQL queries and joins
- Transactions and ACID compliance
- Full-text search
- Complex data relationships
- Structured data with schemas

**Alternative**: Use Netlify Blobs for unstructured data, file storage, or simple key-value needs.

## Prerequisites

### Installation

```bash
npm install @netlify/neon
```

### Site Setup

1. **Login to Netlify CLI**:
```bash
netlify login
```

2. **Link your site**:
```bash
netlify link
```

3. **Install `@netlify/neon`**:
```bash
npm install @netlify/neon
```

4. **Run dev or build**:
```bash
netlify dev
# or
netlify build
```

The database is automatically provisioned on first use. No manual setup required.

## Basic Usage

### Query Database

```typescript
// netlify/functions/users.mts
import { neon } from "@netlify/neon";
import type { Context } from "@netlify/functions";

// No connection string needed - automatically configured
const sql = neon();

export default async (req: Request, context: Context) => {
  const users = await sql`SELECT * FROM users LIMIT 10`;
  return Response.json(users);
};

export const config = {
  path: "/api/users",
};
```

### Insert Data

```typescript
import { neon } from "@netlify/neon";

const sql = neon();

export default async (req: Request, context: Context) => {
  const { name, email } = await req.json();
  
  const result = await sql`
    INSERT INTO users (name, email)
    VALUES (${name}, ${email})
    RETURNING *
  `;
  
  return Response.json(result[0], { status: 201 });
};
```

### Update Data

```typescript
import { neon } from "@netlify/neon";

const sql = neon();

export default async (req: Request, context: Context) => {
  const { id } = context.params;
  const { name, email } = await req.json();
  
  const result = await sql`
    UPDATE users
    SET name = ${name}, email = ${email}, updated_at = NOW()
    WHERE id = ${id}
    RETURNING *
  `;
  
  if (result.length === 0) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return Response.json(result[0]);
};
```

### Delete Data

```typescript
import { neon } from "@netlify/neon";

const sql = neon();

export default async (req: Request, context: Context) => {
  const { id } = context.params;
  
  const result = await sql`
    DELETE FROM users
    WHERE id = ${id}
    RETURNING *
  `;
  
  if (result.length === 0) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return new Response(null, { status: 204 });
};
```

## Database Migrations

Create migration scripts to set up your database schema:

### Get Database URL

```bash
netlify env:get NETLIFY_DATABASE_URL
```

### Create Migration Script

```typescript
// scripts/migrate.ts
import { neon } from "@netlify/neon";

const sql = neon();

async function migrate() {
  console.log("Running migrations...");
  
  // Create users table
  await sql`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;
  
  // Create posts table
  await sql`
    CREATE TABLE IF NOT EXISTS posts (
      id SERIAL PRIMARY KEY,
      user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      title VARCHAR(255) NOT NULL,
      content TEXT,
      published BOOLEAN DEFAULT false,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;
  
  // Create indexes
  await sql`
    CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id)
  `;
  
  await sql`
    CREATE INDEX IF NOT EXISTS idx_posts_published ON posts(published)
  `;
  
  console.log("Migrations completed!");
}

migrate().catch(console.error);
```

### Run Migration

```bash
# Run locally
netlify dev:exec node scripts/migrate.ts

# Or add to package.json
npm run migrate
```

Add to `package.json`:

```json
{
  "scripts": {
    "migrate": "netlify dev:exec node scripts/migrate.ts"
  }
}
```

## SQL Queries

### Parameterized Queries

Always use parameterized queries to prevent SQL injection:

```typescript
// ✅ GOOD - Parameterized
const users = await sql`
  SELECT * FROM users 
  WHERE email = ${email}
`;

// ❌ BAD - String concatenation (SQL injection risk)
const users = await sql`SELECT * FROM users WHERE email = '${email}'`;
```

### Joins

```typescript
const sql = neon();

// Get users with their posts
const usersWithPosts = await sql`
  SELECT 
    u.id,
    u.name,
    u.email,
    json_agg(
      json_build_object(
        'id', p.id,
        'title', p.title,
        'published', p.published
      )
    ) as posts
  FROM users u
  LEFT JOIN posts p ON u.id = p.user_id
  GROUP BY u.id
`;
```

### Transactions

```typescript
import { neon } from "@netlify/neon";

const sql = neon();

export default async (req: Request) => {
  const { userId, postData } = await req.json();
  
  try {
    // Begin transaction
    await sql`BEGIN`;
    
    // Update user
    await sql`
      UPDATE users 
      SET post_count = post_count + 1 
      WHERE id = ${userId}
    `;
    
    // Insert post
    const result = await sql`
      INSERT INTO posts (user_id, title, content)
      VALUES (${userId}, ${postData.title}, ${postData.content})
      RETURNING *
    `;
    
    // Commit transaction
    await sql`COMMIT`;
    
    return Response.json(result[0], { status: 201 });
  } catch (error) {
    // Rollback on error
    await sql`ROLLBACK`;
    throw error;
  }
};
```

### Full-Text Search

```typescript
// Create full-text search index
await sql`
  CREATE INDEX IF NOT EXISTS idx_posts_search 
  ON posts USING GIN(to_tsvector('english', title || ' ' || content))
`;

// Search posts
const searchResults = await sql`
  SELECT 
    id,
    title,
    content,
    ts_rank(
      to_tsvector('english', title || ' ' || content),
      plainto_tsquery('english', ${searchQuery})
    ) as rank
  FROM posts
  WHERE to_tsvector('english', title || ' ' || content) 
    @@ plainto_tsquery('english', ${searchQuery})
  ORDER BY rank DESC
  LIMIT 10
`;
```

## Common Patterns

### CRUD API

```typescript
// netlify/functions/api-users.mts
import { neon } from "@netlify/neon";
import type { Context } from "@netlify/functions";

const sql = neon();

export default async (req: Request, context: Context) => {
  const { method } = req;
  const { id } = context.params;
  
  try {
    switch (method) {
      case "GET":
        return id ? getUser(id) : listUsers();
      case "POST":
        return createUser(req);
      case "PUT":
        return updateUser(id, req);
      case "DELETE":
        return deleteUser(id);
      default:
        return new Response("Method not allowed", { status: 405 });
    }
  } catch (error) {
    console.error("Database error:", error);
    return Response.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
};

async function listUsers() {
  const users = await sql`
    SELECT id, name, email, created_at 
    FROM users 
    ORDER BY created_at DESC
  `;
  return Response.json(users);
}

async function getUser(id: string) {
  const result = await sql`
    SELECT id, name, email, created_at 
    FROM users 
    WHERE id = ${id}
  `;
  
  if (result.length === 0) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return Response.json(result[0]);
}

async function createUser(req: Request) {
  const { name, email } = await req.json();
  
  const result = await sql`
    INSERT INTO users (name, email)
    VALUES (${name}, ${email})
    RETURNING id, name, email, created_at
  `;
  
  return Response.json(result[0], { status: 201 });
}

async function updateUser(id: string, req: Request) {
  const { name, email } = await req.json();
  
  const result = await sql`
    UPDATE users
    SET name = ${name}, email = ${email}, updated_at = NOW()
    WHERE id = ${id}
    RETURNING id, name, email, updated_at
  `;
  
  if (result.length === 0) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return Response.json(result[0]);
}

async function deleteUser(id: string) {
  const result = await sql`
    DELETE FROM users 
    WHERE id = ${id}
    RETURNING id
  `;
  
  if (result.length === 0) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return new Response(null, { status: 204 });
}

export const config = {
  path: "/api/users/:id?",
};
```

### Pagination

```typescript
import { neon } from "@netlify/neon";

const sql = neon();

export default async (req: Request) => {
  const url = new URL(req.url);
  const page = parseInt(url.searchParams.get("page") || "1");
  const limit = parseInt(url.searchParams.get("limit") || "10");
  const offset = (page - 1) * limit;
  
  // Get total count
  const countResult = await sql`SELECT COUNT(*) FROM posts`;
  const total = parseInt(countResult[0].count);
  
  // Get paginated results
  const posts = await sql`
    SELECT * FROM posts
    ORDER BY created_at DESC
    LIMIT ${limit}
    OFFSET ${offset}
  `;
  
  return Response.json({
    data: posts,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  });
};
```

### Authentication

```typescript
import { neon } from "@netlify/neon";
import bcrypt from "bcryptjs";

const sql = neon();

// Register user
export async function register(req: Request) {
  const { email, password, name } = await req.json();
  
  // Hash password
  const hashedPassword = await bcrypt.hash(password, 10);
  
  try {
    const result = await sql`
      INSERT INTO users (email, password, name)
      VALUES (${email}, ${hashedPassword}, ${name})
      RETURNING id, email, name
    `;
    
    return Response.json(result[0], { status: 201 });
  } catch (error) {
    if (error.code === "23505") { // Unique violation
      return Response.json(
        { error: "Email already exists" },
        { status: 409 }
      );
    }
    throw error;
  }
}

// Login user
export async function login(req: Request) {
  const { email, password } = await req.json();
  
  const result = await sql`
    SELECT id, email, password, name
    FROM users
    WHERE email = ${email}
  `;
  
  if (result.length === 0) {
    return Response.json(
      { error: "Invalid credentials" },
      { status: 401 }
    );
  }
  
  const user = result[0];
  const valid = await bcrypt.compare(password, user.password);
  
  if (!valid) {
    return Response.json(
      { error: "Invalid credentials" },
      { status: 401 }
    );
  }
  
  // Return user without password
  const { password: _, ...userWithoutPassword } = user;
  return Response.json(userWithoutPassword);
}
```

### Relationships

```typescript
import { neon } from "@netlify/neon";

const sql = neon();

// Get user with posts
export async function getUserWithPosts(userId: string) {
  const result = await sql`
    SELECT 
      u.id,
      u.name,
      u.email,
      COALESCE(
        json_agg(
          json_build_object(
            'id', p.id,
            'title', p.title,
            'content', p.content,
            'published', p.published,
            'created_at', p.created_at
          )
        ) FILTER (WHERE p.id IS NOT NULL),
        '[]'
      ) as posts
    FROM users u
    LEFT JOIN posts p ON u.id = p.user_id
    WHERE u.id = ${userId}
    GROUP BY u.id
  `;
  
  if (result.length === 0) {
    return Response.json({ error: "User not found" }, { status: 404 });
  }
  
  return Response.json(result[0]);
}
```

## Environment Variables

The database connection is automatically configured via `NETLIFY_DATABASE_URL`. You don't need to set it manually.

```typescript
// Automatically uses NETLIFY_DATABASE_URL
const sql = neon();

// Or access it explicitly if needed
const connectionString = process.env.NETLIFY_DATABASE_URL;
```

## Local Development

When using `netlify dev`, the database connection is automatically configured for local development.

```bash
# Start dev server with database access
netlify dev

# Run migration
netlify dev:exec node scripts/migrate.ts
```

## Database Management

### Claiming Your Database

Databases are created anonymously. To claim and manage via Neon dashboard:

1. Go to Netlify UI → Site settings → Database
2. Click "Claim database"
3. Follow instructions to link to Neon account

### Accessing Database Directly

```bash
# Get connection string
netlify env:get NETLIFY_DATABASE_URL

# Connect with psql
psql "$(netlify env:get NETLIFY_DATABASE_URL)"
```

## Best Practices

1. **Use migrations** for schema changes
2. **Always use parameterized queries** to prevent SQL injection
3. **Create indexes** for frequently queried columns
4. **Use transactions** for multi-step operations
5. **Handle errors gracefully** with try-catch blocks
6. **Don't expose raw errors** to clients
7. **Validate input** before database operations
8. **Use connection pooling** (built into `@netlify/neon`)
9. **Limit query results** with LIMIT/OFFSET for pagination
10. **Test migrations locally** before deploying

## Performance Tips

1. **Add indexes** for WHERE, JOIN, and ORDER BY columns
2. **Use EXPLAIN ANALYZE** to optimize slow queries
3. **Avoid N+1 queries** - use JOINs or batch queries
4. **Use connection pooling** (automatic with `@netlify/neon`)
5. **Cache frequently accessed data** in Netlify Blobs
6. **Limit result sets** with pagination
7. **Use prepared statements** (automatic with parameterized queries)

## Security

1. **Never expose database credentials** in client code
2. **Use parameterized queries** to prevent SQL injection
3. **Validate and sanitize input** before queries
4. **Implement authentication** for protected endpoints
5. **Use row-level security** for multi-tenant apps
6. **Rotate credentials** if compromised
7. **Limit database user permissions** to minimum required
8. **Use HTTPS** for all API endpoints
9. **Log security events** for audit trails
10. **Keep dependencies updated** for security patches

## Troubleshooting

### Database Not Provisioned

**Ensure site is linked**:
```bash
netlify status
```

**Run dev or build**:
```bash
netlify dev
# or
netlify build
```

### Connection Errors

**Check environment variable**:
```bash
netlify env:get NETLIFY_DATABASE_URL
```

**Restart dev server**:
```bash
netlify dev
```

### Migration Failures

**Check SQL syntax**:
- Ensure valid Postgres SQL
- Test queries individually

**Check permissions**:
- Ensure database user has required permissions

**Rollback and retry**:
```sql
DROP TABLE IF EXISTS table_name;
-- Re-run migration
```

## Limitations

- Database is serverless Postgres (Neon)
- Connection pooling is automatic
- No direct database access without claiming
- Migrations must be run manually
- No automatic backups (claim database for backups)

## Example Schema

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Posts table
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Comments table
CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_published ON posts(published);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);

-- Full-text search
CREATE INDEX idx_posts_search 
ON posts USING GIN(to_tsvector('english', title || ' ' || content));
```
