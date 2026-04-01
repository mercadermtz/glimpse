# 🏗️ GLIMPSE - Complete Architecture Guide

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER'S iPhone                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    GLIMPSE iOS App                       │   │
│  │  ┌────────────────┐  ┌────────────────┐  ┌───────────┐  │   │
│  │  │  SwiftUI UI    │  │  AVFoundation  │  │  Vision   │  │   │
│  │  │  (Home + Cam)  │  │  (Camera)      │  │  CoreML   │  │   │
│  │  └────────────────┘  └────────────────┘  └───────────┘  │   │
│  │           ↓                  ↓                  ↓        │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │       URLSession (HTTP Client)                  │   │   │
│  │  │       POST /glimpse/search_prices               │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ↓ (HTTPS)                               │
│                    [Internet/Network]                            │
│                          ↓                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           GOOGLE CLOUD / FIREBASE                        │   │
│  │  ┌──────────────────────────────────────────────────┐    │   │
│  │  │     Cloud Functions (Python 3.11)               │    │   │
│  │  │     search_prices(product_name) → prices        │    │   │
│  │  └──────────────────────────────────────────────────┘    │   │
│  │           ↓                           ↓                  │   │
│  │  ┌──────────────────────┐  ┌─────────────────────────┐  │   │
│  │  │ Firestore Cache      │  │ Price Aggregator       │  │   │
│  │  │ (5-min TTL)          │  │ (Parallel scraping)    │  │   │
│  │  │ price_cache/         │  │ (asyncio.gather)       │  │   │
│  │  └──────────────────────┘  └─────────────────────────┘  │   │
│  │                                      ↓                   │   │
│  │                   ┌──────────────────────────────┐       │   │
│  │                   │ 100+ Retail Websites         │       │   │
│  │                   │ ├─ Mercado Libre API         │       │   │
│  │                   │ ├─ OLX API                   │       │   │
│  │                   │ ├─ Amazon API                │       │   │
│  │                   │ ├─ Carrefour.ar (scraped)    │       │   │
│  │                   │ ├─ Falabella (scraped)       │       │   │
│  │                   │ └─ 95+ more sites            │       │   │
│  │                   └──────────────────────────────┘       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### Complete User Journey (Request → Response)

```
1️⃣  USER ACTION (iPhone)
    User opens GLIMPSE app
    User taps camera icon
    User points iPhone at product (e.g., iPhone case)

2️⃣  VISION DETECTION (On-Device, ~200ms)
    Vision Framework captures frame from camera
    CoreML model analyzes image
    Model detects: "iPhone case" (confidence: 85%)
    ↓
    iPhone sends HTTP POST to backend
    {
      "product_name": "iPhone case",
      "confidence": 0.85,
      "timestamp": "2026-04-15T10:30:00Z"
    }

3️⃣  FIREBASE RECEIVES REQUEST (~50ms)
    Cloud Function triggered: search_prices()
    ↓
    Check Firestore cache
    Cache key: hash("iPhone case")
    
    IF cache_hit:
      ├─ Retrieve cached result
      ├─ Verify TTL (5 minutes)
      └─ Return immediately (~50ms) ✅ FAST PATH

    IF cache_miss:
      └─ Proceed to step 4

4️⃣  PARALLEL PRICE SCRAPING (~600ms)
    asyncio.gather() launched with 100 tasks
    
    All sites queried simultaneously:
    ├─ Mercado Libre API (aiohttp)          → 300ms
    ├─ OLX API (aiohttp)                    → 400ms
    ├─ Amazon API (aiohttp)                 → 350ms
    ├─ Carrefour scraper (BeautifulSoup)    → 550ms
    ├─ Falabella scraper (BeautifulSoup)    → 520ms
    └─ 95+ more (asyncio runs all in parallel)
    
    ACTUAL TIME: ~600ms (bottleneck is slowest site)
    NOT: 600ms × 100 = 60,000ms ❌

5️⃣  AGGREGATE & SORT (~50ms)
    Collect all results
    Parse prices from each source
    Convert to ARS (if needed)
    Sort by price (ascending)
    Find cheapest
    
    Result:
    {
      "product": "iPhone case",
      "cheapest": {
        "price": 2890,
        "currency": "ARS",
        "source": "mercado_libre",
        "url": "https://..."
      },
      "alternatives": [
        {"price": 2950, "source": "olx", ...},
        {"price": 3100, "source": "amazon", ...},
        {"price": 3200, "source": "carrefour", ...}
      ],
      "timestamp": "2026-04-15T10:30:00Z"
    }

6️⃣  CACHE RESULT (~50ms)
    Save result to Firestore
    document: price_cache/{hash}
    data: {
      result: {...},
      expires: now + 5min,
      created_at: now
    }

7️⃣  RETURN TO iPhone (~100ms network)
    Cloud Function sends HTTP 200 with JSON response
    iPhone receives response in URLSession completion handler

8️⃣  DISPLAY RESULTS (~50ms)
    Parse JSON response
    Update SwiftUI state
    Animate UI (fade in)
    Show:
    ├─ Cheapest: ARS 2,890 (Mercado Libre)
    ├─ Also from: OLX (2,950), Amazon (3,100)
    └─ ✅ DONE

TOTAL TIME: ~800ms (feels instant!) ✅
```

