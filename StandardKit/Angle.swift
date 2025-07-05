//
//  Angle.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

/// Curvature of an arc between two vectors with a common origin or endpoint.
public enum Angle: Measurement {
  public static let zero = Self.make(value: 0)
  public static let backingUnitSymbol = "rad"

  public var value: Double {
    switch self {
    case .radians(let value):
      value
    }
  }

  public var symbol: String {
    switch self {
    case .radians(_):
      Self.backingUnitSymbol
    }
  }

  /// Ratio of the length of the arc to its radius (180º ÷ π).
  case radians(Double)

  public static func make(value: Double) -> Angle {
    .radians(value)
  }
}
