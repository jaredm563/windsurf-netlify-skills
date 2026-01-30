# Windsurf Netlify Skills

A collection of Windsurf global skills for Netlify platform development. These skills provide comprehensive guidance for building and deploying applications on Netlify.

## 📚 Skills Included

### Core Platform Features

- **[netlify-creating-sites](./netlify-creating-sites/SKILL.md)** - Initialize and link Netlify sites using the CLI
- **[netlify-environment-variables](./netlify-environment-variables/SKILL.md)** - Manage environment variables for secure configuration
- **[netlify-forms](./netlify-forms/SKILL.md)** - Handle form submissions with spam filtering and notifications

### Compute & Functions

- **[netlify-serverless-functions](./netlify-serverless-functions/SKILL.md)** - Create serverless functions (synchronous, background, and scheduled)
- **[netlify-edge-functions](./netlify-edge-functions/SKILL.md)** - Deploy ultra-low latency edge functions for personalization and routing

### Data & Storage

- **[netlify-db](./netlify-db/SKILL.md)** - Use Netlify DB (Neon Postgres) for relational data storage
- **[netlify-blobs](./netlify-blobs/SKILL.md)** - Store unstructured data with key-value storage

### Media & Assets

- **[netlify-image-cdn](./netlify-image-cdn/SKILL.md)** - Transform and optimize images on-demand

## 🚀 Quick Start

### Installation

1. Install Windsurf (if not already installed)
2. Clone this repository or download individual skill files
3. Copy skills to your Windsurf global skills directory:

```bash
# macOS/Linux
cp -r netlify-* ~/.windsurf/skills/

# Windows
copy netlify-* %USERPROFILE%\.windsurf\skills\
```

### Using Skills in Windsurf

Once installed, these skills will be available globally in Windsurf. The AI assistant will automatically reference them when working on Netlify projects.

## 📖 Skill Categories

### Getting Started
Start with **netlify-creating-sites** to learn how to initialize and link Netlify sites.

### Building APIs
Use **netlify-serverless-functions** for traditional API endpoints and **netlify-edge-functions** for low-latency edge computing.

### Data Persistence
- **netlify-db** - For structured, relational data with SQL
- **netlify-blobs** - For unstructured data, files, and caching

### User Interaction
- **netlify-forms** - For contact forms, signups, and submissions
- **netlify-environment-variables** - For secure configuration management

### Media Optimization
- **netlify-image-cdn** - For responsive images and on-demand transformations

## 🛠️ Skill Structure

Each skill follows a consistent structure:

```markdown
---
name: skill-name
description: Brief description
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Skill Title

## When to Use
## Installation
## Basic Usage
## Common Patterns
## Best Practices
## Troubleshooting
```

## 📝 Examples

### Creating a New Netlify Site

```bash
# Initialize new site
netlify init

# Start local development
netlify dev
```

### Building a Serverless API

```typescript
// netlify/functions/api.mts
import type { Context } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  return Response.json({ message: "Hello from Netlify!" });
};

export const config = {
  path: "/api/hello",
};
```

### Using Netlify Blobs for Storage

```typescript
import { getStore } from "@netlify/blobs";

const store = getStore("my-store");
await store.set("key", "value");
const value = await store.get("key");
```

## 🤝 Contributing

These skills are maintained for personal use but contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

Apache-2.0

## 🔗 Resources

- [Netlify Documentation](https://docs.netlify.com/)
- [Netlify CLI](https://docs.netlify.com/cli/get-started/)
- [Netlify Functions](https://docs.netlify.com/functions/overview/)
- [Netlify Edge Functions](https://docs.netlify.com/edge-functions/overview/)
- [Netlify Blobs](https://docs.netlify.com/blobs/overview/)
- [Netlify DB](https://docs.netlify.com/database/overview/)

## 📧 Contact

Created by [@jaredm563](https://github.com/jaredm563)

---

**Note**: These skills are designed for use with Windsurf AI coding assistant and provide comprehensive guidance for Netlify platform development.
