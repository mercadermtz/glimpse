#!/bin/bash

# GLIMPSE Backend Project Setup Script
# Creates complete Firebase Cloud Functions project structure

set -e

PROJECT_NAME="glimpse-backend"

echo "═══════════════════════════════════════════════════════════"
echo "🔧 GLIMPSE Backend Setup"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create project directory
if [ -d "$PROJECT_NAME" ]; then
    echo "❌ Directory '$PROJECT_NAME' already exists"
    exit 1
fi

echo "📁 Creating backend project directory: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME/functions"
cd "$PROJECT_NAME"

echo "📝 Initializing Firebase project..."
firebase init functions --language python --force

cd functions

# Create project structure
echo "📁 Creating folder structure..."

mkdir -p scrapers/other_retailers
mkdir -p cache
mkdir -p models
mkdir -p utils
mkdir -p tests

# Create __init__.py files
touch scrapers/__init__.py
touch cache/__init__.py
touch models/__init__.py
touch utils/__init__.py
touch tests/__init__.py
touch scrapers/other_retailers/__init__.py

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.0
google-cloud-functions==1.3.0
google-cloud-firestore==2.11.0
google-cloud-storage==2.10.0
aiohttp==3.8.5
asyncio==3.4.3
beautifulsoup4==4.12.2
requests==2.31.0
python-dotenv==1.0.0
pytest==7.0.0
pytest-asyncio==0.21.0
pytest-cov==4.1.0
python-dateutil==2.8.2
EOF

echo "✅ Created requirements.txt"

