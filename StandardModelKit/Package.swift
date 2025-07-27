// swift-tools-version: 6.2

// ===-------------------------------------------------------------------------------------------===
// Copyright © 2025 Deus
//
// This file is part of the Deus open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "StandardModelKit",
  platforms: [.macOS(.v13)],
  products: [.library(name: "StandardModelKit", targets: ["StandardModelKit"])],
  dependencies: [
    .package(url: "https://github.com/stackotter/swift-macro-toolkit.git", exact: "0.6.1"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "600.0.1")
  ],
  targets: [
    .macro(
      name: "StandardModelKitMacros",
      dependencies: [
        .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ), .target(name: "StandardModelKit", dependencies: ["StandardModelKitMacros"]),
    .testTarget(
      name: "StandardModelKitTests",
      dependencies: [
        "StandardModelKitMacros", .product(name: "MacroToolkit", package: "swift-macro-toolkit"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
      ]
    )
  ]
)
