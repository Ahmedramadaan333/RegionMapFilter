// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RegionMapFilter",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RegionMapFilter",
            targets: ["RegionMapFilter"])
    ],
    dependencies: [
        // Google Maps SDK must be added by users via CocoaPods
    ],
    targets: [
        .target(
            name: "RegionMapFilter",
            dependencies: [],
            path: "Sources/RegionMapFilter",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
