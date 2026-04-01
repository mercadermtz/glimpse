# 📋 GLIMPSE - Code Standards & Project Rules

## Swift Code Standards

### File Organization

```swift
// 1. Imports
import Foundation
import SwiftUI

// 2. Type/Class Definition
class MyViewModel: ObservableObject {
    // 3. Nested Types
    enum State {
        case idle
        case loading
        case success
        case error(String)
    }
    
    // 4. Constants
    private let timeoutSeconds = 10
    
    // 5. @Published properties
    @Published var state = State.idle
    
    // 6. Private properties
    private var task: Task<Void, Never>?
    
    // 7. Initialization
    init() {}
    
    // 8. Public methods
    func loadData() {}
    
    // 9. Private methods
    private func processData() {}
}
```

### Naming Conventions

**Variables & Functions:**
- Use camelCase
- Be descriptive
- ✅ Good: `isLoading`, `searchPrices()`, `detectedProduct`
- ❌ Bad: `loading`, `sp()`, `prod`

**Classes & Structs:**
- Use PascalCase
- ✅ Good: `PriceViewModel`, `PriceResult`, `CameraService`
- ❌ Bad: `priceViewModel`, `price_result`, `cameraservice`

**Constants:**
- Use UPPER_CASE if global
- Regular camelCase if local
- ✅ Good: `let TIMEOUT = 3`, `private let timeout = 3`
- ❌ Bad: `let timeout = 3` (global)

**Boolean Properties:**
- Prefix with `is` or `has`
- ✅ Good: `isLoading`, `hasError`, `canRetry`
- ❌ Bad: `loading`, `error`, `retry`

### SwiftUI Best Practices

**State Management:**
```swift
// ✅ Good - Minimal state
@MainActor
class CameraViewModel: ObservableObject {
    @Published var prices: PriceResult?
    @Published var error: String?
    @Published var isLoading = false
}

// ❌ Bad - Too much state
class CameraViewModel: ObservableObject {
    @Published var prices: PriceResult?
    @Published var isPricesLoaded = false
    @Published var isPricesError = false
    @Published var pricesError: String?
    @Published var isLoadingPrices = false
}
```

**View Composition:**
```swift
// ✅ Good - Broken into components
struct CameraScreen: View {
    var body: some View {
        ZStack {
            CameraPreview()
            
            VStack {
                CameraHeader()
                Spacer()
                DetectionOverlay()
                Spacer()
                PriceResults()
            }
        }
    }
}

// ❌ Bad - Everything in one view
struct CameraScreen: View {
    var body: some View {
        ZStack {
            // 500 lines of code here...
        }
    }
}
```

**Closures & Trailing Closures:**
```swift
// ✅ Good
Button(action: { viewModel.loadPrices() }) {
    Text("Search")
}

Task {
    await viewModel.loadData()
}

// ❌ Bad
Button(action: { 
    viewModel.loadPrices()
    print("Done")
    // Extra logic here
}) {
    Text("Search")
}
```

### Error Handling

```swift
// ✅ Good - Custom error types
enum CameraError: LocalizedError {
    case permissionDenied
    case noCamera
    case frameCaptureError(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission denied"
        case .noCamera:
            return "No camera available"
        case .frameCaptureError(let detail):
            return "Frame capture failed: \(detail)"
        }
    }
}

// ✅ Good - Proper error handling
do {
    try camera.startCapture()
} catch CameraError.permissionDenied {
    // Show permission request
} catch {
    logger.error("Unexpected error: \(error)")
}
```

---

## Python Code Standards

### File Organization

```python
# 1. Imports (standard library first)
import asyncio
from datetime import datetime
from typing import Dict, List, Optional

# 2. Third-party imports
import aiohttp
import functions_framework
from flask import Request, jsonify

# 3. Local imports
from scrapers.base_scraper import BaseScraper
from cache.firestore_cache import FirestoreCache

# 4. Constants
DEFAULT_TIMEOUT = 3
CACHE_TTL = 300

# 5. Functions/Classes
@functions_framework.http
def search_prices(request: Request):
    pass
```

### Naming Conventions

**Functions & Variables:**
- Use snake_case
- ✅ Good: `search_prices()`, `product_name`, `cache_ttl`
- ❌ Bad: `searchPrices()`, `ProductName`, `CACHE_TTL` (unless constant)

**Classes:**
- Use PascalCase
- ✅ Good: `MercadoLibreScraper`, `FirestoreCache`
- ❌ Bad: `mercado_libre_scraper`, `firestore_cache`

**Constants:**
- Use UPPER_SNAKE_CASE
- ✅ Good: `DEFAULT_TIMEOUT`, `MAX_RETRIES`
- ❌ Bad: `default_timeout`, `maxRetries`

### Type Hints

```python
# ✅ Good - Clear types
async def scrape_all(product_name: str) -> Dict[str, Optional[Dict]]:
    """Scrape all sources in parallel"""
    pass

def aggregate_prices(results: List[Dict]) -> PriceResult:
    """Aggregate and sort prices"""
    pass

# ❌ Bad - No type hints
async def scrape_all(product_name):
    pass
```

### Docstrings

```python
# ✅ Good - Clear docstring
def aggregate_prices(product_name: str, results: Dict) -> PriceResult:
    """
    Aggregate scraping results and find cheapest price.
    
    Args:
        product_name: Name of the product
        results: Dict of scraper_name -> price_data
    
    Returns:
        PriceResult with cheapest + alternatives
    
    Raises:
        ValueError: If no prices found
    """
    pass

# ❌ Bad - Missing docstring
def aggregate_prices(product_name, results):
    # process data
    return result
```

### Error Handling