---

## 📱 iOS Layer Architecture

### Component Hierarchy

```
ContentView (Root)
├── HomeScreen
│   ├── Logo (GLIMPSE)
│   └── OpenCameraButton
│
└── CameraScreen (Conditional)
    ├── CameraPreview
    │   ├── AVFoundation.Session
    │   ├── Vision.Requests
    │   └── CoreML.VNCoreMLModel
    │
    ├── DetectionOverlay
    │   ├── Confidence badge (e.g., "85%")
    │   ├── Product name label
    │   └─── Loading indicator
    │
    └── PriceResults
        ├── CheapestPrice
        │   ├── Price (ARS 2,890)
        │   ├── Source (Mercado Libre)
        │   └─ Button (Go to store)
        │
        ├── AlternativePrices
        │   ├─ OLX: 2,950
        │   ├─ Amazon: 3,100
        │   └─ Carrefour: 3,200
        │
        └── Back Button
```

### Data Models

```swift
// Product detection result
struct DetectionResult {
    let product: String              // "iPhone case"
    let confidence: Float            // 0.85
    let timestamp: Date
}

// API Response from backend
struct PriceSearchResponse: Codable {
    struct PriceSource: Codable {
        let price: Int              // in ARS
        let currency: String        // "ARS"
        let source: String          // "mercado_libre"
        let url: String
    }
    
    let product: String
    let cheapest: PriceSource
    let alternatives: [PriceSource]
    let timestamp: Date
}

// ViewModel state
@MainActor
class CameraViewModel: ObservableObject {
    @Published var isDetecting = false
    @Published var detectedProduct: String?
    @Published var confidence: Float = 0.0
    @Published var prices: PriceSearchResponse?
    @Published var error: String?
    @Published var isLoading = false
}
```

### URLSession Integration

```swift
func searchPrices(product: String) async throws -> PriceSearchResponse {
    let url = URL(string: "https://us-central1-glimpse-ar.cloudfunctions.net/search_prices")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = ["product_name": product]
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.invalidResponse
    }
    
    return try JSONDecoder().decode(PriceSearchResponse.self, from: data)
}
```

---

## ☁️ Backend Layer Architecture

### Cloud Function Structure

```python
# functions/main.py

from flask import Request, jsonify
import functions_framework
from scrapers import ScraperFactory
from cache import FirestoreCache
import asyncio
from typing import Dict, List

@functions_framework.http
def search_prices(request: Request):
    """
    HTTP Cloud Function for price search
    
    Request:
        POST /search_prices
        Content-Type: application/json
        Body: {"product_name": "iPhone case"}
    
    Response:
        Content-Type: application/json
        Body: {
            "product": "iPhone case",
            "cheapest": {...},
            "alternatives": [...],
            "timestamp": "2026-04-15T10:30:00Z"
        }
    """
    
    # Parse request
    request_json = request.get_json()
    product_name = request_json.get('product_name')
    
    # Check cache
    cache = FirestoreCache()
    cached_result = cache.get(product_name)
    if cached_result and not cache.is_expired(cached_result):
        return jsonify(cached_result), 200
    
    # Scrape prices (parallel)
    scraper_factory = ScraperFactory()
    results = asyncio.run(scraper_factory.scrape_all(product_name))
    
    # Aggregate & sort
    aggregated = aggregate_prices(results)
    
    # Cache result
    cache.set(product_name, aggregated, ttl_seconds=300)
    
    return jsonify(aggregated), 200


async def scrape_all(product_name: str) -> Dict:
    """Scrape all sources in parallel"""
    tasks = [
        ScraperFactory.scrape_mercado_libre(product_name),
        ScraperFactory.scrape_olx(product_name),
        ScraperFactory.scrape_amazon(product_name),
        ScraperFactory.scrape_carrefour(product_name),
        ScraperFactory.scrape_falabella(product_name),
        # ... 95+ more
    ]
    
    results = await asyncio.gather(*tasks, return_exceptions=True)
    return {result for result in results if isinstance(result, dict)}


def aggregate_prices(results: List[Dict]) -> Dict:
    """Find cheapest and alternatives"""
    prices = [(r['price'], r['source'], r['url']) for r in results]
    prices.sort(key=lambda x: x[0])  # Sort by price
    
    cheapest = prices[0]
    alternatives = prices[1:4]  # Top 3 alternatives
    
    return {
        "product": "...",
        "cheapest": {
            "price": cheapest[0],
            "source": cheapest[1],
            "url": cheapest[2]
        },
        "alternatives": [
            {"price": alt[0], "source": alt[1], "url": alt[2]}
            for alt in alternatives
        ],
        "timestamp": datetime.now().isoformat()
    }
```

