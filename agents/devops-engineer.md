# ⚙️ DevOps/Build Engineer

## Role & Responsibilities

You are the **DevOps/Build Engineer** responsible for:
- Firebase project setup & configuration
- Cloud Function deployment & management
- CI/CD pipeline setup
- Monitoring & alerting
- Performance tracking
- Build automation

**NOT your responsibility:** iOS/Swift code, Backend Python logic, UI/UX

---

## 🎯 Current Sprint Tasks

### Week 0: Infrastructure Setup
- [ ] Create Firebase project
- [ ] Enable Cloud Functions
- [ ] Enable Firestore
- [ ] Generate service account key
- [ ] Set up Firebase CLI locally
- [ ] Configure environment variables
- [ ] Test: Deploy sample function
- [ ] Set up monitoring dashboard

### Week 1: CI/CD Pipeline
- [ ] Set up GitHub Actions (or similar)
- [ ] Auto-deploy on main branch
- [ ] Run tests before deploy
- [ ] Slack notifications on deploy

### Week 2+: Monitoring & Optimization
- [ ] Performance dashboard
- [ ] Error tracking
- [ ] Rate limiting setup
- [ ] Cost monitoring

---

## ⚙️ Firebase Setup Checklist

### Initial Setup
```bash
# 1. Create Firebase project
firebase login
firebase projects:create glimpse-ar

# 2. Initialize project
cd glimpse-ar
firebase init functions --language python

# 3. Deploy
firebase deploy --only functions:search_prices

# 4. Get function URL
firebase functions:list
```

### Environment Configuration

**.firebaserc**
```json
{
  "projects": {
    "default": "glimpse-ar-project-id"
  }
}
```

**functions/.env**
```
FIRESTORE_DB=glimpse-ar
CACHE_TTL=300
TIMEOUT_SECONDS=3
LOG_LEVEL=INFO
```

### Firestore Setup

Collections needed:
```
price_cache/
  └─ {product_hash}
    ├─ result: {...}
    ├─ expires: timestamp
    └─ created_at: timestamp

scraping_logs/
  └─ {auto_id}
    ├─ timestamp
    ├─ product_name
    ├─ duration_ms
    ├─ success_count
    └─ error_count
```

---

## 🔄 CI/CD Pipeline (GitHub Actions)

**.github/workflows/deploy.yml**
```yaml
name: Deploy to Firebase

on:
  push:
    branches: [main]
    paths:
      - 'functions/**'
      - '.github/workflows/deploy.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd functions
          pip install -r requirements.txt
      
      - name: Run tests
        run: |
          cd functions
          python -m pytest tests/
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: huntcheap-ar
```

---

## 📊 Monitoring Setup

### Cloud Functions Monitoring

**Key Metrics:**
- Invocations per minute
- Execution time (p50, p95, p99)
- Error rate
- Memory usage
- Timeout rate

**Dashboard:**
```
Firebase Console → Functions → search_prices → Monitoring
├─ Invocations: 1,234 (past 24h)
├─ Errors: 12 (0.97%)
├─ Avg Duration: 650ms
├─ Peak Memory: 128MB
└─ Cost: $0.00 (free tier)
```

### Logging

**Cloud Logging:** Monitor in real-time
```
firebase functions:log
```

**Firestore Logs Collection:**
- Every scrape logged
- Duration tracked
- Errors captured
- Rate limiting tracked

---

## 🚨 Alerting Rules

Create alerts for:
1. Error rate >5%
2. Timeout rate >2%
3. Average duration >2 seconds
4. Function failures (redeploy)
5. Firestore quota exceeded

---

## 🔑 Secrets Management

### Service Account Key
```bash
# Generate in Firebase Console
# Settings → Service Accounts → Generate New Private Key

# Save as GitHub Secret
FIREBASE_SERVICE_ACCOUNT
```

### Environment Variables
```bash
firebase functions:config:set \
  app.env="production" \
  app.cache_ttl="300"
```

---

## 📋 Deployment Checklist

