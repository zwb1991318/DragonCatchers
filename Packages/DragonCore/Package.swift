// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DragonCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DragonCore", targets: ["DragonCore"]),
    ],
    targets: [
        .target(name: "DragonCore"),
        .testTarget(name: "DragonCoreTests", dependencies: ["DragonCore"]),
    ]
)
