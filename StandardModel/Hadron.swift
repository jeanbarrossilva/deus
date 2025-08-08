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

/// ``Particle`` composed by two or more ``Quark``s which are bound by strong force. It is the
/// compositor of nucleons — such as protons and neutrons — and, therefore, the most common
/// composite ``Particle`` in the universe.
///
/// ## Classification
///
/// Hadrons are divided into two families:
///
/// Family     | Baryon number        | Composition       |
/// ---------- | -------------------- | ----------------- |
/// ``Meson``  | 0                    | qⁱ ⊗ q̄ⱼ           |
/// Baryon     | +1                   | εⁱʲᵏ qⁱ ⊗ qʲ ⊗ qᵏ |
///
/// > Glossary: • **Baryon number**: ⅓ of the difference between the number of quarks and that of
///               antiquarks. Because of ``Color`` confinement, a phenomenon in which
///               ``ColoredParticle``s are confined, hadrons cannot have a net ``Color`` charge;
///               thus, a hadron being composed of three ``Quark``s of distinct ``Color``s (a
///               baryon) or of a ``Quark`` and an antiquark (a meson) has a ``Color``-neutral
///               state — it is white;\
///             • **q̄**: antiquark, the antiparticle of a ``Quark``.\
///             • **⊗**: tensor product of two vector spaces *V* and *W*: an *m* × *n* matrix, where
///               *m* is the number of components of *V* and *n* is that of *W*.
public protocol Hadron: ColoredParticle<White> {
  /// `Sequence` of ``Quark``s that compose this ``Hadron``.
  associatedtype Quarks: Sequence<any QuarkLike>

  /// ``Quark``s by which this ``Hadron`` is composed, bound by strong force via the gluon
  /// ``Particle``s.
  var quarks: Quarks { get }
}

extension Hadron {
  public var charge: Measurement<UnitElectricCharge> {
    quarks.reduce(.zero) { charge, quark in quark.charge + charge }
  }
  public var color: White { white }
}

// MARK: - Mesons
extension UpQuark {
  /// Combines an down antiquark to this ``UpQuark``.
  ///
  /// - Parameters:
  ///   - lhs: ``UpQuark`` to combine `rhs` to.
  ///   - rhs: Down antiquark to be combined to `lhs`.
  /// - Returns: Result of the u + d̄ combination: a ``PositivePion``.
  static func + (lhs: Self, rhs: Anti<DownQuark<Self.Color>>) -> PositivePion {
    return PositivePion(quarks: [lhs, rhs])
  }
}

/// ``Pion`` with a positive ``charge`` (π⁺), resulted from u + d̄.
///
/// - SeeAlso: ``UpQuark``
/// - SeeAlso: ``DownQuark``
public struct PositivePion: Equatable, Pion {
  public let symbol = "π⁺"
  public let charge = Measurement(value: 1, unit: UnitElectricCharge.elementary)
  public let quarks: InlineArray<2, any QuarkLike>

  fileprivate init(quarks: InlineArray<2, any QuarkLike>) { self.quarks = quarks }
}

/// ``Pion`` with a negative ``charge`` (π⁻), resulted from d + ū.
///
/// - SeeAlso: ``DownQuark``
/// - SeeAlso: ``UpQuark``
public struct NegativePion: Equatable, Pion {
  public let symbol = "π⁻"
  public let charge = Measurement(value: -1, unit: UnitElectricCharge.elementary)
  public let quarks: InlineArray<2, any QuarkLike>

  init(quarks: InlineArray<2, any QuarkLike>) { self.quarks = quarks }
}

extension DownQuark {
  /// Combines an up antiquark to this ``DownQuark``.
  ///
  /// - Parameters:
  ///   - lhs: ``DownQuark`` to combine `rhs` to.
  ///   - rhs: Up antiquark to be combined to `lhs`.
  /// - Returns: Result of the d + ū combination: a ``NegativePion``.
  static func + (lhs: Self, rhs: Anti<UpQuark<Self.Color>>) -> NegativePion {
    NegativePion(quarks: [lhs, rhs])
  }
}

extension Pion where Self: ParticleLike { public var spin: Spin { .zero } }

extension Pion where Self: Equatable, Quarks == InlineArray<2, any QuarkLike> {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.charge == rhs.charge && lhs.color === rhs.color
      && lhs.quarks[0].isPartiallyEqual(to: rhs.quarks[0])
      && lhs.quarks[1].isPartiallyEqual(to: rhs.quarks[1])
  }
}

/// ``Meson`` composed by ``Quark``-antiquark pairs, produced most commonly via high-energy
/// collisions between ``Hadron``s and specific ``Particle``-antiparticle annihilation.
///
/// ## Etimology
///
/// Its name ("π meson", contracted to "pion") was defined by Hideki Yukawa in 1935 and is
/// indicative of its then-theorized role as a carrier ``Particle`` of strong force, inspired by the
/// visual resemblance between "π" and "介", Kanji that means "to mediate".
///
/// Later, in 1962, Murray Gell-Mann theorized that such force was, rather, mediated by gluons,
/// massless ``Particle``s whose ``Spin`` is 1 *ħ* and which are, consequently, categorized as
/// vector bosons.
///
/// ## Stability
///
/// Because of their lightness, the lifetime of pions is extremely short, resulting in them lasting
/// from 85 attoseconds to ~26.033 ns before their decay into muons and neutrinos (π⁺ → μ + v) or
/// into gamma rays. Therefore, they are considered **unstable**.
public protocol Pion: Meson {}

/// ``Hadron`` composed by an even amount of ``Quark``s.
public protocol Meson: Hadron {}
