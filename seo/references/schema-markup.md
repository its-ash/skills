# Schema Markup

Implement JSON‑LD schema.org markup so search engines can understand page content and generate rich results.

## When to use
- You need to add new schema markup to a page.
- Existing markup has errors or is missing required fields.
- You want to improve or expand the types of rich results (FAQ, Product, Breadcrumb, etc.).
- You are auditing a site for structured‑data compliance.

---

## Workflow
1. **Identify page type** – Determine the primary content (article, product, FAQ, event, etc.).
2. **Select schema type(s)** – Choose one or more schema.org types that match the content.
3. **Gather required data** – Collect values for all required properties (e.g., `name`, `url`, `price`).
4. **Create JSON‑LD** – Write the markup using the JSON‑LD format.
5. **Place the script** – Insert the `<script type="application/ld+json">` block in the `<head>` or at the end of `<body>`.
6. **Validate** – Run the markup through Google Rich Results Test and the Schema.org validator.
7. **Deploy** – Publish the changes and monitor Google Search Console for errors or enhancements.
8. **Maintain** – Update the markup whenever the underlying content changes.

---

## Core Principles
- **Accuracy first** – Markup must reflect the visible content. Do not add fields for information that does not exist on the page.
- **Use JSON‑LD** – Preferred by Google; easier to maintain and does not interfere with HTML.
- **Follow Google’s supported types** – Only implement schema types that Google can display as rich results.
- **Validate before publishing** – Catch syntax errors, missing required properties, and mismatched values early.

---

## Common Schema Types
Below are the most frequently used types, their required and recommended properties, and a minimal JSON‑LD example.

### Organization
- **Required**: `name`, `url`
- **Recommended**: `logo`, `sameAs`, `contactPoint`
```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Example Company",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "sameAs": [
    "https://twitter.com/example",
    "https://linkedin.com/company/example"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-555-5555",
    "contactType": "customer service"
  }
}
```

### WebSite (with SearchAction)
- **Required**: `name`, `url`
- **Search box**: `potentialAction` → `SearchAction`
```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Example",
  "url": "https://example.com",
  "potentialAction": {
    "@type": "SearchAction",
    "target": {
      "@type": "EntryPoint",
      "urlTemplate": "https://example.com/search?q={search_term_string}"
    },
    "query-input": "required name=search_term_string"
  }
}
```

### Article / BlogPosting
- **Required**: `headline`, `image`, `datePublished`, `author`
- **Recommended**: `dateModified`, `publisher`, `description`, `mainEntityOfPage`
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "How to Implement Schema Markup",
  "image": "https://example.com/image.jpg",
  "datePublished": "2024-01-15T08:00:00+00:00",
  "author": {"@type": "Person", "name": "Jane Doe"},
  "publisher": {
    "@type": "Organization",
    "name": "Example Company",
    "logo": {"@type": "ImageObject", "url": "https://example.com/logo.png"}
  },
  "description": "A guide to schema markup.",
  "mainEntityOfPage": {"@type": "WebPage", "@id": "https://example.com/schema-guide"}
}
```

### Product
- **Required**: `name`, `image`, `offers`
- **Recommended**: `description`, `sku`, `brand`, `aggregateRating`, `review`
```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Premium Widget",
  "image": "https://example.com/widget.jpg",
  "description": "Best‑selling widget for professionals",
  "sku": "WIDGET-001",
  "brand": {"@type": "Brand", "name": "Example Co"},
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/products/widget",
    "priceCurrency": "USD",
    "price": "99.99",
    "availability": "https://schema.org/InStock",
    "priceValidUntil": "2024-12-31"
  },
  "aggregateRating": {"@type": "AggregateRating", "ratingValue": "4.8", "reviewCount": "127"}
}
```

### FAQPage
- **Required**: `mainEntity` (array of `Question`/`Answer`)
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is schema markup?",
      "acceptedAnswer": {"@type": "Answer", "text": "Schema markup is a structured‑data vocabulary that helps search engines understand your content."}
    },
    {
      "@type": "Question",
      "name": "How do I implement schema?",
      "acceptedAnswer": {"@type": "Answer", "text": "Use JSON‑LD and place the script in the page head."}
    }
  ]
}
```

