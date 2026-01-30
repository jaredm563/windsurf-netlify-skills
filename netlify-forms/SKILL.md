---
name: netlify-forms
description: Handle Netlify Forms including HTML form setup, spam filtering with honeypot fields, AJAX submissions, and form notifications. Use when implementing contact forms, signup forms, or any form submission handling on Netlify-hosted sites.
license: Apache-2.0
metadata:
  author: netlify
  version: "1.0"
---

# Netlify Forms

Netlify Forms automatically handles form submissions without requiring server-side code. Forms are detected at build time and submissions are stored in the Netlify dashboard.

## When to Use

- Contact forms on static sites
- User signups or feedback forms
- Newsletter subscriptions
- Survey or questionnaire submissions
- Job applications or inquiries
- Any form submission without a backend

## Basic HTML Form

Add `data-netlify="true"` to any HTML form:

```html
<form name="contact" method="POST" data-netlify="true">
  <input type="hidden" name="form-name" value="contact" />
  
  <p>
    <label>Name: <input type="text" name="name" required /></label>
  </p>
  
  <p>
    <label>Email: <input type="email" name="email" required /></label>
  </p>
  
  <p>
    <label>Message: <textarea name="message" required></textarea></label>
  </p>
  
  <p>
    <button type="submit">Send</button>
  </p>
</form>
```

**Critical**: The hidden `form-name` input MUST match the form's `name` attribute.

## Spam Filtering with Honeypot

Add a honeypot field that bots will fill but humans won't see:

```html
<form name="contact" method="POST" data-netlify="true" netlify-honeypot="bot-field">
  <input type="hidden" name="form-name" value="contact" />
  
  <!-- Honeypot field - hidden from humans -->
  <p class="hidden" style="display:none;">
    <label>Don't fill this out: <input name="bot-field" /></label>
  </p>
  
  <p>
    <label>Name: <input type="text" name="name" required /></label>
  </p>
  
  <p>
    <label>Email: <input type="email" name="email" required /></label>
  </p>
  
  <p>
    <label>Message: <textarea name="message" required></textarea></label>
  </p>
  
  <p>
    <button type="submit">Send</button>
  </p>
</form>
```

**Best Practice**: Always use honeypot fields to prevent spam submissions.

## AJAX/JavaScript Submission

For SPAs or enhanced UX, submit forms via JavaScript:

```typescript
async function handleSubmit(event: Event) {
  event.preventDefault();
  
  const form = event.target as HTMLFormElement;
  const formData = new FormData(form);
  
  try {
    const response = await fetch('/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams(formData as any).toString(),
    });
    
    if (response.ok) {
      console.log('Form submitted successfully');
      form.reset();
    } else {
      throw new Error('Form submission failed');
    }
  } catch (error) {
    console.error('Error:', error);
  }
}

const form = document.querySelector('form');
form?.addEventListener('submit', handleSubmit);
```

**Important**: Even with AJAX submission, you need the form HTML present in your built output for Netlify to detect it.

## React Component Example

```tsx
import { useState, FormEvent } from 'react';

export function ContactForm() {
  const [status, setStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle');

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus('submitting');

    const form = e.currentTarget;
    const formData = new FormData(form);

    try {
      const response = await fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(formData as any).toString(),
      });

      if (response.ok) {
        setStatus('success');
        form.reset();
      } else {
        setStatus('error');
      }
    } catch {
      setStatus('error');
    }
  }

  if (status === 'success') {
    return (
      <div className="success-message">
        <h2>Thank you for your message!</h2>
        <p>We'll get back to you soon.</p>
      </div>
    );
  }

  return (
    <form 
      name="contact" 
      method="POST" 
      data-netlify="true" 
      netlify-honeypot="bot-field"
      onSubmit={handleSubmit}
    >
      <input type="hidden" name="form-name" value="contact" />
      
      <p style={{ display: 'none' }}>
        <label>
          Don't fill this out: <input name="bot-field" />
        </label>
      </p>
      
      <div>
        <label htmlFor="name">Name</label>
        <input 
          type="text" 
          id="name" 
          name="name" 
          required 
          disabled={status === 'submitting'}
        />
      </div>
      
      <div>
        <label htmlFor="email">Email</label>
        <input 
          type="email" 
          id="email" 
          name="email" 
          required 
          disabled={status === 'submitting'}
        />
      </div>
      
      <div>
        <label htmlFor="message">Message</label>
        <textarea 
          id="message" 
          name="message" 
          required 
          disabled={status === 'submitting'}
        />
      </div>
      
      <button type="submit" disabled={status === 'submitting'}>
        {status === 'submitting' ? 'Sending...' : 'Send'}
      </button>
      
      {status === 'error' && (
        <p className="error">Something went wrong. Please try again.</p>
      )}
    </form>
  );
}
```

