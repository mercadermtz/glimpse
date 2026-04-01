# 🤖 GLIMPSE - Claude AI Orchestration

## Project Overview

**Project:** GLIMPSE MVP - iOS App for Real-Time Price Comparison via AR Camera

**Vision:** Point your iPhone at any product → Get a glimpse of prices from 100+ retailers instantly

**Tagline:** "Get a Glimpse of Every Price"

**Duration:** 6 weeks

**Architecture:**
- **Frontend:** iOS (Swift, SwiftUI, Vision, CoreML)
- **Backend:** Firebase Cloud Functions (Python)
- **Database:** Firestore (caching)
- **Scraping:** 100+ retail websites (parallel asyncio)

---

## 🤖 AI Agent Orchestration

This project uses a multi-agent system where each AI agent specializes in a specific domain:

### Agent Roles & Responsibilities

```
┌─────────────────────────────────────────────────────────────────┐
│                     Project Management                          │
│                  (Coordination & Planning)                       │
└─────────────────────────────────────────────────────────────────┘
         ↓                          ↓                        ↓
    ┌────────────────┐      ┌─────────────────┐    ┌──────────────┐
    │ iOS Developer  │      │ Backend Dev     │    │ DevOps/Build │
    │ (Swift/SwiftUI)│      │ (Python/Firebase)    │ Engineer     │
    └────────────────┘      └─────────────────┘    └──────────────┘
         ↓                          ↓                        ↓
    iOS App                 Price Scraper            Deployment
    ├─ Camera               ├─ Parallel Asyncio      ├─ Firebase
    ├─ Vision Model         ├─ 100+ Websites        ├─ CLI Scripts
    ├─ SwiftUI UI           ├─ Caching              └─ Monitoring
    └─ API Client           └─ Error Handling
```

### Communication Protocol

- **Shared Context:** All agents read from `/docs` and `.claude/context.md`
- **Task Distribution:** Tasks assigned via `.claude/tasks.md`
- **Code Review:** Agent outputs verified against `.claude/standards.md`
- **Escalation:** Cross-agent issues reviewed by Project Manager

---

## 📋 Agent Availability & Load

### Active Agents

```
┌─ iOS Developers (2 agents)
│  ├─ iOS Swift Core Developer
│  └─ iOS SwiftUI Designer/Developer
│
├─ Backend Developers (1 agent)
│  └─ Backend Python/Firebase Developer
│
└─ DevOps (1 agent)
   └─ DevOps/Build Engineer
```

### Context Window Management

Each agent operates with:
- **Context:** Up to 100K tokens
- **Shared Files:** From `/docs` folder
- **Task Queue:** From `.claude/tasks.md`
- **Standards:** From `.claude/standards.md`
- **Skills:** Specialized in their domain

---

## 🚀 Quick Start for Agents

### Step 1: Load Context
All agents should read these files first:
1. `/claude.md` (this file)
2. `.claude/context.md` (project context)
3. `.claude/standards.md` (code/documentation standards)
4. `.claude/tasks.md` (current task queue)

### Step 2: Understand Your Role
- iOS developers → Read `agents/ios-developer.md`
- Backend developers → Read `agents/backend-developer.md`
- DevOps → Read `agents/devops-engineer.md`

### Step 3: Check Skills & Rules
- Custom skills in `skills/` folder
- Project rules in `rules/` folder
- Architecture rules in `.claude/architecture.md`

### Step 4: Start Working
- Pick next task from `.claude/tasks.md`
- Follow standards from `.claude/standards.md`
- Document progress in `.claude/progress.md`

---

## 🎯 Current Phase & Goals

### Phase: Week 0 Setup & Validation

**Current Goal:** Set up project infrastructure and validate all APIs

**Milestone:** Have working Firebase function that scrapes prices

**Success Criteria:**
- ✅ Firebase project created
- ✅ Cloud Function deployed
- ✅ 3 retail websites scraped successfully
- ✅ Response <2 seconds

---

## 📊 Project Dashboard

```
Status:         🟢 IN PROGRESS
Phase:          Week 0 - Setup
Sprint:         1/6 weeks complete
Team Size:      4 AI agents
Completion:     ~15%
Blockers:       0
Risk Level:     🟢 LOW
```

---

## 🔗 Key Files & Navigation

### Configuration Files
- `.claude/claude.md` → **YOU ARE HERE**
- `.claude/context.md` → Project context & spec
- `.claude/standards.md` → Code/doc standards
- `.claude/tasks.md` → Task queue
- `.claude/progress.md` → Weekly progress
- `.claude/architecture.md` → Architecture decisions

### Agent Specs
- `agents/ios-swift-developer.md` → iOS core
- `agents/ios-swiftui-designer.md` → UI/UX
- `agents/backend-python-developer.md` → Backend
- `agents/devops-engineer.md` → Deployment

