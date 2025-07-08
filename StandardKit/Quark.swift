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

/// Charge of up-type quarks.
private let twoThirdsOfE = Measurement(value: 2 / 3, unit: UnitElectricCharge.elementary)

/// Charge of down-type quarks.
private let negativeOneThirdOfE = Measurement(value: -1 / 3, unit: UnitElectricCharge.elementary)

/// Lightest ``Quark``, with a Lagrangian mass of 2.3 ± 0.7 ± 0.5 MeV/*c*². As per the Standard
/// Model, cannot decay.
public struct UpQuark<Color: SingleColor>: Quark {
  public static var symbol: String { "u" }

  public let charge = twoThirdsOfE

  public let color: Color

  public init(color: Color) { self.color = color }
}

/// Second lightest ``Quark``, with a Lagrangian mass of 4.8 ± 0.5 ± 0.3 MeV/*c*². Decays to an
/// ``UpQuark``.
public struct DownQuark<Color: SingleColor>: Quark {
  public static var symbol: String { "d" }

  public let charge = negativeOneThirdOfE

  public let color: Color

  public init(color: Color) { self.color = color }
}

/// Third lightest ``Quark``, with a Lagrangian mass of 95 ± 5 MeV/*c*². Decays to a ``DownQuark``.
public struct StrangeQuark<Color: SingleColor>: Quark {
  public static var symbol: String { "s" }

  public let charge = negativeOneThirdOfE

  public let color: Color

  public init(color: Color) { self.color = color }
}

/// Third heaviest ``Quark``, with a Lagrangian mass of 1.275 ± 0.025 GeV/*c*². Decays to a
/// ``StrangeQuark``.
public struct CharmQuark<Color: SingleColor>: Quark {
  public static var symbol: String { "c" }

  public let charge = twoThirdsOfE

  public let color: Color

  public init(color: Color) { self.color = color }
}

/// Second heaviest ``Quark``, with a Lagrangian mass of 4.18 ± 30 GeV/*c*². Decays to a
/// ``CharmQuark``.
public struct BottomQuark<Color: SingleColor>: Quark {
  public static var symbol: String { "b" }

  public let charge = negativeOneThirdOfE

  public let color: Color

  public init(color: Color) { self.color = color }
}

/// Heaviest ``Quark``, with a Lagrangian mass of 173.21 ± 0.51 ± 0.7 GeV/*c*². Decays to a
/// ``BottomQuark``.
struct TopQuark<Color: SingleColor>: Quark {
  public static var symbol: String { "t" }

  public let charge = twoThirdsOfE

  public let color: Color

  public init(color: Color) { self.color = color }
}

extension Anti: QuarkLike where Counterpart: Quark, Counterpart.Color: SingleColor {
  public typealias Color = Anti<Counterpart.Color>
}

/// A quark (q) is an elementary fermion ``ColoredParticle`` which is confined, bound to at least
/// another one by gluon ``Particle``s via strong force. It is the only ``Particle`` in the Standard
/// Model which experiences each of the four fundamental forces: strong, weak, electromagnetic and
/// gravitational.
///
/// ## Classification
///
/// There are six flavors of quarks, divided into two charge-based types and three generations:
///
/// Flavor      | Generation | Spin   | Charge | Type    | Lagrangian mass               |
/// ----------- | ---------- | ------ | ------ | ------- | ----------------------------- |
/// Up (u)      | 1ˢᵗ        | ½ *ħ*  | +⅔ e   | Up      | 2.3 ± 0.7 ± 0.5 MeV/*c*²      |
/// Down (d)    | 1ˢᵗ        | ½ *ħ*  | -⅓ e   | Down    | 4.8 ± 0.5 ± 0.3 MeV/*c*²      |
/// Strange (s) | 2ⁿᵈ        | ½ *ħ*  | -⅓ e   | Down    | 95 ± 5 MeV/*c*²               |
/// Charm (c)   | 2ⁿᵈ        | ½ *ħ*  | +⅔ e   | Up      | 1.275 ± 0.025 GeV/*c*²        |
/// Bottom (b)  | 3ʳᵈ        | ½ *ħ*  | -⅓ e   | Down    | 4.18 ± 30 GeV/*c*²            |
/// Top (t)     | 3ʳᵈ        | ½ *ħ*  | +⅔ e   | Up      | 173.21 ± 0.51 ± 0.7 GeV/*c*²  |
///
/// > Note: The names up, down, strange, charm, bottom and top have no intrinsic meaning nor do they
/// describe the behavior of such quarks; they were chosen arbitrarily, with the sole purpose of
/// differentiating each flavor or type.
///
/// ## Role in matter composition
///
/// Ordinary matter, such as nucleons and, therefore, atoms, is composed by 1ˢᵗ-generation quarks
/// due to their stability: they have a decay width Γ ≈ 0 and, consequently, a lifetime τ ≈ ∞,
/// because them being the lightest ones either diminishes the chances of (d) or prohibits (u) their
/// decay to lighter — unknown or nonexistent — ``Particle``s of the ``Color`` field. Scenarios
/// beyond the Standard Model in which up quarks decay are those of Grand Unification Theories,
/// which theorize that the aforementioned four fundamental forces were one in the very early
/// universe (first picosecond of its existence) and, as described by the theory of proton decay by
/// Andrei Sakharov, such quarks have τ ≈ 10³⁴ years; nonetheless, they are disconsidered here.
///
/// As for 2ⁿᵈ- and 3ʳᵈ-generation quarks, their masses, ~20 to ~300 times greater than that of the
/// heaviest 1ˢᵗ-generation quark, alongside their ability to emit a W⁺ or W⁻ via weak interaction
/// and, subsequently, decay to lighter quarks, make them unstable and result in τ ⪅ 173 GeV (5 ×
/// 10⁻²⁵ s); these are, therefore, mostly present in cosmic rays and other high-energy collisions.
/// Of the four, the top quark is the only one which is heavy and decays fast enough to the extent
/// of being unable to hadronize (form a ``Hadron``).
///
/// - SeeAlso: ``ParticleLike/charge``
/// - SeeAlso: ``Spin/half``
public protocol Quark: QuarkLike, ColoredParticle where Color: SingleColorLike {}

extension QuarkLike where Self: ParticleLike { public static var spin: Spin { .half } }

/// Base protocol to which ``Quark``s and antiquarks conform.
public protocol QuarkLike: ColoredParticleLike where Color: SingleColorLike {}