## SPA/Framework Considerations

For React, Vue, or other SPAs where forms are rendered client-side, you need to ensure the form HTML exists at build time.

### Option A: Hidden Static Form

Include a hidden static HTML form in your `index.html` or a static file:

```html
<!-- In public/index.html or a static HTML file -->
<form name="contact" netlify netlify-honeypot="bot-field" hidden>
  <input type="text" name="name" />
  <input type="email" name="email" />
  <textarea name="message"></textarea>
</form>
```

### Option B: SSR/Prerendering

Use server-side rendering or prerendering to include the form markup at build time.

### Option C: Build Plugin

For Next.js or other frameworks, the form may be detected during the build process if it's rendered in a page component.

## File Uploads

Forms can accept file uploads:

```html
<form 
  name="upload" 
  method="POST" 
  data-netlify="true" 
  enctype="multipart/form-data"
>
  <input type="hidden" name="form-name" value="upload" />
  
  <p>
    <label>
      Upload file: 
      <input type="file" name="attachment" required />
    </label>
  </p>
  
  <p>
    <label>
      Description: 
      <textarea name="description"></textarea>
    </label>
  </p>
  
  <button type="submit">Upload</button>
</form>
```

**Limits**: 
- Max 10MB per file
- Max 10MB total per submission
- Files are stored with the submission

## Custom Success Page

Redirect to a thank-you page after submission:

```html
<form 
  name="contact" 
  method="POST" 
  data-netlify="true" 
  action="/thank-you"
>
  <input type="hidden" name="form-name" value="contact" />
  <!-- form fields -->
</form>
```

Create a `/thank-you` page:

```html
<!-- thank-you.html -->
<!DOCTYPE html>
<html>
<head>
  <title>Thank You</title>
</head>
<body>
  <h1>Thank you for your submission!</h1>
  <p>We'll get back to you soon.</p>
  <a href="/">Return to home</a>
</body>
</html>
```

## Form Notifications

Configure email notifications in Netlify UI:

1. Go to **Site settings → Forms → Form notifications**
2. Click "Add notification"
3. Choose notification type:
   - **Email notification**: Send to specific email addresses
   - **Slack notification**: Post to Slack channel
   - **Webhook**: POST to custom endpoint
   - **Outgoing webhook**: Zapier, IFTTT, etc.
4. Configure settings and save

### Email Notification Example

- **Event to listen for**: New form submission
- **Form**: Select your form (e.g., "contact")
- **Email to notify**: `team@example.com`
- **Email subject**: `New contact form submission`

### Webhook Example

POST submission data to your endpoint:

```json
{
  "form_name": "contact",
  "form_id": "abc123",
  "site_url": "https://example.com",
  "data": {
    "name": "John Doe",
    "email": "john@example.com",
    "message": "Hello!"
  },
  "ordered_human_fields": [
    {"title": "Name", "name": "name", "value": "John Doe"},
    {"title": "Email", "name": "email", "value": "john@example.com"},
    {"title": "Message", "name": "message", "value": "Hello!"}
  ]
}
```

## reCAPTCHA Integration

Add Google reCAPTCHA v2 for additional spam protection:

```html
<form 
  name="contact" 
  method="POST" 
  data-netlify="true" 
  data-netlify-recaptcha="true"
>
  <input type="hidden" name="form-name" value="contact" />
  
  <p>
    <label>Name: <input type="text" name="name" required /></label>
  </p>
  
  <p>
    <label>Email: <input type="email" name="email" required /></label>
  </p>
  
  <!-- reCAPTCHA widget will be inserted here -->
  <div data-netlify-recaptcha="true"></div>
  
  <button type="submit">Send</button>
</form>
```

**Note**: Netlify handles the reCAPTCHA integration automatically. No API keys needed.

## Viewing Submissions

Access form submissions in Netlify UI:

1. Go to **Site settings → Forms**
2. Click on your form name
3. View submissions, export data, or mark as spam

### Export Submissions

- Click "Export" to download as CSV
- Includes all form fields and submission metadata

## Common Patterns

### Newsletter Signup

```html
<form name="newsletter" method="POST" data-netlify="true">
  <input type="hidden" name="form-name" value="newsletter" />
  
  <label>
    Email: 
    <input type="email" name="email" required placeholder="you@example.com" />
  </label>
  
  <button type="submit">Subscribe</button>
</form>
```

### Multi-Step Form

