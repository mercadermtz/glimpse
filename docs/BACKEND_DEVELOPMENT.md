# 🔧 GLIMPSE - Backend Development Guide

## Setup & Environment

### Prerequisites
- Python 3.11+ (Firebase requires 3.11+)
- pip (Python package manager)
- Firebase CLI
- Git
- Code editor (VS Code recommended)

### Initial Setup

```bash
# Create project directory
mkdir glimpse-backend && cd glimpse-backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Initialize Firebase project structure
firebase init functions --language python

# Install dependencies
pip install -r requirements.txt
```

---

## 📁 Project Structure

```
functions/
├── main.py                          ← Cloud Function entry point
├── requirements.txt                 ← Python dependencies
├── .env.example                     ← Environment variables template
├── .env                             ← Actual env vars (gitignored)
│
├── scrapers/                        ← Price scrapers
│   ├── __init__.py
│   ├── base_scraper.py             ← Base class for all scrapers
│   ├── factory.py                  ← Scraper factory
│   ├── mercado_libre.py            ← Mercado Libre API
│   ├── olx.py                      ← OLX API
│   ├── amazon.py                   ← Amazon API
│   ├── carrefour.py                ← Carrefour scraper
│   ├── falabella.py                ← Falabella scraper
│   ├── jumbo.py                    ← Jumbo scraper
│   └── other_retailers/            ← 95+ more scrapers
│       ├── dafiti.py
│       ├── bazar.py
│       └── ... etc
│
├── cache/                           ← Caching layer
│   ├── __init__.py
│   ├── firestore_cache.py          ← Firestore cache implementation
│   └── cache_models.py             ← Cache data models
│
├── utils/                           ← Utilities
│   ├── __init__.py
│   ├── parser.py                   ← HTML/JSON parsing helpers
│   ├── validators.py               ← Input validation
│   ├── converters.py               ← Currency/unit conversion
│   ├── logger.py                   ← Logging utilities
│   └── constants.py                ← App constants
│
├── models/                          ← Data models
│   ├── __init__.py
│   ├── price_result.py             ← Price result model
│   └── scraper_log.py              ← Logging model
│
├── tests/                           ← Unit tests
│   ├── __init__.py
│   ├── test_mercado_libre.py
│   ├── test_cache.py
│   ├── test_aggregation.py
│   └── fixtures.py                 ← Test data
│
└── .gitignore                       ← Git ignore rules
```

---

## 🚀 Cloud Function Implementation

### Main Entry Point (main.py)

