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

### Importing into Windsurf

**Option 1: Clone and Copy (Recommended)**

```bash
# Clone the repository
git clone https://github.com/jaredm563/windsurf-netlify-skills.git

# Navigate to the cloned directory
cd windsurf-netlify-skills

# Copy all skills to Windsurf global skills directory
# macOS/Linux
cp -r netlify-* ~/.windsurf/skills/

# Windows (PowerShell)
Copy-Item -Path netlify-* -Destination $env:USERPROFILE\.windsurf\skills\ -Recurse

# Windows (Command Prompt)
xcopy netlify-* %USERPROFILE%\.windsurf\skills\ /E /I
```

**Option 2: Download Individual Skills**

1. Navigate to the skill folder you want (e.g., `netlify-serverless-functions`)
2. Download the `SKILL.md` file
3. Create the skill directory in your Windsurf skills folder:
   ```bash
   # macOS/Linux
   mkdir -p ~/.windsurf/skills/netlify-serverless-functions
   
   # Windows
   mkdir %USERPROFILE%\.windsurf\skills\netlify-serverless-functions
   ```
4. Place the downloaded `SKILL.md` file in that directory

**Option 3: Direct Git Clone into Skills Directory**

```bash
# macOS/Linux
cd ~/.windsurf/skills
git clone https://github.com/jaredm563/windsurf-netlify-skills.git
mv windsurf-netlify-skills/netlify-* .
rm -rf windsurf-netlify-skills

# Windows (PowerShell)
cd $env:USERPROFILE\.windsurf\skills
git clone https://github.com/jaredm563/windsurf-netlify-skills.git
Move-Item windsurf-netlify-skills\netlify-* .
Remove-Item windsurf-netlify-skills -Recurse -Force
```

### Verifying Installation

After copying the skills, verify they're installed correctly:

```bash
# macOS/Linux
ls ~/.windsurf/skills/netlify-*

# Windows (PowerShell)
Get-ChildItem $env:USERPROFILE\.windsurf\skills\netlify-*

# Windows (Command Prompt)
dir %USERPROFILE%\.windsurf\skills\netlify-*
```

You should see 8 directories:
- `netlify-blobs`
- `netlify-creating-sites`
- `netlify-db`
- `netlify-edge-functions`
- `netlify-environment-variables`
- `netlify-forms`
- `netlify-image-cdn`
- `netlify-serverless-functions`

### Using Skills in Windsurf

Once installed, these skills will be available globally in Windsurf. The AI assistant will automatically reference them when working on Netlify projects. You don't need to do anything else - just start coding!

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