### Skills
- `skills/ios-development.md`
- `skills/backend-development.md`
- `skills/firebase-deployment.md`
- `skills/testing-verification.md`

### Rules & Standards
- `rules/code-standards.md`
- `rules/documentation-standards.md`
- `rules/git-workflow.md`
- `rules/communication-protocol.md`

### Documentation
- `docs/architecture.md` → System design
- `docs/api-specification.md` → Backend API
- `docs/ios-requirements.md` → iOS specs
- `docs/deployment-guide.md` → How to deploy

---

## 🔄 Workflow for Multi-Agent Development

### Daily Standup Pattern
1. Each agent reads `.claude/progress.md`
2. Check `.claude/tasks.md` for today's priorities
3. Read `.claude/blockers.md` if any
4. Start working on assigned tasks
5. Update progress at end of day

### Task Assignment Pattern
```
Task: Build iOS Camera Screen
Assigned To: iOS SwiftUI Designer
Status: In Progress
Deadline: Wednesday
Verification: Can tap button → camera opens & can tap back
```

### Code Review Pattern
1. Agent completes task
2. Follows `.claude/standards.md`
3. Creates merge request with summary
4. Other agents review
5. Merge when approved

### Escalation Pattern
- Issue blocking multiple agents → Escalate to PM
- Architectural decision needed → Review `.claude/architecture.md`
- Cross-agent conflict → Resolve via communication protocol

---

## 📞 Communication Guidelines

### Sync Points (Recommended)
- **Daily:** 9 AM - Brief standup (5 min per agent)
- **Tuesday:** Mid-week check-in (15 min)
- **Friday:** Weekly review & planning (30 min)

### Async Communication
- **Task updates:** Via `.claude/tasks.md`
- **Progress:** Via `.claude/progress.md`
- **Issues:** Via `.claude/blockers.md`
- **Decisions:** Via `.claude/decisions.md`

### Escalation Path
1. Try to resolve between agents
2. If blocked, add to `.claude/blockers.md`
3. Review in next sync point
4. Document decision in `.claude/decisions.md`

---

## ⚙️ Project Setup Checklist

- [ ] Firebase project created
- [ ] Service account key generated
- [ ] Local development environment set up
- [ ] Git repo initialized
- [ ] All agents have read `.claude/` files
- [ ] First task assigned
- [ ] Daily standup scheduled

---

## 🎓 Learning Resources

Each agent should be familiar with:

**All Agents:**
- `/docs/architecture.md` - System overview
- `rules/communication-protocol.md` - How we talk
- `rules/git-workflow.md` - Git process

**iOS Developers:**
- `docs/ios-requirements.md` - Requirements
- `skills/ios-development.md` - iOS patterns
- `agents/ios-swift-developer.md` - Swift specifics

**Backend Developers:**
- `docs/api-specification.md` - API design
- `skills/backend-development.md` - Backend patterns
- `agents/backend-python-developer.md` - Python/Firebase specifics

**DevOps:**
- `docs/deployment-guide.md` - Deployment steps
- `skills/firebase-deployment.md` - Firebase setup
- `agents/devops-engineer.md` - DevOps role

---

## 🚨 Critical Path & Dependencies

```
Week 0 (Setup):
├─ Firebase project created (DevOps)
├─ iOS project setup (iOS Swift Dev)
└─ Backend scaffold (Backend Dev)
    ↓ (These must complete before Week 1)

Week 1 (Foundation):
├─ Camera screen UI (iOS SwiftUI)
├─ Home screen (iOS SwiftUI)
└─ Cloud Function scaffold (Backend)
    ↓

Week 2 (Vision Integration):
├─ Vision model integration (iOS Swift)
├─ Caching layer (Backend)
    ↓

Week 3 (Price Scraping):
├─ Multi-source scraper (Backend)
    ↓

Week 4 (Integration):
├─ Connect iOS ↔ Backend (All)
    ↓

Week 5 (Polish):
├─ Optimize (All)
├─ Error handling (All)
    ↓

Week 6 (Launch):
└─ TestFlight (DevOps + iOS)
```

---

## ✅ Success Criteria for Project

**Week 0:** ✅ All setup complete
**Week 1-5:** ✅ Each weekly milestone met
**Week 6:** ✅ TestFlight ready with:
- ✅ Vision detection ≥60% accuracy
- ✅ Price results <2 seconds
- ✅ Zero crashes
- ✅ 95%+ uptime

---

## 📧 Need Help?

**Questions about:**
- **Your role** → Read `agents/your-role.md`
- **Code standards** → Read `rules/code-standards.md`
- **Architecture** → Read `docs/architecture.md`
- **Deployment** → Read `docs/deployment-guide.md`
- **Tasks** → Check `.claude/tasks.md`
- **Blockers** → Check `.claude/blockers.md`
- **Decisions** → Check `.claude/decisions.md`

---

**Last Updated:** April 1, 2026
**Project Status:** 🟢 Active
**Next Sync:** Daily at 9 AM