```python
# functions/main.py

import functions_framework
from flask import Request, jsonify
from datetime import datetime, timedelta
import asyncio
import logging
from typing import Dict, List, Optional

from scrapers.factory import ScraperFactory
from cache.firestore_cache import FirestoreCache
from models.price_result import PriceResult, PriceSource
from utils.validators import validate_product_name
from utils.logger import setup_logging

# Setup logging
logger = setup_logging(__name__)

# Initialize services
cache = FirestoreCache()
scraper_factory = ScraperFactory()

@functions_framework.http
def search_prices(request: Request) -> tuple:
    """
    HTTP Cloud Function for price search
    
    Request:
        POST /search_prices
        Content-Type: application/json
        {
            "product_name": "iPhone case",
            "confidence": 0.85,
            "timestamp": "2026-04-15T10:30:00Z"
        }
    
    Response:
        {
            "product": "iPhone case",
            "cheapest": {...},
            "alternatives": [...],
            "timestamp": "...",
            "cached": false,
            "sources_queried": 100
        }
    """
    
    try:
        # Parse request
        request_json = request.get_json()
        product_name = request_json.get('product_name', '').strip()
        
        # Validate input
        if not validate_product_name(product_name):
            return jsonify({
                "error": "Invalid product name",
                "product": product_name
            }), 400
        
        logger.info(f"Searching prices for: {product_name}")
        
        # Check cache first
        cached_result = cache.get(product_name)
        if cached_result and not cache.is_expired(cached_result):
            logger.info(f"Cache HIT for: {product_name}")
            response = cached_result.to_dict()
            response['cached'] = True
            return jsonify(response), 200
        
        # Cache miss - scrape all sources in parallel
        logger.info(f"Cache MISS for: {product_name}, starting scrape")
        start_time = datetime.now()
        
        # Run parallel scraping
        results = asyncio.run(scraper_factory.scrape_all(product_name))
        
        # Aggregate results
        aggregated = aggregate_prices(product_name, results)
        
        # Store in cache
        cache.set(product_name, aggregated, ttl_seconds=300)
        
        duration_ms = int((datetime.now() - start_time).total_seconds() * 1000)
        logger.info(f"Scrape completed in {duration_ms}ms, found {len(results)} sources")
        
        response = aggregated.to_dict()
        response['cached'] = False
        response['duration_ms'] = duration_ms
        response['sources_queried'] = len(results)
        
        return jsonify(response), 200
        
    except Exception as e:
        logger.error(f"Error in search_prices: {str(e)}", exc_info=True)
        
        # Try to return cached result as fallback
        try:
            cached = cache.get(product_name)
            if cached:
                response = cached.to_dict()
                response['error'] = 'Using cached result due to error'
                return jsonify(response), 200
        except:
            pass
        
        return jsonify({
            "error": "Prices unavailable",
            "product": product_name,
            "timestamp": datetime.now().isoformat()
        }), 500


def aggregate_prices(product_name: str, results: Dict[str, Dict]) -> PriceResult:
    """
    Aggregate scraping results and find cheapest price
    
    Args:
        product_name: Name of the product
        results: Dict of scraper_name -> price_data
    
    Returns:
        PriceResult with cheapest + alternatives
    """
    
    if not results:
        raise ValueError("No prices found from any source")
    
    # Extract all prices
    prices = []
    for source_name, data in results.items():
        if data and 'price' in data:
            prices.append({
                'price': data['price'],
                'currency': data.get('currency', 'ARS'),
                'source': source_name,
                'url': data.get('url', ''),
                'title': data.get('title', '')
            })
    
    # Sort by price
    prices.sort(key=lambda x: x['price'])
    
    if not prices:
        raise ValueError("No valid prices found")
    
    # Create result
    cheapest_data = prices[0]
    cheapest = PriceSource(
        price=cheapest_data['price'],
        currency=cheapest_data['currency'],
        source=cheapest_data['source'],
        url=cheapest_data['url']
    )
    
    # Get alternatives (top 3 after cheapest)
    alternatives = []
    for price_data in prices[1:4]:
        alternatives.append(PriceSource(
            price=price_data['price'],
            currency=price_data['currency'],
            source=price_data['source'],
            url=price_data['url']
        ))
    
    return PriceResult(
        product=product_name,
        cheapest=cheapest,
        alternatives=alternatives,
        timestamp=datetime.now()
    )
```

---

## 🕷️ Scraper Implementation

### Base Scraper Class

```python
# scrapers/base_scraper.py

import asyncio
from abc import ABC, abstractmethod
from datetime import datetime
from typing import Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class BaseScraper(ABC):
    """Base class for all price scrapers"""
    
    def __init__(self, name: str, timeout: int = 3):
        self.name = name
        self.timeout = timeout  # Seconds
    
    @abstractmethod
    async def scrape(self, product_name: str) -> Optional[Dict[str, Any]]:
        """
        Scrape product prices
        
        Args:
            product_name: Name of product to search
        
        Returns:
            {
                'price': int (in ARS),
                'currency': 'ARS',
                'source': 'mercado_libre',
                'url': 'https://...',
                'title': 'Product title',
                'timestamp': datetime
            }
            Or None if scrape fails
        """
        pass
    
    async def scrape_with_timeout(self, product_name: str) -> Optional[Dict]:
        """Wrap scrape with timeout"""
        try:
            result = await asyncio.wait_for(
                self.scrape(product_name),
                timeout=self.timeout
            )
            return result
        except asyncio.TimeoutError:
            logger.warning(f"{self.name} timed out after {self.timeout}s")
            return None
        except Exception as e:
            logger.error(f"{self.name} error: {str(e)}")
            return None
```

### Example: Mercado Libre Scraper

