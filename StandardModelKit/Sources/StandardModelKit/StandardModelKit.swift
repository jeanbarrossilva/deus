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

// ===-------------------------------------------------------------------------------------------===
// Written entirely or modified partially by Anthropic Claude Sonnet 4.
// ===-------------------------------------------------------------------------------------------===

/// Represents quark types that can be tested by the `DiscreteQuarkTester` macro.
///
/// This enumeration allows specification of which quark types and flavors should be
/// included in macro-generated test cases. Each case contains an array of flavors
/// for that quark type.
///
/// ## Usage with DiscreteQuarkTester
///
/// When using the `@DiscreteQuarkTester` macro, specify quark types in the `ofTypes` parameter:
///
/// ```swift
/// @DiscreteQuarkTester(
///   derivingNameFrom: "quarkIsAParticle",
///   ofTypes: [.up([.charm, .top]), .down([.strange, .bottom])],
///   colored: [.red, .green],
///   as: "#expect($quark is Particle)"
/// )
/// ```
public enum QuarkType: CaseIterable, Sendable {
  /// All possible quark type configurations with their respective flavors.
  ///
  /// Contains up-type quarks with all up-type flavors and down-type quarks
  /// with all down-type flavors.
  public static let allCases = [up(UpTypeQuarkFlavor.allCases), down(DownTypeQuarkFlavor.allCases)]

  /// Up-type quarks with specified flavors for testing.
  ///
  /// - Parameter flavors: Array of up-type quark flavors to include in generated tests
  case up(_ flavors: [UpTypeQuarkFlavor])

  /// Down-type quarks with specified flavors for testing.
  ///
  /// - Parameter flavors: Array of down-type quark flavors to include in generated tests
  case down(_ flavors: [DownTypeQuarkFlavor])
}

/// Up-type quark flavors available for macro testing.
///
/// This enumeration represents the three up-type quark flavors that can be
/// specified when configuring the `DiscreteQuarkTester` macro.
public enum UpTypeQuarkFlavor: CaseIterable, QuarkFlavor {
  /// The up quark flavor.
  case up

  /// The charm quark flavor.
  case charm

  /// The top quark flavor.
  case top
}

/// Down-type quark flavors available for macro testing.
///
/// This enumeration represents the three down-type quark flavors that can be
/// specified when configuring the `DiscreteQuarkTester` macro.
public enum DownTypeQuarkFlavor: CaseIterable, QuarkFlavor {
  /// The down quark flavor.
  case down

  /// The strange quark flavor.
  case strange

  /// The bottom quark flavor.
  case bottom
}

/// Common interface for all quark flavor types.
///
/// This protocol ensures quark flavors conform to `Sendable` for safe concurrent access
/// and serves as a type constraint for generic operations on quark flavors.
protocol QuarkFlavor: Sendable {}

/// Color charges available for quark testing with the `DiscreteQuarkTester` macro.
///
/// This enumeration specifies which color charges should be applied to quarks
/// in generated test cases.
///
/// ## Usage with DiscreteQuarkTester
///
/// Specify colors in the macro's `colored` parameter:
///
/// ```swift
/// @DiscreteQuarkTester(
///   // ... other parameters ...
///   colored: [.red, .green, .blue],
///   // ... other parameters ...
/// )
/// ```
public enum Color: CaseIterable, Sendable {
  /// Red color charge for quark testing.
  case red

  /// Green color charge for quark testing.
  case green

  /// Blue color charge for quark testing.
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
///   withBody: "#expect($quark is Particle)"
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
///     tested and its color are accessible, respectively, via the predeclared `quark` and `color`
///     local variables.
@attached(member, names: arbitrary)
public macro DiscreteQuarkTester(
  derivingNameFrom baseName: String,
  ofTypes types: [QuarkType],
  colored colors: [Color],
  as body: String
) = #externalMacro(module: "StandardModelKitMacros", type: "DiscreteQuarkTesterMacro")
