---
name: netlify-environment-variables
description: Manage environment variables for Netlify sites using UI, CLI, API, or netlify.toml. Use for storing API keys, secrets, configuration values, and context-specific settings.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify Environment Variables

Environment variables securely store configuration values, API keys, and secrets for Netlify sites. They can be set via UI, CLI, API, or `netlify.toml`.

## When to Use

- Storing API keys and secrets
- Database connection strings
- Third-party service credentials
- Feature flags and configuration
- Context-specific settings (production vs preview)
- Build-time and runtime configuration

## Setting Environment Variables

### Via Netlify CLI (Recommended for Secrets)

```bash
# Set a variable
netlify env:set API_KEY "your-api-key-value"

# Set a secret variable (hidden in UI)
netlify env:set DATABASE_URL "postgresql://..." --secret

# Import from .env file
netlify env:import .env

# List variables (production context)
netlify env:list

# List in .env format
netlify env:list --plain

# Export to .env file
netlify env:list --plain --context production > .env

# Unset a variable
netlify env:unset API_KEY
```

**Note**: Project must be linked first (`netlify link` or `netlify init`).

### Via Netlify UI

Navigate to: **Site settings → Environment variables**

1. Click "Add a variable"
2. Enter key and value
3. Select scopes (contexts and deploy types)
4. Save

**Best for**: Managing variables through a visual interface, team collaboration.

### Via netlify.toml (Not for Secrets)

```toml
# Production context
[context.production.environment]
  NODE_VERSION = "18.17.0"
  API_URL = "https://api.example.com"

# Deploy preview context
[context.deploy-preview.environment]
  API_URL = "https://staging-api.example.com"
  DEBUG = "true"

# Branch deploy context
[context.branch-deploy.environment]
  NODE_ENV = "development"

# Specific branch
[context.staging.environment]
  API_URL = "https://staging-api.example.com"

# Local development
[context.dev.environment]
  NODE_ENV = "development"
  API_URL = "http://localhost:3000"
```

**Important**: Never commit secrets to `netlify.toml`. Use CLI or UI for sensitive values.

## Accessing Environment Variables

### In Serverless Functions

```typescript
// netlify/functions/api.mts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  // Preferred method (Netlify global object)
  const apiKey = Netlify.env.get("API_KEY");
  
  // Alternative (process.env)
  const dbUrl = process.env.DATABASE_URL;
  
  // Via context
  const secret = context.env.get("SECRET_KEY");
  
  if (!apiKey) {
    return Response.json({ error: "API key not configured" }, { status: 500 });
  }
  
  const response = await fetch("https://api.example.com/data", {
    headers: { Authorization: `Bearer ${apiKey}` },
  });
  
  return Response.json(await response.json());
};
```

### In Edge Functions

```typescript
// netlify/edge-functions/geo.ts
import type { Context } from "@netlify/edge-functions";

export default async (req: Request, context: Context) => {
  // Preferred method (Netlify global object)
  const apiKey = Netlify.env.get("API_KEY");
  
  // Via context
  const feature = context.env.get("FEATURE_FLAG");
  
  return Response.json({ 
    featureEnabled: feature === "true",
    hasApiKey: !!apiKey,
  });
};
```

### In Build Scripts

```javascript
// build-script.js
const apiUrl = process.env.API_URL;
const nodeVersion = process.env.NODE_VERSION;

console.log(`Building with Node ${nodeVersion}`);
console.log(`API URL: ${apiUrl}`);
```

### In Framework Code (Build-time)

Environment variables are available during build for static site generation:

```typescript
// Next.js, Astro, etc.
const apiUrl = process.env.API_URL;

export async function getStaticProps() {
  const data = await fetch(`${process.env.API_URL}/data`);
  return { props: { data } };
}
```

**Note**: Build-time variables are baked into the static output.

### In Client-Side Code

For security, environment variables are NOT automatically available in browser code. To expose them:

#### Next.js

Prefix with `NEXT_PUBLIC_`:

```bash
netlify env:set NEXT_PUBLIC_API_URL "https://api.example.com"
```

```typescript
// Available in browser
const apiUrl = process.env.NEXT_PUBLIC_API_URL;
```

#### Vite/Astro

