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
      targets: ["MetaTrackerLib"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.18.0")
  ],
  targets: [
    .target(name: "DatabaseClient"),
    .target(name: "APIClient"),

    .target(
      name: "MetaTrackerLib",
      dependencies: [
        "APIClient",
        "DatabaseClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "MetaTrackerLibTests",
      dependencies: ["MetaTrackerLib"]),

  ]
)
