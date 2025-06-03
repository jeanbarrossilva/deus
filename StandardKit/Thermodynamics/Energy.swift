//
//  Mass.swift
//  Deus
//
//  Created by Jean Barros Silva on 25/05/25.
//

/// Frame-dependent amount of work (the interaction of a thermodynamic system with its surroundings)
/// performable by matter.
///
/// As stated by the law of conservation of energy, the energy of an isolated system is neither
/// created nor destroyed. In the universe — an isolated system —, it is a fundamental property, and
/// is forever constant: it can only be transformed from one form into another, or transferred from
/// body A to B.
public enum Energy: Measurement {
  public static var zero = Self.make(value: 0)
  public static var backingUnitSymbol = "MeV"

  public var value: Double {
    switch self {
    case .megaelectronvolt(let value):
      value
    case .gigaelectronvolt(let value):
      value * 1_000
    }
  }

  public var symbol: String {
    switch self {
    case .megaelectronvolt(_):
      Self.backingUnitSymbol
    case .gigaelectronvolt(_):
      "GeV"
    }
  }

  /// Symbolized as MeV, it is one-hundredth of an electronvolt (eV), with eV = 1.602176634 × 10⁻¹⁹
  /// J and J = C × V.
  case megaelectronvolt(Double)

  /// Symbolized as GeV, it is one-millionth of an electronvolt (eV).
  case gigaelectronvolt(Double)

  public static func make(value: Double) -> Energy {
    megaelectronvolt(value)
  }
}
