//
//  Quark.swift
//  Deus
//
//  Created by Jean Barros Silva on 24/05/25.
//

/// Heaviest ``Quark``, with a Lagrangian mass of 173.21 ± 0.51 ± 0.7 GeV/*c*². Decays to a bottom
/// ``Quark``.
///
/// - SeeAlso: ``bottom``
/// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
struct TopQuark: Quark {
  static var charge = Quarks.positiveTwoThirdsOfE
  static var symbol: Character = "t"

  static func < (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
      && type(of: rhs).symbol != BottomQuark.symbol
      && type(of: rhs).symbol != CharmQuark.symbol
      && type(of: rhs).symbol != StrangeQuark.symbol
      && type(of: rhs).symbol != DownQuark.symbol
      && type(of: rhs).symbol != UpQuark.symbol
  }

  static func > (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
      && type(of: rhs).symbol == BottomQuark.symbol
      || type(of: rhs).symbol == CharmQuark.symbol
      || type(of: rhs).symbol == StrangeQuark.symbol
      || type(of: rhs).symbol == DownQuark.symbol
      || type(of: rhs).symbol == UpQuark.symbol
  }
}

/// Second heaviest ``Quark``, with a Lagrangian mass of 4.18 ± 30 GeV/*c*². Decays to a charm
/// ``Quark``.
///
/// - SeeAlso: ``charm``
/// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
struct BottomQuark: Quark {
  static var charge = Quarks.negativeOneThirdOfE
  static var symbol: Character = "b"

  static func < (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
      && type(of: rhs).symbol != CharmQuark.symbol
      && type(of: rhs).symbol != StrangeQuark.symbol
      && type(of: rhs).symbol != DownQuark.symbol
      && type(of: rhs).symbol != UpQuark.symbol
  }

  static func > (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
      && type(of: rhs).symbol == CharmQuark.symbol
      || type(of: rhs).symbol == StrangeQuark.symbol
      || type(of: rhs).symbol == DownQuark.symbol
      || type(of: rhs).symbol == UpQuark.symbol
  }
}

/// Third heaviest ``Quark``, with a Lagrangian mass of 1.275 ± 0.025 GeV/*c*². Decays to a strange
/// ``Quark``.
///
/// - SeeAlso: ``strange``
/// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
struct CharmQuark: Quark {
  static var charge = Quarks.positiveTwoThirdsOfE
  static var symbol: Character = "c"

  static func < (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
      && type(of: rhs).symbol != StrangeQuark.symbol
      && type(of: rhs).symbol != DownQuark.symbol
      && type(of: rhs).symbol != UpQuark.symbol
  }

  static func > (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
      && type(of: rhs).symbol == StrangeQuark.symbol
      || type(of: rhs).symbol == DownQuark.symbol
      || type(of: rhs).symbol == UpQuark.symbol
  }
}

/// Third lightest ``Quark``, with a Lagrangian mass of 95 ± 5 MeV/*c*². Decays to a down ``Quark``.
///
/// - SeeAlso: ``down``
/// - SeeAlso: ``Energy/megaelectronvolt(_:)``
struct StrangeQuark: Quark {
  static var charge = Quarks.negativeOneThirdOfE
  static var symbol: Character = "s"

  static func < (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs && type(of: rhs).symbol != DownQuark.symbol && type(of: rhs).symbol != UpQuark.symbol
  }

  static func > (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs && type(of: rhs).symbol == DownQuark.symbol || type(of: rhs).symbol == UpQuark.symbol
  }
}

/// Second lightest ``Quark``, with a Lagrangian mass of 4.8 ± 0.5 ± 0.3 MeV/*c*². Decays to an up
/// ``Quark``.
///
/// - SeeAlso: ``up``
/// - SeeAlso: ``Energy/megaelectronvolt(_:)``
struct DownQuark: Quark {
  static let charge = Quarks.negativeOneThirdOfE
  static let symbol: Character = "d"

  static func < (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs && type(of: rhs).symbol != UpQuark.symbol
  }

  static func > (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs && type(of: rhs).symbol == UpQuark.symbol
  }
}

/// Lightest ``Quark``, with a Lagrangian mass of 2.3 ± 0.7 ± 0.5 MeV/*c*². As per the Standard
/// Model, cannot decay.
///
/// - SeeAlso: ``Energy/megaelectronvolt(_:)``
struct UpQuark: Quark {
  static let charge = Quarks.positiveTwoThirdsOfE
  static let symbol: Character = "u"

  static func < (lhs: Self, rhs: any Quark) -> Bool {
    lhs > rhs
  }

  static func > (lhs: Self, rhs: any Quark) -> Bool {
    lhs != rhs
  }
}

