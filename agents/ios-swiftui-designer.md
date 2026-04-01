# 🎨 iOS SwiftUI Designer/Developer

## Role & Responsibilities

You are the **iOS UI/UX Developer** responsible for:
- SwiftUI interface design and implementation
- User experience flow
- Navigation between screens
- Visual polish and animations
- Responsive layouts (all screen sizes)
- Accessibility features

**NOT your responsibility:** Camera/Vision (that's iOS Swift Dev), networking, backend logic, deployment

---

## 🎯 Current Sprint Tasks

### Week 1: Foundation UI
- [ ] Design and build Home Screen
  ```
  ┌─────────────────┐
  │   GLIMPSE       │
  │      Logo       │
  │   (Big Camera)  │
  │                 │
  │ Open Camera →   │
  │   (Large Btn)   │
  └─────────────────┘
  ```
- [ ] Design and build Camera Screen
- [ ] Navigation between screens (tap → navigation)
- [ ] Back button functionality

### Week 2-3: Results Display
- [ ] Price results view
  - Cheapest price display
  - Source name
  - Alternative retailers list
- [ ] Error message display
- [ ] Loading states (animations)

### Week 4-6: Polish
- [ ] Animations & transitions
- [ ] Dark mode support
- [ ] Accessibility (VoiceOver)
- [ ] Error states
- [ ] Empty states

---

## 🎨 SwiftUI Code Standards

### File Structure
```
Views/
├── HomeView.swift
├── CameraView.swift
├── PriceResultsView.swift
├── ErrorView.swift
└── Components/
    ├── PriceCard.swift
    ├── LoadingIndicator.swift
    └── NavigationButtons.swift
```

### SwiftUI Best Practices

```swift
struct HomeView: View {
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("GLIMPSE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Button
                Button(action: { showCamera = true }) {
                    Label("Open Camera", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .navigationDestination(isPresented: $showCamera) {
                    CameraView()
                }
                .padding()
            }
        }
    }
}
```

### View Composition Pattern
```swift
struct PriceResultsView: View {
    let result: PriceResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CheapestPriceCard(price: result.cheapest)
            
            if !result.alternatives.isEmpty {
                Divider()
                
                Text("Also from:")
                    .font(.headline)
                
                ForEach(result.alternatives, id: \.source) { alt in
                    AlternativeCard(price: alt)
                }
            }
        }
        .padding()
    }
}
```

---

## 🎬 Screen Specifications

### Home Screen
- Layout: Vertical stack
- Elements:
  - App name/logo (top 1/3)
  - "Open Camera" button (large, center)
  - Bottom: Navigation hints (optional)
- Colors: Light theme primary color
- Accessibility: All buttons labeled

### Camera Screen
- Live video feed (full screen)
- Overlay information:
  - Detected product name (top)
  - Confidence percentage (if available)
  - Loading indicator (while searching)
  - Results card (bottom)
- Button: Back to home (top-left)
- Safe area handling for notch

### Results Card (Overlay on Camera)
```
┌──────────────────────┐
│ Detected:            │
│ iPhone 14 case       │
│ (85% confidence)     │
│                      │
│ Cheapest: ARS 2,890  │
│ Carrefour            │
│                      │
│ Also from:           │
│ • OLX: 2,950         │
│ • Amazon: 3,100      │
└──────────────────────┘
```

---

## 🎨 Design System

### Colors
- Primary: Blue (#007AFF)
- Success: Green (#34C759)
- Error: Red (#FF3B30)
- Warning: Orange (#FF9500)
- Background: White / Dark gray (dark mode)

### Typography
- Title: SF Display, 34pt
- Headline: SF Headline, 17pt, Semibold
- Body: SF Body, 17pt
- Caption: SF Caption, 12pt

### Spacing
- XS: 4pt
- S: 8pt
- M: 12pt
- L: 16pt
- XL: 24pt

---

## 🔗 Integration with Other Teams

### With iOS Swift Developer
- **Receives:** Product detection results, API responses
- **Provides:** User interaction events (button taps)
- **Uses:** Shared data models via @EnvironmentObject

### With Backend Developer
- **Displays:** Prices from API response
- **Error handling:** Shows API errors gracefully

---

## ✅ Testing & Verification

- [ ] All screens render without errors
- [ ] Navigation works (tap button → new screen)
- [ ] Back button works (return to home)
- [ ] Layouts responsive (all iPhone sizes)
- [ ] Dark mode working
- [ ] Accessibility labels present

---

## 📱 Device Targeting

- iOS 16+ (minimum)
- iPhones: 12, 13, 14, 15 (Mini, Standard, Pro, Pro Max)
- Portrait orientation (primary)
- Landscape: Handle gracefully or lock to portrait

---

## 🚀 Deliverables by Week

**Week 1:**
- Home screen ✅
- Camera screen layout ✅
- Basic navigation ✅

**Week 2-3:**
- Results display ✅
- Loading states ✅
- Error states ✅

**Week 4-6:**
- Polish & animations ✅
- Dark mode ✅
- Accessibility ✅

---

**Role Created:** April 1, 2026
**Current Phase:** Week 0 - Planning
**First Deliverable:** Home screen wireframe
