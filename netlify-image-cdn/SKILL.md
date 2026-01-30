---
name: netlify-image-cdn
description: Transform and optimize images on-demand using Netlify Image CDN. Use for dynamic image resizing, format conversion, quality optimization, and serving responsive images without build-time processing.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify Image CDN

Netlify Image CDN provides on-demand image transformation and optimization via the `/.netlify/images` route. Transform images dynamically without build-time processing.

## When to Use

- Dynamic image resizing and cropping
- Format conversion (WebP, AVIF, JPEG, PNG)
- Quality optimization for bandwidth savings
- Responsive images for different screen sizes
- Serving remote images through your domain
- Generating thumbnails on-demand
- Creating image variants without duplicating files

## Basic Usage

All Netlify projects have a `/.netlify/images` route available automatically without any configuration.

### Transform Local Images

```html
<!-- Original image at /images/photo.jpg -->
<img src="/.netlify/images?url=/images/photo.jpg&w=400&h=300&fit=cover" />

<!-- Convert to WebP -->
<img src="/.netlify/images?url=/images/photo.jpg&w=800&fm=webp&q=80" />

<!-- Create thumbnail -->
<img src="/.netlify/images?url=/images/photo.jpg&w=150&h=150&fit=cover" />
```

### Transform Remote Images

```html
<!-- Remote image (must be allowlisted in netlify.toml) -->
<img src="/.netlify/images?url=https://example.com/image.jpg&w=600&fm=webp" />
```

**Important**: Remote image domains must be allowlisted in `netlify.toml`.

## Query Parameters

### Required Parameter

- **`url`**: Image URL (relative path or absolute URL)
  - Relative: `/images/photo.jpg`
  - Remote: `https://example.com/photo.jpg` (must be URI-encoded)

### Size Parameters

- **`w`**: Width in pixels
- **`h`**: Height in pixels

```html
<!-- Fixed width -->
<img src="/.netlify/images?url=/photo.jpg&w=800" />

<!-- Fixed height -->
<img src="/.netlify/images?url=/photo.jpg&h=600" />

<!-- Both dimensions -->
<img src="/.netlify/images?url=/photo.jpg&w=800&h=600" />
```

### Fit Parameter

Controls how the image is resized when both width and height are specified:

- **`contain`**: Fit within dimensions, maintain aspect ratio (default)
- **`cover`**: Fill dimensions, crop if needed
- **`fill`**: Stretch to exact dimensions (may distort)

```html
<!-- Contain: fits within 400x300, maintains aspect ratio -->
<img src="/.netlify/images?url=/photo.jpg&w=400&h=300&fit=contain" />

<!-- Cover: fills 400x300, crops excess -->
<img src="/.netlify/images?url=/photo.jpg&w=400&h=300&fit=cover" />

<!-- Fill: stretches to exactly 400x300 -->
<img src="/.netlify/images?url=/photo.jpg&w=400&h=300&fit=fill" />
```

### Position Parameter

Controls crop alignment when using `fit=cover`:

- **`top`**, **`bottom`**, **`left`**, **`right`**, **`center`** (default)

```html
<!-- Crop from top -->
<img src="/.netlify/images?url=/photo.jpg&w=400&h=300&fit=cover&position=top" />

<!-- Crop from center (default) -->
<img src="/.netlify/images?url=/photo.jpg&w=400&h=300&fit=cover&position=center" />
```

### Format Parameter

Convert image format:

- **`fm`**: `avif`, `webp`, `jpg`, `png`, `gif`, `blurhash`

```html
<!-- Convert to WebP -->
<img src="/.netlify/images?url=/photo.jpg&fm=webp" />

<!-- Convert to AVIF (best compression) -->
<img src="/.netlify/images?url=/photo.jpg&fm=avif" />

<!-- Generate blurhash placeholder -->
<img src="/.netlify/images?url=/photo.jpg&fm=blurhash" />
```

### Quality Parameter

Control lossy compression quality (1-100, default 75):

- **`q`**: Quality level

```html
<!-- High quality (larger file) -->
<img src="/.netlify/images?url=/photo.jpg&fm=webp&q=90" />

<!-- Lower quality (smaller file) -->
<img src="/.netlify/images?url=/photo.jpg&fm=webp&q=60" />
```

## Complete Example

```html
<img 
  src="/.netlify/images?url=/images/hero.jpg&w=1200&h=600&fit=cover&position=center&fm=webp&q=85"
  alt="Hero image"
  loading="lazy"
/>
```

## Remote Images

To use externally hosted images, allowlist domains in `netlify.toml`:

```toml
[images]
  remote_images = [
    "https://images.unsplash.com/.*",
    "https://cdn.example.com/.*"
  ]
```

Then use with URI-encoded URLs:

