# 📱 GLIMPSE - iOS Development Guide

## Setup & Environment

### Prerequisites
- macOS 13+ (Ventura or later)
- Xcode 15+
- Swift 5.9+
- CocoaPods (for dependency management)
- iPhone 12+ (A14 Bionic+)
- iOS 16+

### Project Creation

```bash
# Create new iOS project
xcode -new-project Glimpse --framework SwiftUI --language Swift

# Or via command line
mkdir Glimpse && cd Glimpse
swift package init --type app

# Install dependencies
pod init
pod install
```

### Dependencies (CocoaPods)

```podfile
platform :ios, '16.0'

target 'Glimpse' do
  pod 'Alamofire'              # Optional: HTTP client (we use URLSession)
  pod 'Kingfisher'             # Optional: Image caching
  pod 'Firebase/Functions'     # Optional: Firebase SDK
  
  target 'GlimpseTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end
```

---

## 🏗️ Project Structure

```
Glimpse/
├── Sources/
│   ├── App/
│   │   ├── GlimpseApp.swift              ← Main entry point
│   │   └── AppState.swift
│   │
│   ├── Views/
│   │   ├── HomeScreen.swift              ← Home UI
│   │   ├── CameraScreen.swift            ← Camera + Vision UI
│   │   ├── PriceResultView.swift         ← Results display
│   │   └── Components/
│   │       ├── CameraPreview.swift
│   │       ├── PriceCard.swift
│   │       └── LoadingIndicator.swift
│   │
│   ├── ViewModels/
│   │   ├── CameraViewModel.swift         ← Camera logic
│   │   ├── PriceSearchViewModel.swift    ← Search & state
│   │   └── AppViewModel.swift            ← Global state
│   │
│   ├── Models/
│   │   ├── Product.swift                 ← Data models
│   │   ├── PriceResult.swift
│   │   ├── DetectionResult.swift
│   │   └── APIResponse.swift
│   │
│   ├── Services/
│   │   ├── PriceSearchService.swift      ← API calls
│   │   ├── CameraService.swift           ← Camera management
│   │   ├── VisionService.swift           ← ML detection
│   │   └── NetworkService.swift          ← Network utilities
│   │
│   ├── Utilities/
│   │   ├── Constants.swift               ← App constants
│   │   ├── Extensions.swift              ← Swift extensions
│   │   └── Logging.swift                 ← Debug logging
│   │
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Localizable.strings
│       └── Models/
│           └── product_detection.mlmodel ← CoreML model
│
├── Tests/
│   ├── CameraViewModelTests.swift
│   ├── PriceSearchServiceTests.swift
│   ├── NetworkServiceTests.swift
│   └── MockServices.swift
│
├── Podfile
├── Podfile.lock
└── README.md
```

---

## 📐 UI Screens

### Screen 1: Home Screen

```swift
struct HomeScreen: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(#colorLiteral(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)), // Electric Blue
                    Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "binoculars")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("GLIMPSE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Get a Glimpse of Every Price")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Open Camera Button
                Button(action: { /* Navigate to camera */ }) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        Text("Open Camera")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(14)
                    .shadow(radius: 8)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
    }
}
```

### Screen 2: Camera Screen

```swift
struct CameraScreen: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview()
                .ignoresSafeArea()
            
            VStack {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Point at Product")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "flashlight.on.fill")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                Spacer()
                
                // Detection overlay
                if let product = viewModel.detectedProduct {
                    VStack(spacing: 12) {
                        Text(product)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            Text("Confidence:")
                            Text("\(Int(viewModel.confidence * 100))%")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.green)
                        .font(.subheadline)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding()
                }
                
                Spacer()
                
                // Results section
                if let prices = viewModel.prices {
                    PriceResultView(prices: prices)
                        .transition(.move(edge: .bottom))
                } else if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                        Text("Searching...")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
    }
}
```

---

## 🧠 Vision & CoreML Integration

### Vision Setup

```swift
import Vision
import CoreML

class VisionService {
    private var requests: [VNRequest] = []
    private let model: VNCoreMLModel
    
    init() throws {
        // Load CoreML model
        let mlModel = try YourProductDetectionModel(configuration: MLModelConfiguration())
        self.model = try VNCoreMLModel(for: mlModel.model)
        setupRequests()
    }
    
    private func setupRequests() {
        let request = VNCoreMLRequest(model: model) { request, error in
            self.processDetectionResults(request)
        }
        request.imageCropAndScaleOption = .centerCrop
        self.requests = [request]
    }
    
    func detectProduct(from pixelBuffer: CVPixelBuffer) throws -> (product: String, confidence: Float) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try handler.perform(requests)
    }
    
    private func processDetectionResults(_ request: VNRequest) {
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        let topResult = results.first
        let productName = topResult?.identifier ?? "Unknown"
        let confidence = Float(topResult?.confidence ?? 0.0)
        
        DispatchQueue.main.async {
            // Update UI with results
        }
    }
}
```

### CoreML Model Integration

```swift
// Use a pre-trained model (MobileNet or YOLO-based)
// Download from: ML Model Marketplace

// Steps:
// 1. Download product detection model (.mlmodel file)
// 2. Add to Xcode project (Glimpse target)
// 3. Xcode auto-generates Swift interface
// 4. Use in VisionService as shown above

// Model characteristics:
// - Input: 224x224 RGB image
// - Output: Classification with 1000+ product categories
// - Size: ~50-100 MB
// - Latency: ~100-200ms on A14+ chips
```

---

## 🌐 Network Service

### URLSession Setup

```swift
class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://us-central1-glimpse-ar.cloudfunctions.net"
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    func searchPrices(product: String) async throws -> PriceSearchResponse {
        guard let url = URL(string: "\(baseURL)/search_prices") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = SearchRequest(product_name: product)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(PriceSearchResponse.self, from: data)
    }
}
```

