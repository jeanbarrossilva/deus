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
    case .megaelectronvolts(let value):
      value
    case .gigaelectronvolts(let value):
      value * 1_000
    }
  }

  public var symbol: String {
    switch self {
    case .megaelectronvolts(_):
      Self.backingUnitSymbol
    case .gigaelectronvolts(_):
      "GeV"
    }
  }

  /// Symbolized as MeV, it is one-hundredth of an electronvolt (eV), with eV = 1.602176634 × 10⁻¹⁹
  /// J and J = C × V.
  case megaelectronvolts(Double)

  /// Symbolized as GeV, it is one-millionth of an electronvolt (eV).
  case gigaelectronvolts(Double)

  public static func make(value: Double) -> Energy {
    megaelectronvolts(value)
  }
}
