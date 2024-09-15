// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JcbCapacitorInapp",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "JcbCapacitorInapp",
            targets: ["InAppPurchasePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "InAppPurchasePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/InAppPurchasePlugin"),
        .testTarget(
            name: "InAppPurchasePluginTests",
            dependencies: ["InAppPurchasePlugin"],
            path: "ios/Tests/InAppPurchasePluginTests")
    ]
)