```python
# scrapers/mercado_libre.py

import aiohttp
import asyncio
import logging
from typing import Optional, Dict, Any
from .base_scraper import BaseScraper

logger = logging.getLogger(__name__)

class MercadoLibreScraper(BaseScraper):
    """Scraper for Mercado Libre Argentina"""
    
    def __init__(self):
        super().__init__(name='mercado_libre', timeout=3)
        self.base_url = 'https://api.mercadolibre.com'
        self.site_id = 'MLA'  # Argentina
    
    async def scrape(self, product_name: str) -> Optional[Dict[str, Any]]:
        """
        Use Mercado Libre API (no scraping needed!)
        Public API: /sites/{site_id}/search
        """
        
        async with aiohttp.ClientSession() as session:
            url = f'{self.base_url}/sites/{self.site_id}/search'
            params = {
                'q': product_name,
                'limit': 1,  # Just get cheapest
                'sort': 'price_asc'
            }
            
            try:
                async with session.get(url, params=params, timeout=self.timeout) as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        if data['results']:
                            item = data['results'][0]
                            
                            return {
                                'price': int(item['price']),
                                'currency': 'ARS',
                                'source': 'mercado_libre',
                                'url': item['permalink'],
                                'title': item['title'],
                                'timestamp': datetime.now().isoformat()
                            }
            except Exception as e:
                logger.error(f"Mercado Libre API error: {str(e)}")
                return None
        
        return None
```

### Scraper Factory

```python
# scrapers/factory.py

import asyncio
from typing import Dict, Optional
from .mercado_libre import MercadoLibreScraper
from .olx import OLXScraper
from .amazon import AmazonScraper
from .carrefour import CarrefourScraper
from .falabella import FalabellaScraper
# ... import 95+ more scrapers

class ScraperFactory:
    """Factory for managing all scrapers"""
    
    def __init__(self):
        self.scrapers = [
            MercadoLibreScraper(),
            OLXScraper(),
            AmazonScraper(),
            CarrefourScraper(),
            FalabellaScraper(),
            # ... 95+ more
        ]
    
    async def scrape_all(self, product_name: str) -> Dict[str, Optional[Dict]]:
        """
        Run all scrapers in parallel
        
        Returns dict of scraper_name -> result
        """
        
        tasks = [
            scraper.scrape_with_timeout(product_name)
            for scraper in self.scrapers
        ]
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Map results to scraper names
        output = {}
        for scraper, result in zip(self.scrapers, results):
            if result and not isinstance(result, Exception):
                output[scraper.name] = result
            else:
                output[scraper.name] = None
        
        return output
```

---

## 💾 Caching Layer

### Firestore Cache

```python
# cache/firestore_cache.py

from google.cloud import firestore
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import hashlib
import logging

logger = logging.getLogger(__name__)

class FirestoreCache:
    """Firestore-based cache for price results"""
    
    def __init__(self, db: Optional[firestore.Client] = None):
        self.db = db or firestore.client()
        self.collection = 'price_cache'
        self.ttl_seconds = 300  # 5 minutes
    
    def _get_product_hash(self, product_name: str) -> str:
        """Generate hash of product name for cache key"""
        return hashlib.md5(product_name.lower().encode()).hexdigest()
    
    def get(self, product_name: str) -> Optional['PriceResult']:
        """Get cached result if exists and not expired"""
        
        try:
            doc_id = self._get_product_hash(product_name)
            doc = self.db.collection(self.collection).document(doc_id).get()
            
            if not doc.exists:
                logger.debug(f"Cache MISS (not found): {product_name}")
                return None
            
            data = doc.to_dict()
            
            # Check if expired
            expires = data.get('expires')
            if expires and expires < datetime.now():
                logger.debug(f"Cache MISS (expired): {product_name}")
                return None
            
            logger.debug(f"Cache HIT: {product_name}")
            
            # Parse back to PriceResult
            from models.price_result import PriceResult
            return PriceResult.from_dict(data['result'])
            
        except Exception as e:
            logger.error(f"Cache get error: {str(e)}")
            return None
    
    def set(self, product_name: str, result: 'PriceResult', ttl_seconds: int = 300):
        """Store result in cache"""
        
        try:
            doc_id = self._get_product_hash(product_name)
            
            cache_data = {
                'result': result.to_dict(),
                'created_at': datetime.now(),
                'expires': datetime.now() + timedelta(seconds=ttl_seconds),
                'product_name': product_name,
                'ttl_seconds': ttl_seconds
            }
            
            self.db.collection(self.collection).document(doc_id).set(cache_data)
            logger.debug(f"Cache SET: {product_name} (TTL: {ttl_seconds}s)")
            
        except Exception as e:
            logger.error(f"Cache set error: {str(e)}")
    
    def is_expired(self, result_data: Dict) -> bool:
        """Check if cache entry is expired"""
        expires = result_data.get('expires')
        return expires and expires < datetime.now()
```