Prefix with `PUBLIC_`:

```bash
netlify env:set PUBLIC_API_URL "https://api.example.com"
```

```typescript
// Vite
const apiUrl = import.meta.env.PUBLIC_API_URL;

// Astro
const apiUrl = import.meta.env.PUBLIC_API_URL;
```

**Important**: Never expose secrets in client-side code.

## Deploy Contexts

Variables can be scoped to specific deploy contexts:

- **Production**: Main branch deploys
- **Deploy previews**: Pull/merge request previews
- **Branch deploys**: Non-production branch deploys
- **Dev**: Local development with `netlify dev`

### Context-Specific Configuration

```toml
# Production only
[context.production.environment]
  API_URL = "https://api.example.com"
  STRIPE_KEY = "pk_live_..."

# Deploy previews only
[context.deploy-preview.environment]
  API_URL = "https://staging-api.example.com"
  STRIPE_KEY = "pk_test_..."

# Branch deploys
[context.branch-deploy.environment]
  API_URL = "https://dev-api.example.com"

# Specific branch
[context.feature-branch.environment]
  FEATURE_FLAG = "true"

# Local development
[context.dev.environment]
  API_URL = "http://localhost:3000"
```

## Precedence Order

When multiple sources define the same variable:

1. **UI/CLI/API variables** (highest priority)
2. **`netlify.toml` context-specific** (`[context.production.environment]`)
3. **`netlify.toml` build environment** (`[build.environment]`)
4. **Netlify default variables** (lowest priority)

**Example**: If `API_URL` is set in both UI and `netlify.toml`, the UI value wins.

## Built-in Netlify Variables

Netlify provides several built-in variables:

### Deploy Information

```typescript
// Deploy context: "production" | "deploy-preview" | "branch-deploy"
const context = process.env.CONTEXT;

// Deploy ID
const deployId = process.env.DEPLOY_ID;

// Deploy URL
const deployUrl = process.env.DEPLOY_URL;

// Deploy prime URL (main URL for the deploy)
const url = process.env.URL;

// Branch name
const branch = process.env.BRANCH;

// Commit ref
const commitRef = process.env.COMMIT_REF;

// Head (current commit)
const head = process.env.HEAD;

// Review ID (for deploy previews)
const reviewId = process.env.REVIEW_ID;
```

### Site Information

```typescript
// Site name
const siteName = process.env.SITE_NAME;

// Site ID
const siteId = process.env.SITE_ID;
```

### Build Information

```typescript
// Build ID
const buildId = process.env.BUILD_ID;

// Repository URL
const repoUrl = process.env.REPOSITORY_URL;
```

## Working with .env Files

### Import from .env

```bash
# Import all variables from .env
netlify env:import .env

# Import to specific context
netlify env:import .env --context production
```

### Export to .env

```bash
# Export production variables
netlify env:list --plain --context production > .env

# Export all contexts
netlify env:list --plain > .env.all
```

### .env File Format

```bash
# .env
API_KEY=your-api-key
DATABASE_URL=postgresql://user:pass@host:5432/db
FEATURE_FLAG=true
```

**Important**: Add `.env` to `.gitignore` to avoid committing secrets.

## Secrets Management

### Mark as Secret

```bash
# CLI: Mark as secret (hidden in UI)
netlify env:set DATABASE_URL "postgresql://..." --secret
```

In UI: Check "Keep this value secret" when creating/editing.

### Best Practices for Secrets

1. **Never commit secrets** to version control
2. **Use CLI or UI** for sensitive values, not `netlify.toml`
3. **Mark as secret** to hide from UI and logs
4. **Rotate regularly** for security
5. **Use different values** for production vs preview
6. **Limit access** using team permissions

## Common Patterns

### Database Connection

```typescript
// netlify/functions/db.mts
import { neon } from "@netlify/neon";

// Automatically uses NETLIFY_DATABASE_URL
const sql = neon();

export default async (req: Request) => {
  const users = await sql`SELECT * FROM users LIMIT 10`;
  return Response.json(users);
};
```

### API Key Management