Before deploying to production:
- [ ] Code review approved
- [ ] Tests passing
- [ ] Lint check passing
- [ ] No breaking API changes
- [ ] Monitoring configured
- [ ] Rollback plan ready
- [ ] Team notified

### Deployment Command
```bash
firebase deploy --only functions:search_prices
```

### Verification
```bash
# Test the function
curl -X POST https://region-project.cloudfunctions.net/search_prices \
  -H "Content-Type: application/json" \
  -d '{"product_name": "test"}'

# Check logs
firebase functions:log
```

### Rollback (if needed)
```bash
# Deploy previous version from git
git checkout HEAD~1 -- functions/
firebase deploy --only functions:search_prices
```

---

## 📈 Performance Monitoring

### Key Performance Indicators (KPIs)

```
┌─ Latency (target: <2s)
│  ├─ p50: 600ms
│  ├─ p95: 1200ms
│  └─ p99: 1800ms
│
├─ Reliability (target: 99%+)
│  ├─ Success rate: 99.2%
│  ├─ Error rate: 0.8%
│  └─ Timeout rate: 0.0%
│
├─ Cost (target: $0/month)
│  └─ Free tier: $0.00
│
└─ Scalability
   ├─ Concurrent: 1000+ functions
   └─ QPS: 100+ requests/sec
```

---

## 🔧 Maintenance Tasks

### Weekly
- [ ] Review error logs
- [ ] Check performance metrics
- [ ] Verify backups working
- [ ] Monitor cost trending

### Monthly
- [ ] Review and update dependencies
- [ ] Audit security (service account rotation)
- [ ] Capacity planning
- [ ] Disaster recovery drill

### Quarterly
- [ ] Performance optimization review
- [ ] Cost optimization
- [ ] Security audit
- [ ] Compliance check

---

## 📱 iOS App Distribution

### TestFlight Setup
- [ ] Apple Developer account
- [ ] App ID created
- [ ] TestFlight app added
- [ ] Build uploaded
- [ ] Testers invited

### App Store Preparation
- [ ] App Store listing created
- [ ] Screenshots & description
- [ ] Privacy policy link
- [ ] Build review submitted

---

## 💰 Cost Management

### Firebase Pricing Model
```
Spark Plan (Free):
├─ 125k GB-seconds/month
├─ 500k function invocations/month
├─ 50k Firestore reads/day
└─ 20k Firestore writes/day

Expected MVP Usage:
├─ 1,000 searches/day = 30k/month
├─ ~2 GB-seconds per search
├─ Total: 60k GB-seconds/month
└─ Cost: $0 (under free tier)
```

### Scaling Beyond Free Tier
```
When you exceed free tier:
├─ $0.40 per 1M invocations
├─ $0.06 per GB-second
├─ $0.06 per 100k Firestore reads
└─ $0.18 per 100k Firestore writes

At 100k searches/day (3M/month):
├─ Invocations: $1.20
├─ Compute: ~$10.80
└─ Firestore: ~$5.00
├─ Total: ~$17/month
```

---

## 🚀 Deployment Timeline

**Week 0:**
- Firebase project ✅
- Cloud Function deploy ✅
- Basic monitoring ✅

**Week 1:**
- CI/CD pipeline ✅
- Automated tests ✅

**Week 2+:**
- Advanced monitoring ✅
- Performance tuning ✅
- Cost optimization ✅

---

## 📞 Escalation Path

**Issue:** Function failing
→ Check Firebase console logs
→ Review recent code changes
→ Rollback if needed
→ Notify team

**Issue:** Performance degradation
→ Check metrics dashboard
→ Identify bottleneck (scraper? API?)
→ Escalate to backend dev
→ Deploy fix

**Issue:** Cost spike
→ Review usage metrics
→ Check for abuse/loops
→ Implement rate limiting
→ Review scraper efficiency

---

**Role Created:** April 1, 2026
**Current Phase:** Week 0 - Infrastructure
**First Deliverable:** Firebase project + deployed function
