//
//  Spin.swift
//  Deus
//
//  Created by Jean Barros Silva on 26/05/25.
//

/// Intrinsic angular momentum of a ``Particle`` that denotes the amount of symmetric faces it has
/// in a turn of 360º. Due to the scale at which they are presented, spins are not equivalent to
/// rotations in the classical sense; they are considered, therefore, a fundamentally-quantum
/// property.
///
/// It is measured in discrete multiples of the reduced Planck constant (*ħ*), expressible by *ħ*ℚ =
/// {n × *ħ* | n ∈ ℚ}, with *ħ* = *h* / (2 × π), where *h* is the Planck constant (equal to
/// 6.62607015 × 10⁻³⁴ J/s) which poses as a separator between the classical scale — in which
/// ``Energy`` and momentum vary continuosly — and the quantum one — in which they are quantized or
/// discrete.
public enum Spin {
  /// ½ *ħ* ``Spin``. The fermion returns to its initial configuration after completing two turns
  /// (720º).
  case half
}
