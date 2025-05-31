//
//  Quark.swift
//  Deus
//
//  Created by Jean Barros Silva on 24/05/25.
//

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
public enum Quark: Comparable, Particle {
  public static var spin = Spin.half

  public var charge: Charge {
    switch self {
    case .up, .charm, .top:
      Self.twoThirdsOfE
    case .down, .strange, .bottom:
      Self.negativeOneThirdOfE
    }
  }

  /// Character which identifies this ``Quark`` as per the International System of Units (SI).
  public var symbol: Character {
    switch self {
    case .up:
      "u"
    case .down:
      "d"
    case .strange:
      "s"
    case .charm:
      "c"
    case .bottom:
      "b"
    case .top:
      "t"
    }
  }

  /// ``charge`` of up-type quarks.
  private static let twoThirdsOfE = Charge.elementary(2 / 3)

  /// ``charge`` of down-type quarks.
  private static let negativeOneThirdOfE = Charge.elementary(-1 / 3)

  /// Lightest ``Quark``, with a Lagrangian mass of 2.3 ± 0.7 ± 0.5 MeV/*c*². As per the Standard
  /// Model, cannot decay.
  ///
  /// - SeeAlso: ``Energy/megaelectronvolt(_:)``
  case up

  /// Second lightest ``Quark``, with a Lagrangian mass of 4.8 ± 0.5 ± 0.3 MeV/*c*². Decays to an up
  /// ``Quark``.
  ///
  /// - SeeAlso: ``up``
  /// - SeeAlso: ``Energy/megaelectronvolt(_:)``
  case down

  /// Third lightest ``Quark``, with a Lagrangian mass of 95 ± 5 MeV/*c*². Decays to a down
  /// ``Quark``.
  ///
  /// - SeeAlso: ``down``
  /// - SeeAlso: ``Energy/megaelectronvolt(_:)``
  case strange

  /// Third heaviest ``Quark``, with a Lagrangian mass of 1.275 ± 0.025 GeV/*c*². Decays to a
  /// strange ``Quark``.
  ///
  /// - SeeAlso: ``strange``
  /// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
  case charm

  /// Second heaviest ``Quark``, with a Lagrangian mass of 4.18 ± 30 GeV/*c*². Decays to a charm
  /// ``Quark``.
  ///
  /// - SeeAlso: ``charm``
  /// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
  case bottom

  /// Heaviest ``Quark``, with a Lagrangian mass of 173.21 ± 0.51 ± 0.7 GeV/*c*². Decays to a bottom
  /// ``Quark``.
  ///
  /// - SeeAlso: ``bottom``
  /// - SeeAlso: ``Energy/gigaelectronvolt(_:)``
  case top
}

/// Collection of properties shared by ``Quark``s.
private struct Quarks {
  /// ``Charge`` of an up-type ``Quark``.
  static let positiveTwoThirdsOfE = Charge.elementary(2 / 3)

  /// ``Charge`` of a down-type ``Quark``.
  static let negativeOneThirdOfE = Charge.elementary(-1 / 3)

  private init() {}
}