```python
# ✅ Good - Specific exceptions
try:
    result = await asyncio.wait_for(scraper.scrape(product), timeout=3)
except asyncio.TimeoutError:
    logger.warning(f"{scraper.name} timed out")
    return None
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    return None

# ❌ Bad - Generic exception
try:
    result = scraper.scrape(product)
except:
    return None
```

### Async Best Practices

```python
# ✅ Good - Parallel execution
async def scrape_all(product: str) -> Dict:
    """Run all scrapers in parallel"""
    tasks = [scraper.scrape_with_timeout(product) for scraper in scrapers]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    return {scraper.name: result for scraper, result in zip(scrapers, results)}

# ❌ Bad - Sequential (slow!)
async def scrape_all(product: str) -> Dict:
    results = {}
    for scraper in scrapers:
        results[scraper.name] = await scraper.scrape(product)
    return results
```

---

## Testing Standards

### Swift Testing

```swift
// ✅ Good - Clear, focused tests
func testSearchPricesSuccess() async {
    // Given
    let mockService = MockNetworkService()
    mockService.mockResult = .success(priceResult)
    
    // When
    let result = try? await mockService.searchPrices("iPhone")
    
    // Then
    XCTAssertNotNil(result)
    XCTAssertEqual(result?.product, "iPhone")
}

// ❌ Bad - Unclear purpose
func testStuff() {
    let vm = CameraViewModel()
    vm.processFrame(buffer)
    // ???
}
```

### Python Testing

```python
# ✅ Good - Comprehensive test
def test_cache_get_expired():
    """Test that expired cache returns None"""
    cache = FirestoreCache()
    
    # Store with past expiration
    cache.set("iPhone", result, ttl_seconds=-1)
    
    # Should be expired
    assert cache.get("iPhone") is None

# ❌ Bad - Missing assertions
def test_cache():
    cache = FirestoreCache()
    cache.set("iPhone", result)
    # That's it?
```

### Test Coverage Target
- **Minimum:** 70% code coverage
- **Target:** 85%+ for critical paths
- **Required:** 100% for error paths

---

## Code Review Checklist

### Before Committing

- [ ] Code builds without errors
- [ ] All tests pass
- [ ] Follows naming conventions
- [ ] No console logs left in (use proper logging)
- [ ] Error handling implemented
- [ ] Comments for complex logic only
- [ ] No hardcoded values (use constants)
- [ ] Memory management (no leaks)
- [ ] Performance acceptable

### Git Commit Messages

```
# ✅ Good format
feat: Implement Vision model detection
fix: Handle network timeout gracefully
refactor: Extract price aggregation logic
test: Add unit tests for cache layer
docs: Update iOS development guide

# Include context
feat: Implement Vision model detection

- Load CoreML model on app startup
- Process frames at 15 FPS
- Return top 3 detections
- Add timeout handling (200ms)

Fixes #42
```

```
# ❌ Bad format
update stuff
fix bug
working on prices
checkpoint
```

### Pull Request Guidelines

**Title:** `[TYPE] Brief description`
- feat, fix, refactor, docs, test

**Description:**
- What was changed
- Why it was changed
- How to test
- References to issues

**Code Review:**
- At least 1 approval before merge
- All CI checks passing
- No conflicts

---

## Performance Standards

### iOS

| Metric | Target | Acceptable |
|--------|--------|-----------|
| Vision Detection | <200ms | <500ms |
| Network Request | <2s | <5s |
| UI Responsiveness | <100ms | <300ms |
| Memory Usage | <100MB | <200MB |
| Battery (per hour) | <2% | <5% |

### Backend

| Metric | Target | Acceptable |
|--------|--------|-----------|
| Scrape All Sites | <600ms | <2s |
| Cache Lookup | <20ms | <100ms |
| API Response | <800ms | <2s |
| Function Startup | <1s | <3s |

---

## Logging Standards

### Swift

```swift
// ✅ Good
logger.info("Starting price search for: \(product)")
logger.warning("Camera permission denied")
logger.error("Network error: \(error.localizedDescription)")

// ❌ Bad
print("hi")
print("error: \(error)")
NSLog("Something happened")
```

### Python

```python
# ✅ Good
logger.info(f"Searching prices for: {product_name}")
logger.warning(f"{scraper.name} timed out")
logger.error(f"Error: {str(e)}", exc_info=True)

# ❌ Bad
print("hello")
print(f"error: {e}")
```

---

## Security Standards

### Never Do

- ❌ Commit credentials (passwords, API keys, tokens)
- ❌ Use hardcoded secrets
- ❌ Log sensitive data (user info, tokens)
- ❌ Skip SSL verification
- ❌ Use `eval()` or `exec()`

### Always Do

- ✅ Use environment variables for secrets
- ✅ Use HTTPS only
- ✅ Validate all inputs
- ✅ Sanitize error messages
- ✅ Rotate API keys regularly

---

## Documentation Standards

### Code Comments

```swift
// ✅ Good - Why, not What
// Use 15 FPS to reduce CPU load
captureSession.videoPreset = .low

// ❌ Bad - Obvious
// Set the video preset to low
captureSession.videoPreset = .low
```

### File Headers

```swift
//
//  CameraViewModel.swift
//  GLIMPSE
//
//  Manages camera and vision detection
//  Coordinates with network service for price lookup
//

import SwiftUI
```

---

## Deployment Standards

### Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Code review approved
- [ ] Performance benchmarked
- [ ] Security audit done
- [ ] Version bumped
- [ ] CHANGELOG updated
- [ ] Release notes written

### Versioning

Use Semantic Versioning: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

---

**Last Updated:** April 1, 2026  
**Version:** 1.0  
**Status:** ✅ Complete