```html
<!-- URL must be URI-encoded -->
<img src="/.netlify/images?url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-123&w=800&fm=webp" />
```

In JavaScript:

```typescript
const imageUrl = "https://images.unsplash.com/photo-123";
const transformedUrl = `/.netlify/images?url=${encodeURIComponent(imageUrl)}&w=800&fm=webp`;
```

## Redirects and Rewrites

Create custom paths using redirects or rewrites:

### Using netlify.toml

```toml
[[redirects]]
  from = "/img/*"
  to = "/.netlify/images?url=/:splat&w=800&fm=webp&q=80"
  status = 200

[[redirects]]
  from = "/thumbnails/*"
  to = "/.netlify/images?url=/:splat&w=150&h=150&fit=cover"
  status = 200
```

Usage:

```html
<!-- Instead of /.netlify/images?url=/photos/pic.jpg&w=800&fm=webp&q=80 -->
<img src="/img/photos/pic.jpg" />

<!-- Instead of /.netlify/images?url=/photos/pic.jpg&w=150&h=150&fit=cover -->
<img src="/thumbnails/photos/pic.jpg" />
```

### Using _redirects File

```
/img/*  /.netlify/images?url=/:splat&w=800&fm=webp&q=80  200
/thumbnails/*  /.netlify/images?url=/:splat&w=150&h=150&fit=cover  200
```

## Responsive Images

### Using srcset

```html
<img
  src="/.netlify/images?url=/photo.jpg&w=800&fm=webp"
  srcset="
    /.netlify/images?url=/photo.jpg&w=400&fm=webp 400w,
    /.netlify/images?url=/photo.jpg&w=800&fm=webp 800w,
    /.netlify/images?url=/photo.jpg&w=1200&fm=webp 1200w
  "
  sizes="(max-width: 600px) 400px, (max-width: 1200px) 800px, 1200px"
  alt="Responsive image"
/>
```

### Using picture Element

```html
<picture>
  <!-- AVIF for modern browsers -->
  <source
    srcset="
      /.netlify/images?url=/photo.jpg&w=400&fm=avif 400w,
      /.netlify/images?url=/photo.jpg&w=800&fm=avif 800w
    "
    sizes="(max-width: 600px) 400px, 800px"
    type="image/avif"
  />
  
  <!-- WebP fallback -->
  <source
    srcset="
      /.netlify/images?url=/photo.jpg&w=400&fm=webp 400w,
      /.netlify/images?url=/photo.jpg&w=800&fm=webp 800w
    "
    sizes="(max-width: 600px) 400px, 800px"
    type="image/webp"
  />
  
  <!-- JPEG fallback -->
  <img
    src="/.netlify/images?url=/photo.jpg&w=800&fm=jpg"
    alt="Responsive image with format fallbacks"
  />
</picture>
```

## React Component Example

```tsx
interface ImageProps {
  src: string;
  alt: string;
  width?: number;
  height?: number;
  fit?: 'contain' | 'cover' | 'fill';
  format?: 'avif' | 'webp' | 'jpg' | 'png';
  quality?: number;
}

export function OptimizedImage({
  src,
  alt,
  width,
  height,
  fit = 'cover',
  format = 'webp',
  quality = 80,
}: ImageProps) {
  const params = new URLSearchParams({
    url: src,
    ...(width && { w: width.toString() }),
    ...(height && { h: height.toString() }),
    fit,
    fm: format,
    q: quality.toString(),
  });

  const imageUrl = `/.netlify/images?${params.toString()}`;

  return <img src={imageUrl} alt={alt} loading="lazy" />;
}

// Usage
<OptimizedImage
  src="/images/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  format="webp"
  quality={85}
/>
```

## Blurhash Placeholders

Generate low-quality placeholders for lazy loading:

```tsx
import { useState, useEffect } from 'react';

function ImageWithPlaceholder({ src, alt }: { src: string; alt: string }) {
  const [loaded, setLoaded] = useState(false);
  
  const blurhashUrl = `/.netlify/images?url=${encodeURIComponent(src)}&fm=blurhash`;
  const fullUrl = `/.netlify/images?url=${encodeURIComponent(src)}&w=1200&fm=webp&q=80`;
  
  return (
    <div style={{ position: 'relative' }}>
      {/* Blurhash placeholder */}
      <img
        src={blurhashUrl}
        alt=""
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: '100%',
          filter: 'blur(20px)',
          opacity: loaded ? 0 : 1,
          transition: 'opacity 0.3s',
        }}
      />
      
      {/* Full image */}
      <img
        src={fullUrl}
        alt={alt}
        onLoad={() => setLoaded(true)}
        style={{ width: '100%', height: 'auto' }}
      />
    </div>
  );
}
```

## Custom Headers

Apply custom headers to source images (same-domain only):

### Using netlify.toml