---

## 📊 Data Models

```swift
// API Request
struct SearchRequest: Codable {
    let product_name: String
}

// API Response
struct PriceSearchResponse: Codable {
    struct PriceSource: Codable {
        let price: Int
        let currency: String
        let source: String
        let url: String
    }
    
    let product: String
    let cheapest: PriceSource
    let alternatives: [PriceSource]
    let timestamp: String
    let cached: Bool?
    let sources_queried: Int?
}

// Detection Result
struct DetectionResult {
    let product: String
    let confidence: Float
    let timestamp: Date
}

// ViewModel State
@MainActor
class CameraViewModel: ObservableObject {
    @Published var isDetecting = false
    @Published var detectedProduct: String?
    @Published var confidence: Float = 0.0
    @Published var prices: PriceSearchResponse?
    @Published var error: String?
    @Published var isLoading = false
    
    private let visionService: VisionService
    private let networkService: NetworkService
    
    init() {
        self.visionService = try! VisionService()
        self.networkService = NetworkService.shared
    }
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        Task {
            do {
                let (product, confidence) = try visionService.detectProduct(from: pixelBuffer)
                
                if confidence > 0.60 {
                    await MainActor.run {
                        self.detectedProduct = product
                        self.confidence = confidence
                        self.isLoading = true
                    }
                    
                    let prices = try await networkService.searchPrices(product: product)
                    
                    await MainActor.run {
                        self.prices = prices
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
```

---

## 🧪 Testing

```swift
import XCTest
@testable import Glimpse

class CameraViewModelTests: XCTestCase {
    var sut: CameraViewModel!
    var mockVisionService: MockVisionService!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockVisionService = MockVisionService()
        mockNetworkService = MockNetworkService()
        sut = CameraViewModel()
    }
    
    func testDetectionSuccessful() async {
        // Given
        let mockPixelBuffer = CVPixelBuffer()
        mockVisionService.detectionResult = ("iPhone case", 0.85)
        
        // When
        sut.processFrame(mockPixelBuffer)
        
        // Then
        XCTAssertEqual(sut.detectedProduct, "iPhone case")
        XCTAssertEqual(sut.confidence, 0.85)
    }
    
    func testPriceSearchTriggeredOnHighConfidence() async {
        // Given
        mockVisionService.detectionResult = ("iPhone case", 0.85)  // > 0.60 threshold
        
        // When
        let pixelBuffer = CVPixelBuffer()
        sut.processFrame(pixelBuffer)
        
        // Then
        XCTAssertTrue(mockNetworkService.searchPricesCalled)
    }
    
    func testErrorHandling() async {
        // Given
        mockNetworkService.shouldThrowError = true
        mockVisionService.detectionResult = ("iPhone case", 0.85)
        
        // When
        sut.processFrame(CVPixelBuffer())
        
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertNil(sut.prices)
    }
}
```

---

## 🚀 Performance Optimization

### Best Practices

1. **Vision Detection**
   - Run on background thread
   - Cache Vision request
   - Use lower resolution for faster detection

2. **Network Requests**
   - Use URLSessionConfiguration with timeouts
   - Implement request cancellation
   - Handle timeouts gracefully

3. **Memory Management**
   - Release pixel buffers after processing
   - Limit cache size
   - Profile with Instruments

4. **Battery**
   - Turn off Vision when not in use
   - Reduce camera FPS (15-30 FPS sufficient)
   - Use low power mode detection

---

## 📋 Checklist: Week 0-1

### Setup (Week 0)
- [ ] Create Xcode project
- [ ] Add CocoaPods dependencies
- [ ] Set up Git repository
- [ ] Create folder structure
- [ ] Add CoreML model to project
- [ ] Create data models

### Camera Screen (Week 1)
- [ ] Implement CameraPreview with AVFoundation
- [ ] Integrate Vision framework
- [ ] Add CoreML model detection
- [ ] Show detection results
- [ ] Handle camera permissions

### Network Integration (Week 1)
- [ ] Implement NetworkService
- [ ] Create API models
- [ ] Add URLSession requests
- [ ] Handle responses
- [ ] Error handling

### UI Polish (Week 1)
- [ ] Home screen design
- [ ] Camera screen layout
- [ ] Results display
- [ ] Loading indicators
- [ ] Error messages

---

## 🔗 Dependencies & Frameworks

### Required (Built-in)
- SwiftUI
- AVFoundation (Camera)
- Vision (Detection)
- CoreML (ML Models)
- URLSession (Networking)

### Optional (Third-party)
- Alamofire (easier networking)
- Kingfisher (image caching)
- Firebase (cloud integration)

---

## 📝 Debugging & Logging

```swift
// Add to AppDelegate for debugging
func setupLogging() {
    #if DEBUG
    let logLevel = Logger.Level.debug
    #else
    let logLevel = Logger.Level.info
    #endif
    
    Logger.setup(level: logLevel)
}

// Usage
import os.log

class Logger {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let camera = os.log(subsystem: subsystem, category: "camera")
    static let network = os.log(subsystem: subsystem, category: "network")
    
    static func logCamera(_ message: String) {
        os_log("%{public}@", log: camera, type: .debug, message)
    }
}
```

---

## 📚 Resources

- [Apple Vision Documentation](https://developer.apple.com/documentation/vision/)
- [CoreML Guide](https://developer.apple.com/documentation/coreml)
- [SwiftUI Guide](https://developer.apple.com/documentation/swiftui)
- [URLSession Guide](https://developer.apple.com/documentation/foundation/urlsession)

---

**Last Updated:** April 1, 2026  
**Version:** 1.0  
**Status:** ✅ Complete