/// A quark (q) is an elementary fermion ``Particle`` which is confined — cannot exist by itself in
/// nature — and bound to at least another one by gluons via strong force. It is the only
/// ``Particle`` in the Standard Model which experiences each of the four fundamental forces:
/// strong, weak, electromagnetic and gravitational.
///
/// ## Classification
///
/// There are six flavors of quarks, divided into two ``Particle/charge``-based types and three
/// generations:
///
/// Flavor   | Generation | Spin   | Charge | Type    | Lagrangian mass               |
/// -------- | ---------- | ------ | ------ | ------- | ----------------------------- |
/// Up       | 1ˢᵗ        | ½ *ħ*  | +⅔ e   | Up      | 2.3 ± 0.7 ± 0.5 MeV/*c*²      |
/// Down     | 1ˢᵗ        | ½ *ħ*  | -⅓ e   | Down    | 4.8 ± 0.5 ± 0.3 MeV/*c*²      |
/// Strange  | 2ⁿᵈ        | ½ *ħ*  | -⅓ e   | Down    | 95 ± 5 MeV/*c*²               |
/// Charm    | 2ⁿᵈ        | ½ *ħ*  | +⅔ e   | Up      | 1.275 ± 0.025 GeV/*c*²        |
/// Bottom   | 3ʳᵈ        | ½ *ħ*  | -⅓ e   | Down    | 4.18 ± 30 GeV/*c*²            |
/// Top      | 3ʳᵈ        | ½ *ħ*  | +⅔ e   | Up      | 173.21 ± 0.51 ± 0.7 GeV/*c*²  |
///
/// > Note: The names up, down, strange, charm, bottom and top have no intrinsic meaning nor do they
/// describe the behavior of such quarks; they were chosen arbitrarily, with the sole purpose of
/// differentiating each flavor or type.
///
/// ## Role in matter composition
///
/// Ordinary matter, such as nucleons and, therefore, atoms, is composed by 1ˢᵗ-generation quarks
/// due to their stability: they have a decay width Γ ≈ 0 and, consequently, a lifetime τ ≈ ∞,
/// because them being the lightest ones prohibits their decay to lighter — unknown or nonexistent —
/// ``Particle``s. Scenarios beyond the Standard Model in which they do decay are those of Grand
/// Unification Theories, which theorize that the aforementioned four fundamental forces were one in
/// the very early universe (first picosecond of its existence) and, as described by the theory of
/// proton decay by Andrei Sakharov, such quarks have τ ≈ 10³⁴ years; nonetheless, they are
/// disconsidered here.
///
/// As for 2ⁿᵈ- and 3ʳᵈ-generation quarks, their masses, ~20 to ~300 times greater than that of the
/// heaviest 1ˢᵗ-generation quark, alongside their ability to emit a W⁺ or W⁻ via weak interaction
/// and, subsequently, decay to lighter quarks, make them unstable and result in lifetimes ⪅ 173 GeV
/// (5 × 10⁻²⁵ s); these are, therefore, mostly present in cosmic rays and other high-energy
/// collisions. Of the four, the top quark is the only one which is heavy and decays fast enough to
/// the extent of being unable to hadronize (form a hadron).
///
/// - SeeAlso: ``Spin/half``
/// - SeeAlso: ``Charge/elementary(_:)``
/// - SeeAlso: ``Energy/megaelectronvolt(_:)``
/// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
public protocol Quark: Particle {
  /// Determines whether this ``Quark`` is less than another one in terms of mass.
  ///
  /// - Parameters:
  ///   - lhs: ``Quark`` to be compared with `rhs`.
  ///   - rhs: ``Quark`` to be compared with `lhs`.
  /// - Returns: `true` if the mass of `lhs` is less than that of `rhs`; otherwise, `false`.
  static func < (lhs: Self, rhs: any Quark) -> Bool

  /// Determines whether this ``Quark`` is greater than another one in terms of mass.
  ///
  /// - Parameters:
  ///   - lhs: ``Quark`` to be compared with `rhs`.
  ///   - rhs: ``Quark`` to be compared with `lhs`.
  /// - Returns: `true` if the mass of `lhs` is greater than that of `rhs`; otherwise, `false`.
  static func > (lhs: Self, rhs: any Quark) -> Bool
}

extension Quark {
  /// Determines whether this ``Quark`` differs from another one in terms of mass.
  ///
  /// - Parameters:
  ///   - lhs: ``Quark`` to be compared with `rhs`.
  ///   - rhs: ``Quark`` to be compared with `lhs`.
  /// - Returns: `true` if the mass of `lhs` differs from that of `rhs`; otherwise, `false`.
  public static func != (lhs: Self, rhs: any Quark) -> Bool {
    !(lhs == rhs)
  }

  /// Determines whether this ``Quark`` is equal to another one in terms of mass.
  ///
  /// - Parameters:
  ///   - lhs: ``Quark`` to be compared with `rhs`.
  ///   - rhs: ``Quark`` to be compared with `lhs`.
  /// - Returns: `true` if the mass of `lhs` equals to that of `rhs`; otherwise, `false`.
  public static func == (lhs: Self, rhs: any Quark) -> Bool {
    type(of: lhs).symbol == type(of: rhs).symbol
  }
}

extension Quark where Self: Particle {
  public static var spin: Spin { .half }
}

/// Collection of properties shared by ``Quark``s.
private struct Quarks {
  /// ``Charge`` of an up-type ``Quark``.
  static let positiveTwoThirdsOfE = Charge.elementary(2 / 3)

  /// ``Charge`` of a down-type ``Quark``.
  static let negativeOneThirdOfE = Charge.elementary(-1 / 3)

  private init() {}
}