```typescript
// netlify/functions/api.mts
export default async (req: Request, context: Context) => {
  const apiKey = Netlify.env.get("EXTERNAL_API_KEY");
  
  if (!apiKey) {
    return Response.json(
      { error: "API key not configured" },
      { status: 500 }
    );
  }
  
  const response = await fetch("https://api.example.com/data", {
    headers: { 
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
  });
  
  if (!response.ok) {
    return Response.json(
      { error: "External API error" },
      { status: response.status }
    );
  }
  
  return Response.json(await response.json());
};
```

### Feature Flags

```typescript
// netlify/edge-functions/feature-flag.ts
export default async (req: Request, context: Context) => {
  const newFeatureEnabled = Netlify.env.get("FEATURE_NEW_UI") === "true";
  
  if (newFeatureEnabled) {
    const url = new URL(req.url);
    url.pathname = `/new-ui${url.pathname}`;
    return context.rewrite(url);
  }
  
  return context.next();
};
```

### Context-Specific Configuration

```typescript
// netlify/functions/config.mts
export default async (req: Request) => {
  const config = {
    apiUrl: Netlify.env.get("API_URL"),
    environment: Netlify.env.get("CONTEXT"),
    debug: Netlify.env.get("DEBUG") === "true",
    version: Netlify.env.get("VERSION") || "1.0.0",
  };
  
  return Response.json(config);
};
```

### Multi-Environment Setup

```toml
# netlify.toml

# Production
[context.production.environment]
  API_URL = "https://api.example.com"
  STRIPE_KEY = "pk_live_..."
  ANALYTICS_ID = "UA-PROD-123"
  LOG_LEVEL = "error"

# Staging branch
[context.staging.environment]
  API_URL = "https://staging-api.example.com"
  STRIPE_KEY = "pk_test_..."
  ANALYTICS_ID = "UA-STAGING-123"
  LOG_LEVEL = "info"

# Deploy previews
[context.deploy-preview.environment]
  API_URL = "https://preview-api.example.com"
  STRIPE_KEY = "pk_test_..."
  ANALYTICS_ID = "UA-PREVIEW-123"
  LOG_LEVEL = "debug"

# Local development
[context.dev.environment]
  API_URL = "http://localhost:3000"
  STRIPE_KEY = "pk_test_..."
  LOG_LEVEL = "debug"
```

## Troubleshooting

### Variable Not Available

**Check context**: Ensure variable is set for the correct context (production, deploy-preview, etc.)

```bash
# List variables for specific context
netlify env:list --context production
netlify env:list --context deploy-preview
```

**Check scope**: In UI, verify variable is enabled for the correct scopes.

### Build Fails with Missing Variable

**Set in netlify.toml** for build-time variables:

```toml
[build.environment]
  NODE_VERSION = "18.17.0"
```

**Or set via CLI**:

```bash
netlify env:set NODE_VERSION "18.17.0"
```

### Variable Not Updating

**Clear build cache**:

```bash
netlify build --clear-cache
```

**Trigger new deploy**: Changes to environment variables require a new deploy.

### Client-Side Variable Not Available

**Ensure proper prefix**:
- Next.js: `NEXT_PUBLIC_`
- Vite/Astro: `PUBLIC_`

**Rebuild**: Client-side variables are baked into the build.

## Best Practices

1. **Use CLI/UI for secrets**, never `netlify.toml`
2. **Prefix client-side variables** appropriately
3. **Use context-specific values** for different environments
4. **Mark sensitive values as secret**
5. **Document required variables** in README
6. **Validate variables** in functions before use
7. **Use `.env.example`** to show required variables (without values)
8. **Rotate secrets regularly**
9. **Limit team access** to production secrets
10. **Use different values** for production vs preview/dev

## Example .env.example

```bash
# .env.example
# Copy to .env and fill in values

# Required
API_KEY=
DATABASE_URL=

# Optional
DEBUG=false
LOG_LEVEL=info
FEATURE_FLAG=false
```

## Security Checklist

- [ ] Secrets marked as secret in UI/CLI
- [ ] `.env` added to `.gitignore`
- [ ] No secrets in `netlify.toml`
- [ ] Different values for prod vs preview
- [ ] Client-side variables don't expose secrets
- [ ] Team access properly configured
- [ ] Secrets rotated regularly
- [ ] Variables validated before use