### Firestore Schema

```
firestore/
├── price_cache/ (Collection)
│   └── {product_hash} (Document)
│       ├── result: {
│       │   "product": "iPhone case",
│       │   "cheapest": {...},
│       │   "alternatives": [...]
│       │ }
│       ├── expires: Timestamp (now + 5 min)
│       ├── created_at: Timestamp
│       └── source_count: Number (how many sources)
│
└── scraping_logs/ (Collection, optional)
    └── {auto_id} (Document)
        ├── timestamp: Timestamp
        ├── product_name: String
        ├── duration_ms: Number
        ├── success_count: Number
        ├── error_count: Number
        └── failed_sources: Array
```

---

## 🔗 API Contract

### Request Format

```http
POST https://us-central1-glimpse-ar.cloudfunctions.net/search_prices
Content-Type: application/json

{
  "product_name": "iPhone 14 Pro case",
  "confidence": 0.85,
  "timestamp": "2026-04-15T10:30:00Z"
}
```

### Response Format (Success)

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "product": "iPhone 14 Pro case",
  "cheapest": {
    "price": 2890,
    "currency": "ARS",
    "source": "mercado_libre",
    "url": "https://articulo.mercadolibre.com.ar/..."
  },
  "alternatives": [
    {
      "price": 2950,
      "currency": "ARS",
      "source": "olx",
      "url": "https://www.olx.com.ar/..."
    },
    {
      "price": 3100,
      "currency": "ARS",
      "source": "amazon",
      "url": "https://www.amazon.com/-/es/..."
    },
    {
      "price": 3200,
      "currency": "ARS",
      "source": "carrefour",
      "url": "https://www.carrefour.com.ar/..."
    }
  ],
  "timestamp": "2026-04-15T10:30:00Z",
  "cached": false,
  "sources_queried": 100
}
```

### Response Format (Error)

```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "error": "No prices found",
  "product": "iPhone case",
  "timestamp": "2026-04-15T10:30:00Z",
  "cache_fallback": {
    "price": 2890,
    "source": "cache",
    "note": "Showing cached result from 5 minutes ago"
  }
}
```

---

## 📊 Performance Targets

| Component | Target | Status |
|-----------|--------|--------|
| Vision Detection | <200ms | On-device, fast ✅ |
| Network Request | ~50ms | iOS → Cloud |
| Parallel Scraping | ~600ms | asyncio.gather() |
| Firestore Cache Lookup | ~20ms | Fast |
| Firestore Write | ~50ms | Background |
| Response Parsing | ~20ms | Swift Codable |
| UI Update | ~30ms | SwiftUI animation |
| **TOTAL E2E** | **~800ms** | **✅ Instant feel** |

---

## 🛡️ Error Handling & Fallbacks

### Fallback Chain

```
User searches: "iPhone case"
    ↓
Try: Mercado Libre API
    ↓ (if timeout > 3 sec, skip)
Try: OLX API
    ↓ (if timeout > 3 sec, skip)
Try: Amazon API
    ↓ (if timeout > 3 sec, skip)
Try: Web scrapers (Carrefour, Falabella, etc.)
    ↓ (fastest 3 used)
Aggregate results from all successful sources
    ↓
Store in cache (even if partial)
    ↓
If NO sources succeeded:
    ├─ Check 24h device cache
    ├─ Return old results (if available)
    └─ If no cache: Return error "Prices unavailable"
```

---

## 🔐 Security Considerations

### API Security
- HTTPS only (no HTTP fallback)
- No API keys in URLs
- Request signing (if needed)
- Rate limiting (Firebase default 100k/month free)

### Data Privacy
- No user tracking
- No persistent logs
- Price data aggregated only
- Cache expires after 5 minutes

### Code Security
- Input validation (product_name sanitized)
- Timeout on all external requests (3 seconds)
- Error messages don't leak internals
- Logging sanitized (no PII)

---

## 🚀 Deployment

### Infrastructure
- **iOS App:** TestFlight → App Store
- **Backend:** Firebase Cloud Functions (auto-scaling)
- **Database:** Firestore (managed)
- **DNS/CDN:** Google Cloud (included)

### Costs
- **Free Tier:** 500k invocations/month
- **MVP Usage:** ~30k invocations/month
- **Cost:** $0 during development ✅

---

## 📝 Next Steps

1. iOS agents: Implement SwiftUI screens & URLSession
2. Backend agent: Implement scraper factory & aggregation
3. DevOps agent: Set up Firebase & Cloud Functions
4. All: Test end-to-end flow

---

**Last Updated:** April 1, 2026  
**Version:** 1.0  
**Status:** ✅ Complete
