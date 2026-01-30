---
name: netlify-creating-sites
description: Initialize and link Netlify sites using the CLI. Use when setting up new projects, linking existing sites, or configuring Netlify for local development.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Creating and Linking Netlify Sites

Initialize new Netlify sites or link existing projects using the Netlify CLI. This enables local development, deployment, and access to Netlify platform features.

## When to Use

- Setting up a new project on Netlify
- Linking an existing local project to a Netlify site
- Enabling Netlify features (Functions, Blobs, DB, etc.)
- Configuring local development environment
- Deploying sites manually or via CI/CD

## Prerequisites

### Install Netlify CLI

```bash
npm install -g netlify-cli

# Or with yarn
yarn global add netlify-cli

# Verify installation
netlify --version
```

### Login to Netlify

```bash
netlify login
```

This opens a browser window to authenticate with your Netlify account.

## Checking if Site is Linked

A site is linked if `.netlify/state.json` exists and contains a `siteId`:

```bash
# Check if state.json exists
cat .netlify/state.json

# Should contain:
# {
#   "siteId": "abc123-def456-..."
# }
```

If the file doesn't exist or `siteId` is empty, the site is not linked.

## Initializing a New Site

Use `netlify init` to create a new site or link to an existing one:

```bash
netlify init
```

This interactive command will:

1. **Ask if you want to create a new site or link existing**
2. **For new sites**:
   - Choose team/account
   - Enter site name (optional)
   - Configure build settings
   - Set up continuous deployment (optional)
3. **For existing sites**:
   - Search for site by name
   - Select from list
   - Link to local project

### Manual Deployment (No Git)

If you choose manual deployment:

```bash
netlify init

# Choose "Create & configure a new site"
# Select team
# Enter site name
# Choose "Deploy manually"
```

This sets up the site without connecting to a Git repository. Deploy with:

```bash
netlify deploy --prod
```

### Continuous Deployment (Git)

If you choose continuous deployment:

```bash
netlify init

# Choose "Create & configure a new site"
# Select team
# Enter site name
# Choose "Connect to Git"
```

This will:
1. Prompt you to connect a Git provider (GitHub, GitLab, Bitbucket)
2. Select repository
3. Configure build settings
4. Set up automatic deploys on push

**Note**: You may need to set up the Git repository first if it doesn't exist.

## Linking an Existing Site

If the site already exists on Netlify but isn't linked locally:

```bash
netlify link
```

This interactive command will:

1. **Search for site**: Enter site name or URL
2. **Select from list**: Choose from your sites
3. **Link to project**: Creates `.netlify/state.json`

### Link by Site ID

If you know the site ID:

```bash
netlify link --id abc123-def456-...
```

### Link by Site Name

```bash
netlify link --name my-site-name
```

## Project Structure After Linking

```
project/
├── .netlify/
│   └── state.json          # Contains siteId
├── netlify.toml            # Optional configuration
├── netlify/
│   ├── functions/          # Serverless functions
│   └── edge-functions/     # Edge functions
└── ...
```

### .netlify/state.json

```json
{
  "siteId": "abc123-def456-ghi789"
}
```

**Important**: Add `.netlify/` to `.gitignore` to avoid committing local state.

## Configuration with netlify.toml

Create a `netlify.toml` file for site configuration:

```toml
[build]
  # Build command
  command = "npm run build"
  
  # Publish directory
  publish = "dist"
  
  # Functions directory
  functions = "netlify/functions"

[build.environment]
  # Build-time environment variables
  NODE_VERSION = "18.17.0"

[dev]
  # Local dev server settings
  command = "npm run dev"
  port = 3000
  targetPort = 8888
  autoLaunch = true

# Redirects
[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200

# Headers
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
```

## Local Development

### Start Dev Server

```bash
netlify dev
```

This starts a local development server with:
- Functions at `/.netlify/functions/`
- Edge Functions at configured paths
- Netlify Blobs, DB, and other platform features
- Environment variables from Netlify
- Redirects and headers from `netlify.toml`

**Default URL**: `http://localhost:8888`

### Custom Dev Command

If using a framework with its own dev server:

```bash
# For Vite-based frameworks, install plugin first
npm install -D @netlify/vite-plugin

# Then run framework's dev command
npm run dev
```

The `@netlify/vite-plugin` brings Netlify platform features into your framework's dev server.

## Deploying

### Deploy to Production

```bash
netlify deploy --prod
```

### Deploy Preview

```bash
netlify deploy
```

This creates a deploy preview with a unique URL.

### Deploy with Build

```bash
netlify deploy --build --prod
```

This runs the build command before deploying.

## Environment Variables

### Set Environment Variables

```bash
# Set a variable
netlify env:set API_KEY "your-api-key"

# Set a secret (hidden in UI)
netlify env:set DATABASE_URL "postgresql://..." --secret

# Import from .env file
netlify env:import .env

# List variables
netlify env:list

# Unset a variable
netlify env:unset API_KEY
```

**Note**: Project must be linked before setting environment variables.

## Common Workflows

### New Project from Scratch

```bash
# 1. Create project directory
mkdir my-project
cd my-project

# 2. Initialize project (npm, git, etc.)
npm init -y
git init

# 3. Install dependencies
npm install

# 4. Initialize Netlify
netlify init

# 5. Start development
netlify dev
```

