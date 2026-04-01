#!/bin/bash

# GLIMPSE iOS Project Setup Script
# Creates complete iOS project structure and basic files

set -e

PROJECT_NAME="Glimpse"
PROJECT_DIR="${PROJECT_NAME}"

echo "═══════════════════════════════════════════════════════════"
echo "🚀 GLIMPSE iOS Project Setup"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create project directory
if [ -d "$PROJECT_DIR" ]; then
    echo "❌ Directory '$PROJECT_DIR' already exists"
    exit 1
fi

echo "📁 Creating project directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR/Glimpse/Sources"
mkdir -p "$PROJECT_DIR/Tests"
mkdir -p "$PROJECT_DIR/Glimpse/Resources"

cd "$PROJECT_DIR"

echo "📝 Creating Swift Package manifest..."
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Glimpse",
    products: [
        .app(name: "Glimpse", targets: ["Glimpse"]),
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .executableTarget(
            name: "Glimpse",
            dependencies: [],
            path: "Glimpse/Sources"
        ),
        .testTarget(
            name: "GlimpseTests",
            dependencies: ["Glimpse"],
            path: "Tests"
        ),
    ]
)
EOF

echo "✅ Created Package.swift"

# Create folder structure
echo "📁 Creating folder structure..."

mkdir -p Glimpse/Sources/App
mkdir -p Glimpse/Sources/Views
mkdir -p Glimpse/Sources/ViewModels
mkdir -p Glimpse/Sources/Models
mkdir -p Glimpse/Sources/Services
mkdir -p Glimpse/Sources/Utilities
mkdir -p Glimpse/Sources/Components
mkdir -p Glimpse/Resources

# Create main app entry point
cat > Glimpse/Sources/App/GlimpseApp.swift << 'EOF'
import SwiftUI

@main
struct GlimpseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF

echo "✅ Created GlimpseApp.swift"

# Create ContentView
cat > Glimpse/Sources/Views/ContentView.swift << 'EOF'
import SwiftUI

struct ContentView: View {
    @State private var showCamera = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(#colorLiteral(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)),
                    Color(#colorLiteral(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
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
                
                Button(action: { showCamera = true }) {
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
        .sheet(isPresented: $showCamera) {
            // Camera view will go here
            Text("Camera View - To be implemented")
        }
    }
}

#Preview {
    ContentView()
}
EOF

echo "✅ Created ContentView.swift"

# Create Models
cat > Glimpse/Sources/Models/PriceResult.swift << 'EOF'
import Foundation

struct PriceResult: Codable {
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
EOF

echo "✅ Created PriceResult.swift"

# Create ViewModel
cat > Glimpse/Sources/ViewModels/CameraViewModel.swift << 'EOF'
import Foundation
import SwiftUI

@MainActor
class CameraViewModel: ObservableObject {
    @Published var isDetecting = false
    @Published var detectedProduct: String?
    @Published var confidence: Float = 0.0
    @Published var prices: PriceResult?
    @Published var error: String?
    @Published var isLoading = false
    
    func processFrame() {
        // To be implemented
    }
}
EOF

echo "✅ Created CameraViewModel.swift"

# Create Podfile
cat > Podfile << 'EOF'
platform :ios, '16.0'

target 'Glimpse' do
  # HTTP Client
  pod 'Alamofire', '~> 5.0'
  
  # Testing
  pod 'Quick'
  pod 'Nimble'
  
  target 'GlimpseTests' do
    inherit! :search_paths
  end
end
EOF

echo "✅ Created Podfile"

# Create .gitignore
cat > .gitignore << 'EOF'
# Xcode
build/
DerivedData/
*.pbxuser
*.xcworkspace/xcuserdata/
*.xcworkspace/
*.xcodeproj/
.DS_Store

# Swift Package Manager
.build/
.swiftpm/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv

# Environment variables
.env
.env.local

# IDE
.vscode/
.idea/

# Logs
*.log

# Firebase
google-services.json
ServiceAccountKey.json
EOF

echo "✅ Created .gitignore"

# Create README
cat > README.md << 'EOF'
# 🍎 GLIMPSE iOS App

Real-time price comparison via AR camera.

## Setup

### Prerequisites
- macOS 13+
- Xcode 15+
- Swift 5.9+
- iOS 16+

### Installation

```bash
# Install dependencies
pod install

# Open workspace
open Glimpse.xcworkspace

# Run
⌘R (or click Run)
```

## Project Structure

```
Glimpse/Sources/
├── App/          - App entry point
├── Views/        - SwiftUI screens
├── ViewModels/   - State management
├── Models/       - Data models
├── Services/     - Networking, Vision
└── Utilities/    - Helpers
```

## Development

See `docs/iOS_DEVELOPMENT.md` for detailed guide.
EOF

echo "✅ Created README.md"

# Git initialization
echo ""
echo "🔧 Initializing Git repository..."
git init
git add .
git commit -m "Initial commit: GLIMPSE iOS project structure"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ GLIMPSE iOS Project Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📁 Project created at: $(pwd)"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. pod install"
echo "  3. open Glimpse.xcworkspace"
echo "  4. Start building! 🚀"
echo ""
