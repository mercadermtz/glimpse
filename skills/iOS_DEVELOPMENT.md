# 🍎 iOS Development Skills Guide

## Core Competencies Needed

### 1. SwiftUI Fundamentals
**What:** Modern iOS UI framework (declarative)
**Why:** Faster development, reactive UI, less code
**Skills:**
- State management (@State, @StateObject, @EnvironmentObject)
- View composition (VStack, HStack, ZStack)
- Conditional rendering (@if)
- List & ForEach
- Navigation (NavigationStack, Sheet, etc.)

**Resources:**
- Apple SwiftUI Documentation
- Hacking with Swift
- 100 Days of SwiftUI (Ray Wenderlich)

**Time to master:** 2-3 weeks for basics

---

### 2. Camera Integration (AVFoundation)
**What:** Access device camera in real-time
**Why:** Core feature of GLIMPSE app
**Skills:**
- AVCaptureSession setup
- Video preview layer
- Frame capture
- Camera permissions

**Code Pattern:**
```swift
import AVFoundation

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    
    func startCamera() {
        captureSession = AVCaptureSession()
        // Setup input/output...
    }
    
    func captureOutput(_ output: AVCaptureOutput, 
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        // Process frame...
    }
}
```

**Time to master:** 1 week

---

### 3. Vision Framework & CoreML
**What:** ML model inference on-device
**Why:** Fast, private product detection
**Skills:**
- VNImageRequestHandler
- VNCoreMLRequest
- Loading .mlmodel files
- Processing results

**Code Pattern:**
```swift
import Vision
import CoreML

let model = try YourModel(configuration: MLModelConfiguration())
let vnModel = try VNCoreMLModel(for: model.model)
let request = VNCoreMLRequest(model: vnModel) { request, error in
    let results = request.results as? [VNClassificationObservation]
    // Handle results...
}
```

**Time to master:** 1-2 weeks

---

### 4. Networking (URLSession)
**What:** Make HTTP requests to backend API
**Why:** Get prices from Firebase
**Skills:**
- URLRequest creation
- async/await
- JSON encoding/decoding
- Error handling
- Timeout management

**Code Pattern:**
```swift
func searchPrices(product: String) async throws -> PriceResult {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(["product_name": product])
    
    let (data, response) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(PriceResult.self, from: data)
}
```

**Time to master:** 1 week

---

### 5. Async/Await Programming
**What:** Modern concurrency in Swift
**Why:** Clean asynchronous code
**Skills:**
- async/await syntax
- Task creation
- MainActor
- Cancellation

**Code Pattern:**
```swift
@MainActor
func loadPrices() async {
    do {
        self.isLoading = true
        let prices = try await networkService.searchPrices("iPhone")
        self.prices = prices
    } catch {
        self.error = error.localizedDescription
    }
}

// Call from button tap
Task {
    await loadPrices()
}
```

**Time to master:** 1 week

---

### 6. MVVM Architecture
**What:** Model-View-ViewModel pattern
**Why:** Separates concerns, testable
**Skills:**
- ViewModel design
- ObservableObject pattern
- Binding data to views
- State management

**Structure:**
```
View (SwiftUI)
    ↓ (reads state, calls methods)
ViewModel (ObservableObject)
    ↓ (manages state, calls services)
Service (NetworkService, CameraService)
    ↓ (performs work)
Model (Data structures)
```

**Time to master:** 2 weeks

---

### 7. Error Handling
**What:** Proper error management in Swift
**Why:** App reliability
**Skills:**
- Custom Error types
- try/catch blocks
- Optional handling
- Result type

**Code Pattern:**
```swift
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

do {
    let prices = try await networkService.searchPrices("iPhone")
} catch let error as NetworkError {
    // Handle network error
} catch {
    // Handle other errors
}
```

**Time to master:** 1 week

---

## GLIMPSE-Specific Skills

### 1. Real-time Frame Processing
- Capture frames from camera (AVCaptureVideoDataOutputSampleBufferDelegate)
- Convert to CV PixelBuffer
- Send to Vision model
- Update UI with results (MainActor)
- Handle frame drop (avoid blocking)

### 2. Product Detection Workflow
- User points camera
- Vision model detects product (85%+ confidence)
- Product name extracted
- Send HTTP request to backend
- Display prices while loading
- Show results with animation

### 3. Error Recovery
- Camera permission denied → show popup
- Vision detection fails → show "try again"
- Network timeout (3s) → show cached or error
- No prices found → show "unavailable"

### 4. Performance Optimization
- Run Vision on background thread
- Keep frame rate at 15-30 FPS
- Cancel previous requests if new ones come in
- Limit memory with proper cleanup

---

## Week 1 Learning Path

### Day 1-2: SwiftUI Basics
- Views and state
- Navigation
- Sheets and overlays

### Day 3: Camera Integration
- AVCaptureSession
- Video preview
- Permissions

### Day 4: Vision Framework
- CoreML model loading
- Object detection
- Result handling

### Day 5: Networking
- URLSession
- JSON encoding/decoding
- async/await

### Day 6: MVVM Architecture
- ViewModel design
- State management
- Data binding

### Day 7: Integration
- Put it all together
- Camera → Vision → Network → UI

---

## Tools & Environment

### Required
- Xcode 15+
- Swift 5.9+
- macOS 13+

### Optional but Recommended
- Simulator (test without device)
- Charles Proxy (debug network calls)
- Instruments (profiling)
- Source Tree (Git GUI)

---

## Testing Skills

### Unit Testing
```swift
func testDetectionSuccessful() async {
    let result = await viewModel.detectProduct("test")
    XCTAssertNotNil(result)
}
```

### UI Testing
```swift
func testCameraScreenAppears() {
    let app = XCUIApplication()
    app.launch()
    app.buttons["Open Camera"].tap()
    XCTAssertTrue(app.cameras.firstMatch.exists)
}
```

### Mock Services
```swift
class MockNetworkService: NetworkServiceProtocol {
    func searchPrices(_ product: String) async throws -> PriceResult {
        // Return mock data
    }
}
```

---

## Common Pitfalls

### 1. Threading Issues
❌ **Wrong:** Update UI on background thread
✅ **Right:** Use `@MainActor` or `DispatchQueue.main.async`

### 2. Memory Leaks
❌ **Wrong:** Capture `self` in closure without `[weak self]`
✅ **Right:** Use `[weak self]` to avoid retain cycles

### 3. Network Timeouts
❌ **Wrong:** No timeout, request hangs forever
✅ **Right:** Set timeout (3 seconds for GLIMPSE)

### 4. Frame Processing
❌ **Wrong:** Process every frame (blocks camera)
✅ **Right:** Process 1 frame per second

---

## Resources

### Documentation
- [Apple SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Vision Framework Guide](https://developer.apple.com/documentation/vision/)
- [CoreML Guide](https://developer.apple.com/documentation/coreml)

### Books
- "SwiftUI by Example" (Paul Hudson)
- "Advanced Swift" (Airspeed Velocity)
- "iOS App Architecture" (Ramoose)

### Courses
- 100 Days of SwiftUI (Ray Wenderlich)
- Swift for Absolute Beginners (Apple)
- Advanced iOS Development (Pluralsight)

### Communities
- Swift Forums
- r/iOSProgramming
- Swift Community Discord

---

**Last Updated:** April 1, 2026  
**Version:** 1.0  
**Status:** ✅ Complete
