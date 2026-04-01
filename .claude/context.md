# 📋 GLIMPSE - Project Context

## Quick Facts

- **Project Name:** GLIMPSE
- **Tagline:** "Get a Glimpse of Every Price"
- **Duration:** 6 weeks
- **Team:** 4 AI agents (iOS x2, Backend x1, DevOps x1)
- **Tech Stack:** iOS (Swift/SwiftUI), Firebase (Python), Firestore
- **MVP Goal:** iOS app that detects products via camera and shows prices from 100+ retailers

---

## 🎯 The Problem & Solution

### Problem
Users shop and want to know: "Is this the cheapest price?" 
- Currently: Manual Google search for each product
- Takes: 2-5 minutes per product
- Frustration: Never sure if they're getting the best deal

### Solution: GLIMPSE
Users point iPhone camera at product → App shows:
- ✅ Cheapest price + where to buy
- ✅ Alternative retailers + prices
- ✅ All within 800ms (feels instant)

---

## 🏗️ Architecture Overview

### Three Main Components

```
1️⃣ iOS App (Frontend)
   ├─ Camera (AVFoundation)
   ├─ Vision Model (CoreML - detects products)
   ├─ UI (SwiftUI)
   └─ API Client (calls backend)

2️⃣ Firebase Backend (Server)
   ├─ Cloud Function (Python)
   ├─ Scrapes 100+ websites in parallel
   ├─ Finds cheapest price
   └─ Caches results (5 min TTL)

3️⃣ Data Sources (External)
   ├─ Mercado Libre API
   ├─ OLX API
   ├─ Amazon API
   ├─ Local retailers (web scraped)
   └─ 95+ more websites
```

### Data Flow

```
User points camera at product
    ↓ (200ms - on device)
Vision model detects: "iPhone case"
    ↓ (100ms)
iPhone sends HTTP POST to backend
    ↓ (100ms network)
Firebase Cloud Function receives request
    ↓
Check 5-min cache → Cache HIT? Return immediately (50ms)
    ↓ Cache MISS?
Scrape 100+ websites IN PARALLEL (600ms)
    ├─ Mercado Libre: 300ms → ARS 2890
    ├─ OLX: 400ms → ARS 2950
    ├─ Amazon: 350ms → ARS 3100
    └─ ... 97 more sites
    ↓
Aggregate & sort results
Find cheapest: ARS 2890 (Mercado Libre)
Cache for 5 minutes
    ↓ (100ms network)
iPhone receives JSON response
    ↓ (50ms)
Display results:
├─ Cheapest: ARS 2,890 (Mercado Libre)
├─ Also from: OLX (2,950), Amazon (3,100)
└─ Total time: 800ms ✅
```

---

## 📱 iOS App Requirements

### Two Screens Only (MVP)

**Screen 1: Home**
```
┌─────────────────┐
│                 │
│   GLIMPSE      │
│                 │
│ [Camera Icon]   │
│                 │
│ Open Camera     │
│    Button       │
│                 │
└─────────────────┘
```

**Screen 2: Camera**
```
┌─────────────────┐
│  📷 Live Feed   │
│  (User points   │
│   at product)   │
│                 │
│ Detected:       │
│ iPhone case     │
│ 85% confidence  │
│                 │
│ Searching...⌛   │
│                 │
│ Cheapest:       │
│ ARS 2,890       │
│ (Carrefour)     │
│                 │
│ [← Back]        │
└─────────────────┘
```

### Key Requirements

- ✅ Detect products via camera (≥60% accuracy)
- ✅ Show cheapest price + source
- ✅ Show 3 alternative retailers
- ✅ Response time: <2 seconds
- ✅ No crashes (graceful error handling)
- ✅ Works offline partially (uses cache)

---

## ☁️ Backend Requirements

### Cloud Function: search_prices(product_name)

**Input:**
```json
{
  "product_name": "iPhone 14 Pro case"
}
```

**Output:**
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

### Key Requirements

- ✅ Scrape 100+ websites in parallel (not sequential)
- ✅ Response time: <2 seconds
- ✅ Cache results for 5 minutes
- ✅ Handle timeouts gracefully
- ✅ Fallback chain if scraper fails
- ✅ Error logging to Firestore
- ✅ Auto-scaling (Firebase handles it)

---

## 🌐 Data Sources Strategy

### Multi-Source Approach (Not Single API Dependency)

**Why:** If Mercado Libre API denied → 99 other sources still work

### Sources by Priority

1. **APIs (Fastest, Most Reliable)**
   - Mercado Libre /sites/MLA/search
   - OLX Search API
   - Amazon Product Advertising API

2. **Web Scraping (Next Best)**
   - Carrefour.ar
   - Falabella.com.ar
   - Jumbo.com.ar
   - 97+ local retailers

3. **Fallbacks**
   - Cached results (5 min old)
   - User-submitted prices (if enabled)

### Fallback Chain

```
User searches: "iPhone case"
    ↓
Try: Mercado Libre API → Success? Use it
    ↓ (if fails)
Try: OLX API → Success? Use it
    ↓ (if fails)
Try: Amazon API → Success? Use it
    ↓ (if fails)
Try: Web scraping (5 sites) → Success? Use partial
    ↓ (if all fail)
Check cache → Has old results? Use them
    ↓ (if no cache)
Return error: "Prices unavailable now"
```

