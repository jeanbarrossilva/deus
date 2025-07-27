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

import Foundation

public enum QuarkType: CaseIterable, Sendable {
  public static let allCases = [up(UpTypeQuarkFlavor.allCases), down(DownTypeQuarkFlavor.allCases)]

  case up(_ flavors: [UpTypeQuarkFlavor])
  case down(_ flavors: [DownTypeQuarkFlavor])
}

public enum UpTypeQuarkFlavor: CaseIterable, QuarkFlavor {
  case up
  case charm
  case top
}

public enum DownTypeQuarkFlavor: CaseIterable, QuarkFlavor {
  case down
  case strange
  case bottom
}

extension QuarkFlavor where Self: CustomStringConvertible {
  var description: String { "\(self)".capitalized(with: .current) + "Quark" }
}

protocol QuarkFlavor: Sendable {}

public enum Color: CaseIterable {
  case red
  case green
  case blue
}

/// Generates Swift Testing test cases for each specified quark, colored with the given colors,
/// ensuring that an expected behavior occurs for every desired combination of quarks and colors,
/// delegating the work of producing such boilerplate to the compiler.
///
/// ## Dependencies
///
/// Expanding this macro requires that `StandardModel` and `Testing` be imported.
///
/// ## Examples
///
/// Further documentation is examplified based on the invocation
///
/// ```swift
/// @DiscreteQuarkTester(
///   derivingNameFrom: "quarkIsAParticle",
///   ofTypes: [.up([.charm, .top])],
///   colored: [.green, .blue],
///   as: "#expect($quark is Particle)"
/// )
/// ```
///
/// of this macro.
///
/// ## Naming
///
/// The name of the tests is derived from the base one, which is, then, specialized based on the
/// quark being tested and the color with which it is colored. Such base name is **required** to
/// contain the word "quark" (case-insensitively) once — and only once.
///
/// ```swift
/// @Test
/// func greenCharmQuarkIsAParticle() { … }
///
/// @Test
/// func blueCharmQuarkIsAParticle() { … }
///
/// @Test
/// func greenTopQuarkIsAParticle() { … }
///
/// @Test
/// func blueTopQuarkIsAParticle() { … }
/// ```
///
/// - Parameters:
///   - baseName: Name from which that of the tests will derive from. Required to contain the word
///     "quark" once, which will then be specialized based on the flavor and the color with which it
///     is colored in the test case.
///   - types: Types and flavors of quarks to be tested.
///   - colors: Colors with which each of the quarks is colored.
///   - body: Code inserted in the body of the test case, from which the non-type-erased quark being
///     tested and its color are accessible, respectively, via the `$quark` and `$color`
///     placeholders.
@attached(member, names: arbitrary)
public macro DiscreteQuarkTester(
  derivingNameFrom baseName: String,
  ofTypes types: [QuarkType] = QuarkType.allCases,
  colored colors: [Color] = Color.allCases,
  as body: String
) = #externalMacro(module: "StandardModelKitMacros", type: "DiscreteQuarkTesterMacro")
