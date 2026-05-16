// swift-tools-version: 5.9
/**
 * [INPUT]: Depends on Swift Package Manager and raycast/extensions-swift-tools.
 * [OUTPUT]: Provides the movecursor executable target exported to Raycast TypeScript via Swift plugins.
 * [POS]: swift/movecursor package manifest, defining the native bridge build boundary.
 * [PROTOCOL]: Update this header when changed, then check agents.md
 */

import PackageDescription

let package = Package(
  name: "movecursor",
  platforms: [
    .macOS(.v12),
  ],
  dependencies: [
    .package(url: "https://github.com/raycast/extensions-swift-tools", from: "1.0.4"),
  ],
  targets: [
    .executableTarget(
      name: "movecursor",
      dependencies: [
        .product(name: "RaycastSwiftMacros", package: "extensions-swift-tools"),
        .product(name: "RaycastSwiftPlugin", package: "extensions-swift-tools"),
        .product(name: "RaycastTypeScriptPlugin", package: "extensions-swift-tools"),
      ]
    ),
  ]
)