---

## 📊 Data Models

```python
# models/price_result.py

from dataclasses import dataclass, asdict
from datetime import datetime
from typing import List, Optional

@dataclass
class PriceSource:
    """Single price source result"""
    price: int                # in ARS
    currency: str            # 'ARS'
    source: str              # 'mercado_libre', 'olx', etc
    url: str                 # Product URL
    
    def to_dict(self):
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: dict):
        return cls(**data)

@dataclass
class PriceResult:
    """Complete price search result"""
    product: str
    cheapest: PriceSource
    alternatives: List[PriceSource]
    timestamp: datetime
    
    def to_dict(self):
        return {
            'product': self.product,
            'cheapest': self.cheapest.to_dict(),
            'alternatives': [a.to_dict() for a in self.alternatives],
            'timestamp': self.timestamp.isoformat()
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        return cls(
            product=data['product'],
            cheapest=PriceSource.from_dict(data['cheapest']),
            alternatives=[PriceSource.from_dict(a) for a in data['alternatives']],
            timestamp=datetime.fromisoformat(data['timestamp'])
        )
```

---

## 🧪 Testing

```python
# tests/test_mercado_libre.py

import pytest
import asyncio
from unittest.mock import patch, AsyncMock
from scrapers.mercado_libre import MercadoLibreScraper

@pytest.fixture
def scraper():
    return MercadoLibreScraper()

@pytest.mark.asyncio
async def test_scrape_success(scraper):
    """Test successful scrape"""
    
    with patch('aiohttp.ClientSession.get') as mock_get:
        # Mock API response
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json.return_value = {
            'results': [{
                'price': 2890,
                'permalink': 'https://articulo.mercadolibre.com.ar/...',
                'title': 'iPhone case'
            }]
        }
        mock_get.return_value.__aenter__.return_value = mock_response
        
        result = await scraper.scrape('iPhone case')
        
        assert result is not None
        assert result['price'] == 2890
        assert result['source'] == 'mercado_libre'

@pytest.mark.asyncio
async def test_scrape_timeout(scraper):
    """Test timeout handling"""
    
    with patch('asyncio.wait_for', side_effect=asyncio.TimeoutError):
        result = await scraper.scrape_with_timeout('iPhone case')
        assert result is None

@pytest.mark.asyncio
async def test_factory_parallel(scraper_factory):
    """Test parallel scraping"""
    
    results = await scraper_factory.scrape_all('iPhone case')
    
    assert isinstance(results, dict)
    assert len(results) == 100  # All scrapers
    # Some will succeed, some will fail (that's OK)
```

---

## 📋 Requirements

```
# requirements.txt

Flask==2.3.0
google-cloud-functions==1.3.0
google-cloud-firestore==2.11.0
aiohttp==3.8.0
asyncio==3.4.3
beautifulsoup4==4.12.0
requests==2.31.0
python-dotenv==1.0.0
pytest==7.0.0
pytest-asyncio==0.21.0
```

---

## 🚀 Deployment

```bash
# Deploy to Firebase
firebase deploy --only functions:search_prices

# View logs
firebase functions:log

# Test function locally
functions-framework --target=search_prices --debug

# Set environment variables
firebase functions:config:set config.api_timeout="3" config.cache_ttl="300"
```

---

## 📋 Checklist: Week 0-1

### Setup (Week 0)
- [ ] Create Firebase project
- [ ] Initialize Python Cloud Functions
- [ ] Set up virtual environment
- [ ] Create folder structure
- [ ] Add requirements.txt

### Base Implementation (Week 1)
- [ ] Implement BaseScraper class
- [ ] Implement Mercado Libre scraper (API)
- [ ] Implement OLX scraper (API)
- [ ] Implement Amazon scraper (API)
- [ ] Implement Carrefour scraper (web scrape)

### Core Functionality (Week 1)
- [ ] Implement ScraperFactory
- [ ] Implement parallel scraping (asyncio)
- [ ] Implement Firestore caching
- [ ] Implement aggregation logic
- [ ] Create Cloud Function entry point

### Testing & Deployment (Week 1)
- [ ] Write unit tests
- [ ] Test with sample products
- [ ] Deploy to Firebase
- [ ] Verify end-to-end flow

---

**Last Updated:** April 1, 2026  
**Version:** 1.0  
**Status:** ✅ Complete