---

## ⚙️ Tech Stack Details

### iOS
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Camera:** AVFoundation
- **Vision:** Vision Framework + CoreML
- **ML Model:** YOLO or MobileNet (on-device)
- **Networking:** URLSession (async/await)
- **Minimum OS:** iOS 16+
- **Target Devices:** iPhone 12+ (A14 Bionic+)

### Backend
- **Platform:** Firebase
- **Compute:** Cloud Functions (Python 3.11+)
- **Database:** Firestore (caching)
- **Environment:** Python 3.11+ runtime
- **Libraries:**
  - asyncio (parallel scraping)
  - aiohttp (async HTTP)
  - BeautifulSoup (HTML parsing)
  - pandas (optional data processing)

### Deployment
- **iOS:** TestFlight → App Store
- **Backend:** Firebase deploy CLI
- **Infrastructure:** Google Cloud (managed by Firebase)

---

## 📊 Key Metrics & Targets

### Performance
- **Vision Detection:** 100-200ms (on-device, fast)
- **Backend Scraping:** 600ms (parallel execution)
- **Network Latency:** 100ms round-trip
- **Total E2E:** 800ms goal, <2s acceptable

### Reliability
- **Uptime:** 99%+ target
- **Error Handling:** Graceful degradation
- **Crash Rate:** 0% (MVP should not crash)
- **Cache Hit Rate:** 90%+ (most searches repeat)

### Scalability
- **Concurrent Users:** 1000+ day 1
- **Requests/Day:** 50k+ expected
- **Cost:** $0/month (Firebase free tier)
- **No scaling issues** (Firebase auto-scales)

---

## 🗓️ 6-Week Timeline

### Week 0: Setup & Validation (Parallel)
- **iOS:** Project setup, CocoaPods, basic structure
- **Backend:** Firebase project, service accounts, initial scraper
- **DevOps:** Deployment pipeline, monitoring
- **Deliverable:** First working Firebase function

### Week 1: Foundation
- **iOS:** Home screen + Camera screen UI
- **Backend:** Multi-source price aggregator
- **DevOps:** CI/CD setup
- **Deliverable:** Tap button → camera opens

### Week 2: Vision Integration
- **iOS:** Vision model integration, on-device detection
- **Backend:** Caching layer, error handling
- **DevOps:** Monitoring dashboard
- **Deliverable:** Point at 10 products → 6+ detected

### Week 3: Price Search
- **iOS:** Connect to backend, display prices
- **Backend:** Optimize scraping, add more sources
- **DevOps:** Scale testing
- **Deliverable:** See prices within 2 seconds

### Week 4: Integration & Polish
- **iOS:** Polish UI, error messages, edge cases
- **Backend:** Fine-tune latency, add logging
- **DevOps:** Load testing
- **Deliverable:** Complete MVP functionality

### Week 5: Optimization & Testing
- **iOS:** Performance, battery, memory
- **Backend:** Optimize algorithms, reduce latency
- **DevOps:** Final validation
- **Deliverable:** <800ms responses, zero crashes

### Week 6: Launch Preparation
- **iOS:** TestFlight build, final testing
- **Backend:** Production monitoring
- **DevOps:** Deployment, rollback plan
- **Deliverable:** Ready for beta launch

---

## 🎯 Success Criteria (MVP Complete)

### Functional
- ✅ Tap button → camera opens
- ✅ Point at product → detected (60%+ accuracy)
- ✅ See prices within 2 seconds
- ✅ See 3+ alternative retailers
- ✅ No crashes (graceful errors)

### Performance
- ✅ Detection: <200ms
- ✅ Backend response: <2s
- ✅ Total E2E: <2.5s
- ✅ Battery: <3% per hour usage

### Reliability
- ✅ 95%+ uptime
- ✅ 99%+ requests succeed
- ✅ 0% critical crashes
- ✅ Graceful degradation (always shows something)

### Cost
- ✅ $0/month (free tier)
- ✅ Scales to 100k DAU without costs
- ✅ No infrastructure management

---

## 🔑 Critical Dependencies

### On Other Teams/Services
- ✅ Mercado Libre API (public, working)
- ✅ OLX API (public, working)
- ✅ Amazon API (requires approval, 2-4 weeks)
- ✅ Vision Framework (iOS built-in)
- ✅ Firebase (Google owned, reliable)

### Internal Dependencies
- ✅ iOS team → Backend team (API design)
- ✅ Backend team → DevOps (deployment)
- ✅ All teams → Architecture decisions

---

## 📞 Questions to Answer Before Week 1

1. **Vision Model:** Use YOLO or MobileNet?
2. **ML Provider:** On-device or ML API?
3. **Retailers:** Which 100 sites to target?
4. **Currency:** ARS only or multi-currency?
5. **Location:** Buenos Aires only or Argentina-wide?
6. **Pricing:** Freemium model or free?

---

## 📄 Next Steps

1. **Today:** All agents read this file + `/claude.md`
2. **Tomorrow:** Setup meeting (30 min)
3. **Wednesday:** First code review
4. **Friday:** First working prototype
5. **Week 1:** Camera + Home screen done

---

**Status:** 🟢 Active
**Last Updated:** April 1, 2026
**Next Review:** Weekly on Fridays
