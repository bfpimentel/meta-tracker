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
  ],
  targets: [
    .target(name: "AnalyticsClient"),
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
      name: "AppTelemetryClient",
      dependencies: [
        "AnalyticsClient",
        "TelemetryClient",
      ]
    ),

    .target(
      name: "MetaTrackerLib",
      dependencies: [
        "APIClient",
        "AnalyticsClient",
        "DatabaseClient",
        "Models",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "MetaTrackerLibTests",
      dependencies: ["MetaTrackerLib"]),

    // Models
    .target(name: "Models"),
  ]
)