```tsx
import { useState } from 'react';

export function MultiStepForm() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    company: '',
    message: '',
  });

  function handleChange(e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    
    const response = await fetch('/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        'form-name': 'multi-step',
        ...formData,
      }).toString(),
    });
    
    if (response.ok) {
      setStep(3);
    }
  }

  return (
    <>
      {/* Hidden form for Netlify detection */}
      <form name="multi-step" netlify netlify-honeypot="bot-field" hidden>
        <input type="text" name="name" />
        <input type="email" name="email" />
        <input type="text" name="company" />
        <textarea name="message" />
      </form>

      {/* Visible multi-step form */}
      {step === 1 && (
        <div>
          <h2>Step 1: Your Info</h2>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            placeholder="Name"
            required
          />
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            placeholder="Email"
            required
          />
          <button onClick={() => setStep(2)}>Next</button>
        </div>
      )}

      {step === 2 && (
        <form onSubmit={handleSubmit}>
          <h2>Step 2: Details</h2>
          <input
            type="text"
            name="company"
            value={formData.company}
            onChange={handleChange}
            placeholder="Company"
          />
          <textarea
            name="message"
            value={formData.message}
            onChange={handleChange}
            placeholder="Message"
            required
          />
          <button type="button" onClick={() => setStep(1)}>Back</button>
          <button type="submit">Submit</button>
        </form>
      )}

      {step === 3 && (
        <div>
          <h2>Thank you!</h2>
          <p>Your submission has been received.</p>
        </div>
      )}
    </>
  );
}
```

### Conditional Fields

```html
<form name="inquiry" method="POST" data-netlify="true">
  <input type="hidden" name="form-name" value="inquiry" />
  
  <p>
    <label>
      Inquiry Type:
      <select name="type" id="inquiry-type" required>
        <option value="">Select...</option>
        <option value="sales">Sales</option>
        <option value="support">Support</option>
        <option value="other">Other</option>
      </select>
    </label>
  </p>
  
  <p id="company-field" style="display:none;">
    <label>
      Company:
      <input type="text" name="company" />
    </label>
  </p>
  
  <p>
    <label>Message: <textarea name="message" required></textarea></label>
  </p>
  
  <button type="submit">Send</button>
  
  <script>
    document.getElementById('inquiry-type').addEventListener('change', (e) => {
      const companyField = document.getElementById('company-field');
      companyField.style.display = e.target.value === 'sales' ? 'block' : 'none';
    });
  </script>
</form>
```

## Troubleshooting

### Form Not Detected

**Ensure form exists at build time**:
- For SPAs, include a hidden static form in `index.html`
- Or use SSR/prerendering to generate form HTML

**Check attributes**:
- `data-netlify="true"` is present
- `name` attribute matches hidden `form-name` value
- Form is not inside a conditional that prevents build-time rendering

### Submissions Not Appearing

**Check the Forms tab** in Netlify dashboard:
- Navigate to Site settings → Forms
- Look for your form name
- Check spam folder

**Verify form name**:
- Hidden input `form-name` value must match form's `name` attribute exactly

### 404 on Submission

**Post to correct URL**:
- Post to `/` or the page URL where the form exists
- Include `Content-Type: application/x-www-form-urlencoded` header for AJAX

**Check action attribute**:
- If using custom success page, ensure it exists

### AJAX Submission Not Working

**Include Content-Type header**:
```typescript
fetch('/', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams(formData).toString(),
});
```

**Ensure form-name is included**:
```html
<input type="hidden" name="form-name" value="contact" />
```

## Best Practices

1. **Always use honeypot fields** to prevent spam
2. **Include hidden form-name input** matching the form's name attribute
3. **For SPAs, include static form** in HTML for detection
4. **Use reCAPTCHA** for high-traffic forms
5. **Provide user feedback** during submission (loading state)
6. **Show success/error messages** after submission
7. **Validate on client and server** (Netlify validates required fields)
8. **Set up notifications** to be alerted of new submissions
9. **Export submissions regularly** for backup
10. **Test forms** before deploying to production

## Limits

- **Free plan**: 100 submissions/month
- **Pro plan**: 1,000 submissions/month
- **Business plan**: 10,000 submissions/month
- **File uploads**: 10MB per file, 10MB total per submission
- **Spam filtering**: Included (honeypot, reCAPTCHA)

## Security

- Netlify automatically sanitizes form submissions
- Honeypot fields filter bot submissions
- reCAPTCHA provides additional protection
- Submissions are stored securely in Netlify dashboard
- Email notifications don't expose sensitive data
- HTTPS is enforced for all form submissions
