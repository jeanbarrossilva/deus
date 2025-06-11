//
//  Quark.swift
//  Deus
//
//  Created by Jean Barros Silva on 24/05/25.
//

/// A quark (q) is an elementary fermion ``ColoredParticle`` which is confined, bound to at least
/// another one by gluon ``Particle``s via strong force. It is the only ``Particle`` in the Standard
/// Model which experiences each of the four fundamental forces: strong, weak, electromagnetic and
/// gravitational.
///
/// ## Classification
///
/// There are six flavors of quarks, divided into two ``charge``-based types and three generations:
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
/// of being unable to hadronize (form a hadron).
///
/// - SeeAlso: ``Spin/half``
/// - SeeAlso: ``Charge/elementary(_:)``
/// - SeeAlso: ``Energy/megaelectronvolts(_:)``
/// - SeeAlso: ``Energy/gigaelectronvolts(_:)``
public enum Quark: ColoredParticle, Equatable {
  public static var spin = Spin.half

  public var charge: Charge {
    switch self {
    case .up, .charm, .top:
      Self.twoThirdsOfE
    case .down, .strange, .bottom:
      Self.negativeOneThirdOfE
    }
  }

  public var symbol: String {
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

  public var color: Color {
    switch self {
    case .up(let color):
      color
    case .down(let color):
      color
    case .strange(let color):
      color
    case .charm(let color):
      color
    case .bottom(let color):
      color
    case .top(let color):
      color
    }
  }

  /// ``charge`` of up-type quarks.
  private static let twoThirdsOfE = Charge.elementary(2 / 3)

  /// ``Charge`` of down-type quarks.
  private static let negativeOneThirdOfE = Charge.elementary(-1 / 3)

  /// Lightest ``Quark``, with a Lagrangian mass of 2.3 ± 0.7 ± 0.5 MeV/*c*². As per the Standard
  /// Model, cannot decay.
  ///
  /// - SeeAlso: ``Energy/megaelectronvolts(_:)``
  case up(color: Color)

  /// Second lightest ``Quark``, with a Lagrangian mass of 4.8 ± 0.5 ± 0.3 MeV/*c*². Decays to an up
  /// ``Quark``.
  ///
  /// - SeeAlso: ``up(color:)``
  /// - SeeAlso: ``Energy/megaelectronvolts(_:)``
  case down(color: Color)

  /// Third lightest ``Quark``, with a Lagrangian mass of 95 ± 5 MeV/*c*². Decays to a down
  /// ``Quark``.
  ///
  /// - SeeAlso: ``down(color:)``
  /// - SeeAlso: ``Energy/megaelectronvolts(_:)``
  case strange(color: Color)

  /// Third heaviest ``Quark``, with a Lagrangian mass of 1.275 ± 0.025 GeV/*c*². Decays to a
  /// strange ``Quark``.
  ///
  /// - SeeAlso: ``strange(color:)``
  /// - SeeAlso: ``Energy/gigaelectronvolts(_:)``
  case charm(color: Color)

  /// Second heaviest ``Quark``, with a Lagrangian mass of 4.18 ± 30 GeV/*c*². Decays to a charm
  /// ``Quark``.
  ///
  /// - SeeAlso: ``charm(color:)``
  /// - SeeAlso: ``Energy/gigaelectronvolts(_:)``
  case bottom(color: Color)

  /// Heaviest ``Quark``, with a Lagrangian mass of 173.21 ± 0.51 ± 0.7 GeV/*c*². Decays to a bottom
  /// ``Quark``.
  ///
  /// - SeeAlso: ``bottom(color:)``
  /// - SeeAlso: ``Energy/gigaelectronvolts(_:)``
  case top(color: Color)

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.symbol == rhs.symbol && lhs.color == rhs.color
  }
}
