// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MetaTrackerLib",
  platforms: [
    .iOS(.v14),
    .macOS(.v11),
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "MetaTrackerLib",
      targets: ["MetaTrackerLib"]),
    .library(name: "AppTelemetryClient", targets: ["AppTelemetryClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.18.0"),
    .package(
      name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      from: "1.9.0"),
    .package(
      name: "TelemetryClient", url: "https://github.com/AppTelemetry/SwiftClient", from: "1.0.13"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.1.0"),
  ],
  targets: [
    .target(
      name: "AnalyticsClient",
      dependencies: [
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
      ]),
    .target(
      name: "DatabaseClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(
      name: "APIClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        "Models",
      ]
    ),
    .testTarget(
      name: "APIClientTests",
      dependencies: [
        "APIClient",
        "SnapshotTesting",
      ],
      exclude: [
        "__Snapshots__"
      ]
    ),

    .target(
      name: "AppEnvironment",
      dependencies: [
        "APIClient",
        "AnalyticsClient",
        "DatabaseClient",
        "SearchFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),

    .target(
      name: "AppTelemetryClient",
      dependencies: [
        "AnalyticsClient",
        "TelemetryClient",
        "Secrets",
      ]
    ),

    .target(
      name: "MetaTrackerLib",
      dependencies: [
        "AppEnvironment",
        "APIClient",
        "AnalyticsClient",
        "DatabaseClient",
        "Models",
        "SearchFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "MetaTrackerLibTests",
      dependencies: ["MetaTrackerLib"]),

    // Models
    .target(name: "Models"),

    // SearchFeature
    .target(
      name: "SearchFeature",
      dependencies: [
        "APIClient",
        "DatabaseClient",
        "AnalyticsClient",
      ]
    ),
    .testTarget(name: "SearchFeatureTests", dependencies: ["SearchFeature", "AppEnvironment"]),

    // Secrets
    .target(name: "Secrets", exclude: ["_Secrets.swift"]),
  ]
)
