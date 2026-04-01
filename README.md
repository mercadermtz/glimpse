# 🍎 GLIMPSE - Multi-Agent AI Repository

## Welcome to the AI-Orchestrated Development Repository

This repository is designed for **multi-agent AI development** using Claude with specialized agents for each domain.

```
GLIMPSE MVP
├─ iOS App (Swift + SwiftUI)
├─ Backend (Python + Firebase)
└─ DevOps (Cloud Functions + Deployment)
```

**Get a Glimpse of Every Price** - AR-powered price comparison for Argentina

---

## 🤖 Quick Start for AI Agents

### Step 1: Agents Load Context
All agents should read these files **in this order:**

1. **`/claude.md`** ← START HERE
   - Project overview
   - Agent roles & communication
   - Quick start guide

2. **`.claude/context.md`**
   - Complete project specifications
   - Architecture overview
   - Timeline & success criteria

3. **Your Role File** (choose one):
   - `agents/ios-swift-developer.md` → If you're iOS Swift dev
   - `agents/ios-swiftui-designer.md` → If you're iOS UI/UX dev
   - `agents/backend-python-developer.md` → If you're Backend dev
   - `agents/devops-engineer.md` → If you're DevOps

4. **`.claude/standards.md`**
   - Code standards (Swift, Python)
   - Documentation requirements
   - Code review process

5. **`.claude/tasks.md`**
   - Current task queue
   - Assignment & deadlines
   - Verification criteria

### Step 2: Check Status & Blockers
- Read: `.claude/progress.md` - Current progress
- Read: `.claude/blockers.md` - Any blockers (if exists)
- Read: `.claude/decisions.md` - Architecture decisions

### Step 3: Start Working
- Pick a task from `.claude/tasks.md`
- Follow standards from `.claude/standards.md`
- Coordinate with other agents via shared files

---

## 📁 Repository Structure

```
Glimpse_Repo/
├── claude.md                          ← 🎯 MAIN ENTRY POINT
│
├── .claude/                           ← Project Configuration
│   ├── context.md                     (Project specs & architecture)
│   ├── standards.md                   (Code/doc standards)
│   ├── tasks.md                       (Task queue)
│   ├── progress.md                    (Weekly progress)
│   ├── blockers.md                    (Current blockers)
│   ├── decisions.md                   (Architecture decisions)
│   └── architecture.md                (System design)
│
├── agents/                            ← Agent Role Definitions
│   ├── ios-swift-developer.md         (iOS core logic)
│   ├── ios-swiftui-designer.md        (iOS UI/UX)
│   ├── backend-python-developer.md    (Firebase/Python)
│   └── devops-engineer.md             (Deployment/CI-CD)
│
├── docs/                              ← Technical Documentation (EMPTY - TO FILL)
│   ├── architecture.md                (System design details)
│   ├── api-specification.md           (Backend API)
│   ├── ios-requirements.md            (iOS specs)
│   └── deployment-guide.md            (How to deploy)
│
├── skills/                            ← Domain Skills & Patterns (EMPTY - TO FILL)
│   ├── ios-development.md
│   ├── backend-development.md
│   ├── firebase-deployment.md
│   └── testing-verification.md
│
├── rules/                             ← Project Rules (EMPTY - TO FILL)
│   ├── code-standards.md
│   ├── documentation-standards.md
│   ├── git-workflow.md
│   └── communication-protocol.md
│
├── .github/                           ← GitHub Config (EMPTY - TO FILL)
│   └── workflows/
│       └── deploy.yml                 (CI/CD pipeline)
│
└── README.md                          (THIS FILE)
```

---

## 🚀 For Each Agent Type

### 🍎 iOS Swift Developer
**Your Responsibilities:**
- Camera integration (AVFoundation)
- Vision model integration (CoreML)
- API client & networking
- Data models & error handling

**Start:** Read `/agents/ios-swift-developer.md`

### 🎨 iOS SwiftUI Designer
**Your Responsibilities:**
- UI/UX design & implementation
- SwiftUI components
- Navigation & state management
- Accessibility & animations

**Start:** Read `/agents/ios-swiftui-designer.md`

### 🔧 Backend Python Developer
**Your Responsibilities:**
- Firebase Cloud Functions
- Multi-source price scraping
- Caching layer (Firestore)
- Error handling & optimization

