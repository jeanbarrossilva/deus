//
//  Charge.swift
//  Deus
//
//  Created by Jean Barros Silva on 24/05/25.
//

/// Amount of force experienced by matter in an electromagnetic field.
public enum Charge: Measurement {
  public static var zero = Charge.make(value: 0)
  public static let backingUnitSymbol = "e"

  public var symbol: String {
    switch self {
    case .elementary(_):
      Self.backingUnitSymbol
    }
  }

  public var value: Double {
    switch self {
    case .elementary(let value):
      value
    }
  }

  /// Amount in elementary charge (*e*). *e* is a fundamental constant as per the SI, equating
  /// 1.602176634 × 10⁻¹⁹ C and representing the least amount of ``Charge`` which can exist
  /// unconfined in the universe.
  case elementary(Double)

  public static func make(value: Double) -> Charge {
    .elementary(value)
  }
}