### BreadcrumbList
- **Required**: `itemListElement` (ordered `ListItem` objects)
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com"},
    {"@type": "ListItem", "position": 2, "name": "Blog", "item": "https://example.com/blog"},
    {"@type": "ListItem", "position": 3, "name": "SEO Guide", "item": "https://example.com/blog/seo-guide"}
  ]
}
```

### LocalBusiness
- **Required**: `name`, `address`
- **Recommended**: `image`, `geo`, `telephone`, `openingHoursSpecification`, `priceRange`
```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Example Coffee Shop",
  "image": "https://example.com/shop.jpg",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main Street",
    "addressLocality": "San Francisco",
    "addressRegion": "CA",
    "postalCode": "94102",
    "addressCountry": "US"
  },
  "geo": {"@type": "GeoCoordinates", "latitude": "37.7749", "longitude": "-122.4194"},
  "telephone": "+1-555-555-5555",
  "openingHoursSpecification": [{
    "@type": "OpeningHoursSpecification",
    "dayOfWeek": ["Monday","Tuesday","Wednesday","Thursday","Friday"],
    "opens": "08:00",
    "closes": "18:00"
  }],
  "priceRange": "$$"
}
```

### Review / AggregateRating (on Product or Service)
- **Required for rating**: `aggregateRating` with `ratingValue` and `ratingCount`
- **Optional**: `review` array with `author`, `datePublished`, `reviewRating`, `reviewBody`
> **Note:** Reviews must be from real customers; self‑generated reviews violate Google policies.
```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Example Product",
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "bestRating": "5",
    "worstRating": "1",
    "ratingCount": "523"
  },
  "review": [{
    "@type": "Review",
    "author": {"@type": "Person", "name": "John Smith"},
    "datePublished": "2024-01-10",
    "reviewRating": {"@type": "Rating", "ratingValue": "5"},
    "reviewBody": "Excellent product, exceeded my expectations."
  }]
}
```

### Event
- **Required**: `name`, `startDate`, `location` (or `eventAttendanceMode` for online)
```json
{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "Annual Marketing Conference",
  "startDate": "2024-06-15T09:00:00-07:00",
  "endDate": "2024-06-15T17:00:00-07:00",
  "eventAttendanceMode": "https://schema.org/OnlineEventAttendanceMode",
  "location": {"@type": "VirtualLocation", "url": "https://example.com/conference"},
  "image": "https://example.com/conference.jpg",
  "description": "Join us for our annual marketing conference...",
  "offers": {"@type": "Offer", "url": "https://example.com/conference/tickets", "price": "199", "priceCurrency": "USD", "availability": "https://schema.org/InStock", "validFrom": "2024-01-01"},
  "organizer": {"@type": "Organization", "name": "Example Company", "url": "https://example.com"}
}
```

---

## Validation & Testing
- **Google Rich Results Test** – https://search.google.com/test/rich-results
- **Schema.org Validator** – https://validator.schema.org/
- **Search Console** – Check *Enhancements* reports for errors and warnings.

### Common errors to watch for
- Missing required properties (Google may require more than the schema.org minimum).
- Invalid date format – use ISO 8601 (`YYYY-MM-DD` or `YYYY-MM-DDThh:mm:ss±hh:mm`).
- URLs must be absolute and start with `http://` or `https://`.
- Enumeration values must match exact schema.org terms (e.g., `InStock`).
- Content mismatch – markup must reflect what users see on the page.

---

## Implementation Patterns
### Static sites (HTML, Jekyll, Hugo)
- Insert JSON‑LD directly in the page template.
- Use partials/includes for reusable snippets (e.g., Organization markup).

### Dynamic frameworks (React, Next.js, Vue)
- Create a component that renders a `<script type="application/ld+json">` tag.
- Server‑side render the markup for SEO.
```jsx
// Example for Next.js
export default function ProductPage({ product }) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: product.name,
    image: product.image,
    description: product.description,
    sku: product.sku,
    brand: {"@type": "Brand", name: product.brand},
    offers: {
      "@type": "Offer",
      url: product.url,
      priceCurrency: "USD",
      price: product.price,
      availability: "https://schema.org/InStock"
    }
  };
  return (
    <>
      <Head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
        />
      </Head>
      {/* page content */}
    </>
  );
}
```

### CMS platforms (WordPress, Drupal)
- Use SEO plugins that generate schema (Yoast SEO, Rank Math, Schema Pro).
- For custom data, add schema via theme `functions.php` or a dedicated plugin that outputs JSON‑LD.

---

## Checklist
- [ ] Identify page type and desired rich result.
- [ ] Choose appropriate schema.org type(s).
- [ ] Gather all required property values.
- [ ] Write JSON‑LD adhering to Google’s supported fields.
- [ ] Place the script in `<head>` or before `</body>`.
- [ ] Run Google Rich Results Test – no errors.
- [ ] Verify URLs, dates, and enumerations are correctly formatted.
- [ ] Check Search Console after deployment for enhancements and warnings.
- [ ] Update markup when page content changes.

---

## Questions to Ask the User
- What kind of page are you working on (article, product, FAQ, etc.)?
- Which rich results are you targeting?
- Do you already have schema on the page? If so, share the existing markup.
- What data sources are available to populate the required fields?
- What tech stack does the site use (static HTML, CMS, React, etc.)?