**Start:** Read `/agents/backend-python-developer.md`

### ⚙️ DevOps Engineer
**Your Responsibilities:**
- Firebase setup & configuration
- Cloud Function deployment
- CI/CD pipeline
- Monitoring & alerting

**Start:** Read `/agents/devops-engineer.md`

---

## 📋 Project Status

```
📊 Overall Progress: 15%
🟢 Status: Active
📅 Phase: Week 0 - Setup & Validation
👥 Team: 4 AI Agents
🎯 Goal: iOS app with real-time price comparison via AR
```

### Weekly Status
- **Week 0:** Setup & validation (IN PROGRESS)
- **Week 1:** Foundation (SCHEDULED)
- **Week 2:** Vision integration (SCHEDULED)
- **Week 3:** Price scraping (SCHEDULED)
- **Week 4:** Integration (SCHEDULED)
- **Week 5:** Optimization (SCHEDULED)
- **Week 6:** Launch preparation (SCHEDULED)

---

## 🔄 Communication Protocol

### Daily Standup
- Read `.claude/progress.md`
- Check `.claude/tasks.md`
- Work on assigned task
- Update progress at end of day

### Blockers
- If blocked: Add to `.claude/blockers.md`
- Escalate in next sync point
- Decision documented in `.claude/decisions.md`

### Code Changes
- Follow `.claude/standards.md`
- Create clear commit messages
- Coordinate with other agents

---

## ✅ Success Criteria for MVP

### Functional ✅
- Tap button → camera opens
- Point at product → detected (60%+ accuracy)
- See prices within 2 seconds
- 3+ alternative retailers shown
- No crashes (graceful errors)

### Performance ✅
- Detection: <200ms
- Backend response: <2s
- Total E2E: <2.5s
- Battery: <3% per hour

### Reliability ✅
- 95%+ uptime
- 0% crashes
- Graceful degradation

### Cost ✅
- $0/month (Firebase free tier)
- Scales to 100k DAU cost-free

---

## 📞 Need Help?

### Questions?
- Your role? → Read `agents/your-role.md`
- Code standards? → Read `.claude/standards.md`
- System architecture? → Read `.claude/context.md`
- Current tasks? → Read `.claude/tasks.md`
- Any blockers? → Check `.claude/blockers.md`

### Blockers?
1. Add to `.claude/blockers.md`
2. Notify team
3. Wait for next sync point
4. Decision recorded in `.claude/decisions.md`

---

## 🎯 Key Insights

### Multi-Agent Orchestration
- Each agent specializes in one domain
- Shared context files (all agents read same specs)
- Clear task queue & status tracking
- Asynchronous communication via files

### Development Pattern
1. **Understand:** Read all context files
2. **Plan:** Check task queue
3. **Execute:** Follow standards, write code
4. **Communicate:** Update progress files
5. **Verify:** Get code reviewed by another agent

### Quality Gates
- ✅ Tests passing
- ✅ Code standards followed
- ✅ Documentation complete
- ✅ Peer review approved
- ✅ Integration tested

---

## 📚 Learning Resources

For all agents:
- `/claude.md` - Main project guide
- `.claude/context.md` - Complete specifications
- `.claude/standards.md` - Code standards
- `agents/your-role.md` - Your specific role

---

## 🚀 Getting Started Right Now

1. You are an AI Agent
2. Read `/claude.md` (5 min)
3. Read `.claude/context.md` (10 min)
4. Read your role file (15 min)
5. Read `.claude/tasks.md` (5 min)
6. Pick a task and start! 🚀

---

## 📝 Important Files

| File | Purpose | For Whom |
|------|---------|----------|
| `/claude.md` | Project overview | ALL |
| `.claude/context.md` | Specifications | ALL |
| `.claude/standards.md` | Code standards | ALL |
| `.claude/tasks.md` | Task queue | ALL |
| `.claude/progress.md` | Status | ALL |
| `agents/your-role.md` | Your role | Individual agents |

---

**Last Updated:** April 1, 2026
**Project Status:** 🟢 Active
**Next Sync:** Daily at 9 AM

**Ready to build? Read `/claude.md` and let's go! 🚀**
