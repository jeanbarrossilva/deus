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