# Create main.py
cat > main.py << 'EOF'
import functions_framework
from flask import Request, jsonify
from datetime import datetime
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def search_prices(request: Request):
    """
    HTTP Cloud Function for price search
    
    Request:
        POST /search_prices
        Content-Type: application/json
        {
            "product_name": "iPhone case",
            "confidence": 0.85
        }
    """
    
    try:
        # Parse request
        request_json = request.get_json()
        product_name = request_json.get('product_name', '').strip()
        
        if not product_name:
            return jsonify({"error": "Missing product_name"}), 400
        
        logger.info(f"Searching prices for: {product_name}")
        
        # TODO: Implement price scraping logic
        # For now, return mock data
        response = {
            "product": product_name,
            "cheapest": {
                "price": 2890,
                "currency": "ARS",
                "source": "mercado_libre",
                "url": "https://example.com"
            },
            "alternatives": [
                {
                    "price": 2950,
                    "currency": "ARS",
                    "source": "olx",
                    "url": "https://example.com"
                }
            ],
            "timestamp": datetime.now().isoformat(),
            "cached": False,
            "sources_queried": 100
        }
        
        return jsonify(response), 200
        
    except Exception as e:
        logger.error(f"Error in search_prices: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500
EOF

echo "✅ Created main.py"

# Create base scraper
cat > scrapers/base_scraper.py << 'EOF'
import asyncio
from abc import ABC, abstractmethod
from typing import Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class BaseScraper(ABC):
    """Base class for all price scrapers"""
    
    def __init__(self, name: str, timeout: int = 3):
        self.name = name
        self.timeout = timeout
    
    @abstractmethod
    async def scrape(self, product_name: str) -> Optional[Dict[str, Any]]:
        """Scrape product prices"""
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
EOF

echo "✅ Created base_scraper.py"

# Create factory
cat > scrapers/factory.py << 'EOF'
import asyncio
from typing import Dict, Optional
from .base_scraper import BaseScraper
import logging

logger = logging.getLogger(__name__)

class ScraperFactory:
    """Factory for managing all scrapers"""
    
    def __init__(self):
        self.scrapers = []  # Will populate with actual scrapers
    
    async def scrape_all(self, product_name: str) -> Dict[str, Optional[Dict]]:
        """Run all scrapers in parallel"""
        
        tasks = [
            scraper.scrape_with_timeout(product_name)
            for scraper in self.scrapers
        ]
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        output = {}
        for scraper, result in zip(self.scrapers, results):
            if result and not isinstance(result, Exception):
                output[scraper.name] = result
            else:
                output[scraper.name] = None
        
        return output
EOF

echo "✅ Created factory.py"

# Create cache module
cat > cache/firestore_cache.py << 'EOF'
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
        self.ttl_seconds = 300
    
    def _get_product_hash(self, product_name: str) -> str:
        """Generate hash of product name for cache key"""
        return hashlib.md5(product_name.lower().encode()).hexdigest()
    
    def get(self, product_name: str) -> Optional[Dict]:
        """Get cached result if exists and not expired"""
        try:
            doc_id = self._get_product_hash(product_name)
            doc = self.db.collection(self.collection).document(doc_id).get()
            
            if not doc.exists:
                return None
            
            data = doc.to_dict()
            expires = data.get('expires')
            
            if expires and expires < datetime.now():
                return None
            
            return data
            
        except Exception as e:
            logger.error(f"Cache get error: {str(e)}")
            return None
    
    def set(self, product_name: str, result: Dict, ttl_seconds: int = 300):
        """Store result in cache"""
        try:
            doc_id = self._get_product_hash(product_name)
            cache_data = {
                'result': result,
                'created_at': datetime.now(),
                'expires': datetime.now() + timedelta(seconds=ttl_seconds)
            }
            self.db.collection(self.collection).document(doc_id).set(cache_data)
        except Exception as e:
            logger.error(f"Cache set error: {str(e)}")
EOF

echo "✅ Created firestore_cache.py"

# Create models
cat > models/price_result.py << 'EOF'
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import List, Optional

@dataclass
class PriceSource:
    """Single price source result"""
    price: int
    currency: str
    source: str
    url: str
    
    def to_dict(self):
        return asdict(self)

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
EOF

echo "✅ Created price_result.py"

# Create .env.example
cat > .env.example << 'EOF'
# Firebase Configuration
FIREBASE_PROJECT_ID=glimpse-ar-project-id
FIRESTORE_DB=glimpse-ar

# Scraper Configuration
SCRAPER_TIMEOUT=3
CACHE_TTL=300

# Logging
LOG_LEVEL=INFO
EOF

echo "✅ Created .env.example"

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
.venv

# Environment variables
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Firebase
.runtimeconfig.json

# Testing
.coverage
htmlcov/

# OS
.DS_Store
Thumbs.db
EOF

echo "✅ Created .gitignore"

# Create README
cat > README.md << 'EOF'
# 🔧 GLIMPSE Backend

Firebase Cloud Functions for price comparison.

## Setup

### Prerequisites
- Python 3.11+
- Firebase CLI
- Google Cloud Project

### Installation

```bash
# Install Python dependencies
pip install -r requirements.txt

# Install Firebase CLI (if not already)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init functions --language python
```

## Project Structure

```
functions/
├── main.py               - Cloud Function entry point
├── scrapers/             - Price scrapers
├── cache/                - Caching layer
├── models/               - Data models
├── utils/                - Utilities
├── tests/                - Tests
└── requirements.txt      - Python dependencies
```

## Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
functions-framework --target=search_prices --debug

# Deploy to Firebase
firebase deploy --only functions:search_prices

# View logs
firebase functions:log
```

## Testing

```bash
# Run tests
pytest tests/ -v

# Coverage
pytest tests/ --cov=. --cov-report=html
```

See `docs/BACKEND_DEVELOPMENT.md` for detailed guide.
EOF

echo "✅ Created README.md"

# Initialize git
echo ""
echo "🔧 Initializing Git repository..."
cd ..
git init
git add .
git commit -m "Initial commit: GLIMPSE backend structure"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ GLIMPSE Backend Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📁 Project created at: $(pwd)"
echo ""
echo "Next steps:"
echo "  1. cd functions"
echo "  2. pip install -r requirements.txt"
echo "  3. functions-framework --target=search_prices --debug"
echo "  4. Start building! 🚀"
echo ""