### Existing Project, New Site

```bash
# 1. Navigate to project
cd existing-project

# 2. Initialize Netlify
netlify init

# Choose "Create & configure a new site"
# Configure settings

# 3. Start development
netlify dev
```

### Existing Project, Existing Site

```bash
# 1. Navigate to project
cd existing-project

# 2. Link to existing site
netlify link

# Search for site or enter site ID

# 3. Start development
netlify dev
```

### Framework-Specific Setup

#### Next.js

```bash
# Create Next.js app
npx create-next-app@latest my-app
cd my-app

# Initialize Netlify
netlify init

# Install Netlify adapter (automatic)
# Start dev server
npm run dev
```

#### Astro

```bash
# Create Astro app
npm create astro@latest my-app
cd my-app

# Initialize Netlify
netlify init

# Install Vite plugin
npm install -D @netlify/vite-plugin

# Start dev server
npm run dev
```

#### SvelteKit

```bash
# Create SvelteKit app
npm create svelte@latest my-app
cd my-app

# Initialize Netlify
netlify init

# Install Vite plugin
npm install -D @netlify/vite-plugin

# Start dev server
npm run dev
```

#### Nuxt

```bash
# Create Nuxt app
npx nuxi init my-app
cd my-app

# Initialize Netlify
netlify init

# Install Nuxt module
npx nuxi module add @netlify/nuxt

# Start dev server
npm run dev
```

## Netlify CLI Commands Reference

### Site Management

```bash
# Initialize new site or link existing
netlify init

# Link to existing site
netlify link

# Unlink from site
netlify unlink

# Get site info
netlify status

# Open site in browser
netlify open

# Open admin UI
netlify open:admin
```

### Development

```bash
# Start dev server
netlify dev

# Start dev server on specific port
netlify dev --port 3000

# Live session (share local dev)
netlify dev --live
```

### Deployment

```bash
# Deploy preview
netlify deploy

# Deploy to production
netlify deploy --prod

# Deploy with build
netlify deploy --build --prod

# Deploy specific directory
netlify deploy --dir=dist --prod
```

### Functions

```bash
# List functions
netlify functions:list

# Create new function
netlify functions:create

# Invoke function locally
netlify functions:invoke my-function

# Invoke with payload
netlify functions:invoke my-function --payload '{"key":"value"}'

# Serve functions locally
netlify functions:serve
```

### Environment Variables

```bash
# Set variable
netlify env:set KEY "value"

# Set secret
netlify env:set KEY "value" --secret

# List variables
netlify env:list

# List in .env format
netlify env:list --plain

# Import from .env
netlify env:import .env

# Unset variable
netlify env:unset KEY
```

### Build

```bash
# Run build locally
netlify build

# Run build with debug
netlify build --debug

# Clear cache and build
netlify build --clear-cache
```

## Troubleshooting

### Site Not Linking

**Check authentication**:
```bash
netlify status
```

If not logged in:
```bash
netlify login
```

**Verify site exists**:
- Check Netlify dashboard
- Ensure you have access to the site
- Try linking by site ID instead of name

### Functions Not Working Locally

**Install Vite plugin** (for Vite-based frameworks):
```bash
npm install -D @netlify/vite-plugin
```

**Or use Netlify Dev**:
```bash
netlify dev
```

### Environment Variables Not Available

**Ensure site is linked**:
```bash
netlify status
```

**Set variables**:
```bash
netlify env:set API_KEY "value"
```

**Check context**:
```bash
netlify env:list --context production
netlify env:list --context deploy-preview
```

### Build Failing

**Test build locally**:
```bash
netlify build
```

**Check build settings** in `netlify.toml`:
```toml
[build]
  command = "npm run build"
  publish = "dist"
```

**Clear cache**:
```bash
netlify build --clear-cache
```

## Best Practices

1. **Add `.netlify/` to `.gitignore`** to avoid committing local state
2. **Use `netlify.toml`** for configuration instead of UI when possible
3. **Test locally** with `netlify dev` before deploying
4. **Use environment variables** for secrets and configuration
5. **Link site early** in development to access platform features
6. **Use framework plugins** (`@netlify/vite-plugin`, `@netlify/nuxt`) for better DX
7. **Set up continuous deployment** for automatic deploys on push
8. **Use deploy previews** to test changes before production
9. **Document required environment variables** in README
10. **Keep CLI updated** for latest features and fixes

## Security

- Never commit `.netlify/state.json` with sensitive data
- Use `--secret` flag for sensitive environment variables
- Rotate API keys and secrets regularly
- Use different values for production vs preview environments
- Limit team access to production sites
- Review deploy logs for exposed secrets

## Common Issues

### "Site not found" error

**Solution**: Link the site first:
```bash
netlify link
```

### Functions not detected

**Solution**: Ensure functions are in the correct directory:
```toml
[build]
  functions = "netlify/functions"
```

### Environment variables not loading

**Solution**: Restart dev server after setting variables:
```bash
netlify env:set KEY "value"
netlify dev
```

### Build command not found

**Solution**: Install dependencies first:
```bash
npm install
netlify build
```
