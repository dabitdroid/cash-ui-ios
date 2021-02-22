// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CashUI",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CashUI",
            targets: ["CashUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "CashCore", url: "https://github.com/atmcoin/cash-sdk-ios.git", .upToNextMajor(from: "4.0.0")),
        .package(name: "Firebase",
                   url: "https://github.com/firebase/firebase-ios-sdk.git",
                   .branch("7.0-spm-beta")),
        .package(name:"CountryPicker", url: "https://github.com/SURYAKANTSHARMA/CountryPicker.git", .upToNextMajor(from: "1.2.7")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CashUI",
            dependencies: ["CashCore",
            "CountryPicker",
            .product(name: "FirebaseMessaging", package: "Firebase"),
            .product(name: "FirebaseFunctions", package: "Firebase"),
            .product(name: "FirebaseAnalytics", package: "Firebase"),
            ]
        ),
        .testTarget(
            name: "CashUITests",
            dependencies: ["CashUI"]),
    ]
)
