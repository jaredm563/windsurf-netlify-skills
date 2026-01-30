<div align="center">

# 🌊 Windsurf Netlify Skills

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-8-brightgreen.svg)](#-skills-included)
[![Netlify](https://img.shields.io/badge/Netlify-00C7B7?logo=netlify&logoColor=white)](https://netlify.com)
[![Windsurf](https://img.shields.io/badge/Windsurf-AI%20Assistant-purple)](https://codeium.com/windsurf)

*A curated collection of Windsurf global skills for Netlify platform development*

[Quick Start](#-quick-start) • [Skills](#-skills-included) • [Examples](#-examples) • [Resources](#-resources)

</div>

---

## 📚 Skills Included

<table>
<tr>
<td width="50%" valign="top">

### 🎯 Core Platform Features

- 🚀 **[Creating Sites](./netlify-creating-sites/SKILL.md)**  
  Initialize and link Netlify sites using the CLI

- 🔐 **[Environment Variables](./netlify-environment-variables/SKILL.md)**  
  Manage environment variables for secure configuration

- 📝 **[Forms](./netlify-forms/SKILL.md)**  
  Handle form submissions with spam filtering and notifications

### ⚡ Compute & Functions

- 🔧 **[Serverless Functions](./netlify-serverless-functions/SKILL.md)**  
  Create serverless functions (synchronous, background, and scheduled)

- 🌐 **[Edge Functions](./netlify-edge-functions/SKILL.md)**  
  Deploy ultra-low latency edge functions for personalization and routing

</td>
<td width="50%" valign="top">

### 💾 Data & Storage

- 🗄️ **[Netlify DB](./netlify-db/SKILL.md)**  
  Use Netlify DB (Neon Postgres) for relational data storage

- 📦 **[Blobs](./netlify-blobs/SKILL.md)**  
  Store unstructured data with key-value storage

### 🖼️ Media & Assets

- 🎨 **[Image CDN](./netlify-image-cdn/SKILL.md)**  
  Transform and optimize images on-demand

</td>
</tr>
</table>

## 🚀 Quick Start

> **💡 Tip**: Choose the installation method that works best for your workflow

### Importing into Windsurf

#### 📋 Option 1: Clone and Copy (Recommended)

```bash
# Clone the repository
git clone https://github.com/jaredm563/windsurf-netlify-skills.git
cd windsurf-netlify-skills

# macOS/Linux
cp -r netlify-* ~/.windsurf/skills/

# Windows (PowerShell)
Copy-Item netlify-* -Destination $env:USERPROFILE\.windsurf\skills\ -Recurse

# Windows (Command Prompt)
xcopy netlify-* %USERPROFILE%\.windsurf\skills\ /E /I
```

#### 📥 Option 2: Download Individual Skills

1. Browse to the skill folder you want (e.g., `netlify-serverless-functions`)
2. Download the `SKILL.md` file
3. Create the directory and place the file:

```bash
# macOS/Linux
mkdir -p ~/.windsurf/skills/netlify-serverless-functions
# Then move the downloaded SKILL.md into that directory

# Windows
mkdir %USERPROFILE%\.windsurf\skills\netlify-serverless-functions
# Then move the downloaded SKILL.md into that directory
```

#### 🔄 Option 3: Direct Git Clone into Skills Directory

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

### ✅ Verify Installation

Check that the skills were copied:

```bash
# macOS/Linux
ls ~/.windsurf/skills/netlify-*

# Windows (PowerShell)
Get-ChildItem $env:USERPROFILE\.windsurf\skills\netlify-*

# Windows (Command Prompt)
dir %USERPROFILE%\.windsurf\skills\netlify-*
```

You should see 8 directories:

<details>
<summary>📂 View all skill directories</summary>

- `netlify-blobs`
- `netlify-creating-sites`
- `netlify-db`
- `netlify-edge-functions`
- `netlify-environment-variables`
- `netlify-forms`
- `netlify-image-cdn`
- `netlify-serverless-functions`

</details>

### 🎯 Using the Skills

Once installed, Windsurf will automatically reference these skills when working on Netlify projects. No additional setup needed.

> **🤖 How it works**: Windsurf's AI assistant will automatically detect when you're working on Netlify projects and provide context-aware suggestions based on these skills.

## 📖 Skill Categories

<table>
<tr>
<td width="33%" valign="top">

### 🎓 Getting Started
Start with **Creating Sites** to learn how to initialize and link Netlify sites.

### 🔌 Building APIs
Use **Serverless Functions** for traditional API endpoints and **Edge Functions** for low-latency edge computing.

</td>
<td width="33%" valign="top">

### 💾 Data Persistence
- **DB** - Structured, relational data with SQL
- **Blobs** - Unstructured data, files, and caching

### 👥 User Interaction
- **Forms** - Contact forms, signups, and submissions
- **Environment Variables** - Secure configuration management

</td>
<td width="33%" valign="top">

### 🎨 Media Optimization
- **Image CDN** - Responsive images and on-demand transformations

### 🔗 Quick Links
- [Installation](#-quick-start)
- [Examples](#-examples)
- [Resources](#-resources)

</td>
</tr>
</table>

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

### 🏗️ Creating a New Netlify Site

```bash
# Initialize new site
netlify init

# Start local development
netlify dev
```

### ⚡ Building a Serverless API

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

### 📦 Using Netlify Blobs for Storage

```typescript
import { getStore } from "@netlify/blobs";

const store = getStore("my-store");
await store.set("key", "value");
const value = await store.get("key");
```

## 🤝 Contributing

These skills are maintained for personal use but contributions are welcome:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch
3. ✏️ Make your changes
4. 🚀 Submit a pull request

---

## � Resources

<table>
<tr>
<td width="50%">

**� Official Documentation**
- [Netlify Documentation](https://docs.netlify.com/)
- [Netlify CLI](https://docs.netlify.com/cli/get-started/)
- [Netlify Functions](https://docs.netlify.com/functions/overview/)

</td>
<td width="50%">

**🛠️ Platform Features**
- [Edge Functions](https://docs.netlify.com/edge-functions/overview/)
- [Netlify Blobs](https://docs.netlify.com/blobs/overview/)
- [Netlify DB](https://docs.netlify.com/database/overview/)

</td>
</tr>
</table>

---

<div align="center">

## � License

**Apache-2.0**

Created by [@jaredm563](https://github.com/jaredm563)

*These skills are designed for use with Windsurf AI coding assistant*

</div>