```toml
[[headers]]
  for = "/images/*"
  [headers.values]
    Cache-Control = "public, max-age=604800, must-revalidate"
```

### Using _headers File

```
/images/*
  Cache-Control: public, max-age=604800, must-revalidate
```

**Note**: Custom headers only work for images hosted on the same domain, not remote images.

## Framework Integration

### Angular

Uses `NgOptimizedImage` component automatically:

```typescript
import { NgOptimizedImage } from '@angular/common';

@Component({
  selector: 'app-hero',
  standalone: true,
  imports: [NgOptimizedImage],
  template: `
    <img 
      ngSrc="/images/hero.jpg" 
      width="1200" 
      height="600"
      priority
    />
  `
})
```

### Astro

Uses `<Image />` component automatically:

```astro
---
import { Image } from 'astro:assets';
import heroImage from '../images/hero.jpg';
---

<Image src={heroImage} alt="Hero" width={1200} height={600} />
```

### Next.js

Configure `remotePatterns` in `next.config.js`:

```javascript
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
    ],
  },
};
```

### Nuxt

Uses `nuxt/image` module automatically:

```vue
<template>
  <NuxtImg src="/images/hero.jpg" width="1200" height="600" />
</template>
```

## Caching Behavior

- Transformed images are cached at the edge
- Source images are cached for future transformations
- Cache is invalidated on new deploys
- Use asset fingerprinting for fine-grained cache control

```html
<!-- Cache-busted URL -->
<img src="/.netlify/images?url=/images/hero.abc123.jpg&w=800&fm=webp" />
```

## Performance Best Practices

1. **Use modern formats**: AVIF > WebP > JPEG
2. **Optimize quality**: 80-85 is usually sufficient
3. **Lazy load**: Add `loading="lazy"` to off-screen images
4. **Responsive images**: Use `srcset` and `sizes`
5. **Provide dimensions**: Prevents layout shift
6. **Use blurhash**: For smooth loading experience
7. **Cache-bust**: Use fingerprinted filenames for long cache times

```html
<img
  src="/.netlify/images?url=/hero.jpg&w=800&fm=webp&q=85"
  srcset="
    /.netlify/images?url=/hero.jpg&w=400&fm=webp&q=85 400w,
    /.netlify/images?url=/hero.jpg&w=800&fm=webp&q=85 800w,
    /.netlify/images?url=/hero.jpg&w=1200&fm=webp&q=85 1200w
  "
  sizes="(max-width: 600px) 400px, (max-width: 1200px) 800px, 1200px"
  width="800"
  height="600"
  loading="lazy"
  alt="Hero image"
/>
```

## Common Patterns

### Art Direction

```html
<picture>
  <!-- Mobile: portrait crop -->
  <source
    media="(max-width: 600px)"
    srcset="/.netlify/images?url=/hero.jpg&w=600&h=800&fit=cover&position=center"
  />
  
  <!-- Desktop: landscape crop -->
  <source
    media="(min-width: 601px)"
    srcset="/.netlify/images?url=/hero.jpg&w=1200&h=600&fit=cover&position=center"
  />
  
  <img src="/.netlify/images?url=/hero.jpg&w=1200" alt="Hero" />
</picture>
```

### Dynamic Gallery

```tsx
function Gallery({ images }: { images: string[] }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {images.map((src, i) => (
        <img
          key={i}
          src={`/.netlify/images?url=${encodeURIComponent(src)}&w=400&h=400&fit=cover&fm=webp&q=80`}
          alt={`Gallery image ${i + 1}`}
          loading="lazy"
        />
      ))}
    </div>
  );
}
```

### User Avatars

```tsx
function Avatar({ src, size = 40 }: { src: string; size?: number }) {
  const avatarUrl = `/.netlify/images?url=${encodeURIComponent(src)}&w=${size}&h=${size}&fit=cover&fm=webp&q=90`;
  
  return (
    <img
      src={avatarUrl}
      alt="User avatar"
      width={size}
      height={size}
      className="rounded-full"
    />
  );
}
```

## Limitations

- **Remote images**: Must be allowlisted in `netlify.toml`
- **Circular dependencies**: Avoid redirects that create loops
- **Custom headers**: Only work for same-domain images
- **Rewritten static targets**: Image CDN doesn't execute for rewritten static files

## Troubleshooting

**Remote images not working**
- Ensure domain is allowlisted in `netlify.toml` under `[images]`
- Verify URL is properly URI-encoded
- Check that the remote server allows hotlinking

**Images not transforming**
- Verify the source image exists and is accessible
- Check query parameter syntax
- Ensure no conflicting redirects

**Poor quality**
- Increase `q` parameter (default is 75)
- Try different format (`avif` has best compression)
- Check source image quality

**Slow loading**
- Use lazy loading for off-screen images
- Implement progressive loading with blurhash
- Optimize source images before uploading
