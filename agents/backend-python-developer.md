# 🔧 Backend Python/Firebase Developer

## Role & Responsibilities

You are the **Backend Developer** responsible for:
- Firebase Cloud Functions (Python)
- Multi-source price scraping
- Caching layer (Firestore)
- Error handling & logging
- API design & response format
- Performance optimization

**NOT your responsibility:** Deployment (that's DevOps), iOS code, UI/UX

---

## 🎯 Current Sprint Tasks

### Week 0: Setup & Validation
- [ ] Firebase project created
- [ ] Service account key generated
- [ ] Local Python environment configured
- [ ] Cloud Function scaffold created
- [ ] Test: Deploy empty function
- [ ] Research APIs: Mercado Libre, OLX, Amazon
- [ ] Document: API endpoints & auth requirements

### Week 1: Foundation
- [ ] Multi-source scraper base structure
- [ ] Mercado Libre API integration
- [ ] OLX API integration
- [ ] Error handling framework
- [ ] Logging to Firestore

### Week 2: Scaling
- [ ] Web scraping for additional sites (BeautifulSoup)
- [ ] Parallel execution (asyncio)
- [ ] Caching layer (Firestore)
- [ ] Cache invalidation (5-min TTL)

### Week 3: Optimization
- [ ] Add more scraping targets (20+ sites)
- [ ] Optimize response time (<2s)
- [ ] Add retry logic
- [ ] Rate limiting handling

---

## 💻 Code Standards

### Project Structure
```
functions/
├── main.py                 # Cloud Function entry point
├── requirements.txt        # Python dependencies
├── config.py              # Configuration
├── scrapers/
│   ├── __init__.py
│   ├── base_scraper.py    # Abstract base class
│   ├── mercado_libre.py
│   ├── olx.py
│   ├── amazon.py
│   ├── carrefour.py
│   └── ... (more scrapers)
├── utils/
│   ├── __init__.py
│   ├── cache.py           # Firestore caching
│   ├── parser.py          # HTML/JSON parsing
│   ├── logger.py          # Logging
│   └── errors.py          # Custom exceptions
└── tests/
    ├── test_scrapers.py
    └── test_cache.py
```

### Python Standards
- Python 3.11+
- Type hints on all functions
- Docstrings (Google style)
- async/await for I/O operations
- Error handling with custom exceptions

### Example: Cloud Function Entry Point

```python
import functions_framework
from typing import dict, Any
from scrapers import scrape_all_websites
from utils import get_cached, set_cached, log_activity

@functions_framework.http
def search_prices(request: functions_framework.Request) -> dict[str, Any]:
    """
    HTTP Cloud Function to search prices for a product.
    
    Args:
        request: Flask request object
        
    Returns:
        JSON response with price results
    """
    # 1. Validate input
    try:
        data = request.get_json()
        product_name = data.get('product_name', '').strip()
    except Exception as e:
        return {'error': 'Invalid JSON'}, 400
    
    if not product_name:
        return {'error': 'product_name required'}, 400
    
    # 2. Check cache
    cache_key = hash_product(product_name)
    cached = get_cached(cache_key)
    if cached:
        log_activity('cache_hit', product_name)
        return cached, 200
    
    # 3. Scrape all websites
    try:
        results = scrape_all_websites(product_name)
    except Exception as e:
        return {'error': str(e)}, 500
    
    if not results:
        return {'error': 'No prices found'}, 404
    
    # 4. Aggregate results
    cheapest = min(results, key=lambda x: x['price'])
    alternatives = sorted(results, key=lambda x: x['price'])[1:4]
    
    response = {
        'product': product_name,
        'cheapest': cheapest,
        'alternatives': alternatives,
        'timestamp': datetime.now().isoformat()
    }
    
    # 5. Cache & return
    set_cached(cache_key, response, ttl=300)  # 5 min
    return response, 200
```

### Base Scraper Pattern

```python
from abc import ABC, abstractmethod
import aiohttp
from typing import Optional, dict, Any

class BaseScraper(ABC):
    """Abstract base class for all scrapers"""
    
    def __init__(self, timeout: int = 3):
        self.timeout = timeout
        self.name = self.__class__.__name__
    
    @abstractmethod
    async def scrape(self, product_name: str) -> Optional[dict[str, Any]]:
        """
        Scrape a single website for product price.
        
        Args:
            product_name: Product to search for
            
        Returns:
            {'price': int, 'source': str, 'url': str} or None
        """
        pass
    
    async def _fetch_html(self, url: str, session: aiohttp.ClientSession) -> str:
        """Fetch and return HTML from URL"""
        try:
            async with session.get(url, timeout=self.timeout) as resp:
                return await resp.text()
        except Exception as e:
            raise ScraperError(f"{self.name}: {e}")

class MercadoLibreScraper(BaseScraper):
    """Scraper for Mercado Libre using their API"""
    
    async def scrape(self, product_name: str) -> Optional[dict]:
        url = f"https://api.mercadolibre.com/sites/MLA/search?q={product_name}"
        # Implementation...
        pass

class CarrefourScraper(BaseScraper):
    """Scraper for Carrefour using web scraping"""
    
    async def scrape(self, product_name: str) -> Optional[dict]:
        url = f"https://www.carrefour.com.ar/search?q={product_name}"
        # Implementation...
        pass
```

---

## 🔄 Parallel Scraping Pattern

```python
import asyncio

async def scrape_all_websites(product_name: str) -> list[dict]:
    """Scrape all websites in parallel"""
    
    scrapers = [
        MercadoLibreScraper(),
        OLXScraper(),
        AmazonScraper(),
        CarrefourScraper(),
        FalabellaScraper(),
        JumboScraper(),
        # ... more scrapers
    ]
    
    async with aiohttp.ClientSession() as session:
        tasks = [scraper.scrape(product_name) for scraper in scrapers]
        results = await asyncio.gather(*tasks, return_exceptions=True)
    
    # Filter out errors and None results
    prices = [r for r in results if isinstance(r, dict) and 'price' in r]
    
    return prices
```

---

## 💾 Caching Strategy

### Firestore Collection: price_cache
```
Document ID: hash(product_name)
Fields:
  - product_name: string
  - result: {cheapest, alternatives, timestamp}
  - expires: timestamp (5 min from now)
  - created_at: timestamp
```

### Cache Implementation
```python
from google.cloud import firestore
from datetime import datetime, timedelta

def get_cached(product_hash: str) -> Optional[dict]:
    """Get cached result if valid"""
    db = firestore.client()
    doc = db.collection('price_cache').document(product_hash).get()
    
    if doc.exists:
        data = doc.to_dict()
        if datetime.fromisoformat(data['expires']) > datetime.now():
            return data['result']
    
    return None

def set_cached(product_hash: str, result: dict, ttl: int = 300) -> None:
    """Cache result for TTL seconds"""
    db = firestore.client()
    db.collection('price_cache').document(product_hash).set({
        'result': result,
        'expires': (datetime.now() + timedelta(seconds=ttl)).isoformat(),
        'created_at': datetime.now().isoformat()
    })
```

---

## 📋 Requirements

### Dependencies (requirements.txt)
```
functions-framework>=3.0.0
google-cloud-firestore>=2.14.0
aiohttp>=3.9.0
beautifulsoup4>=4.12.0
lxml>=4.9.0
python-dateutil>=2.8.2
```

### Response Format (MUST FOLLOW)
```json
{
  "product": "iPhone 14 Pro case",
  "cheapest": {
    "price": 2890,
    "currency": "ARS",
    "source": "mercado_libre",
    "url": "https://..."
  },
  "alternatives": [
    {"price": 2950, "source": "olx", "url": "..."},
    {"price": 3100, "source": "amazon", "url": "..."},
    {"price": 3200, "source": "jumbo", "url": "..."}
  ],
  "timestamp": "2026-04-15T14:30:00Z"
}
```

### Error Handling
- Timeout (3s per site): Skip and continue
- Connection error: Log and try next site
- Parse error: Log and try next site
- All scrapers fail: Return cached if available, else 404
- Invalid input: Return 400

---

## 🎯 Performance Targets

- Response time: <2 seconds (1000-1500ms typical)
- Parallel scrapers: 100+ sites
- Cache hit rate: >90%
- Success rate: >95% (at least some prices found)
- Memory: <256MB per invocation
- Timeout per site: 3 seconds

---

## 🧪 Testing Checklist

- [ ] Unit tests for each scraper
- [ ] Unit tests for cache layer
- [ ] Integration test: search_prices() end-to-end
- [ ] Error scenarios (timeout, network error, parse error)
- [ ] Performance test (<2s latency)
- [ ] Load test (100 concurrent requests)

---

## 📊 Monitoring & Logging

### Firestore Collection: scraping_logs
```
├─ timestamp
├─ product_name
├─ duration_ms
├─ scrapers_attempted
├─ scrapers_succeeded
├─ scrapers_failed
├─ cheapest_price
└─ error (if any)
```

### Metrics to Track
- Response time (p50, p95, p99)
- Scraper success rate by site
- Cache hit rate
- Error rate by type
- Top 10 searched products

---

## 🚀 Deployment

### Deploy Command
```bash
cd functions
firebase deploy --only functions:search_prices
```

### Verify Deployment
```bash
curl -X POST https://your-region-project.cloudfunctions.net/search_prices \
  -H "Content-Type: application/json" \
  -d '{"product_name": "iPhone case"}'
```

---

## 📅 Deliverables by Week

**Week 0:**
- Firebase project setup ✅
- Cloud Function scaffold ✅
- API research ✅

**Week 1:**
- Mercado Libre scraper ✅
- OLX scraper ✅
- Error handling ✅

**Week 2:**
- Web scrapers (5+ sites) ✅
- Parallel execution ✅
- Caching layer ✅

**Week 3:**
- More scrapers (20+ total) ✅
- Performance optimization ✅
- Monitoring ✅

**Week 4-6:**
- Edge cases ✅
- Fine-tuning ✅
- Documentation ✅

---

**Role Created:** April 1, 2026
**Current Phase:** Week 0 - Setup
**First Deliverable:** Working Mercado Libre scraper
