//
//  Particle.swift
//  Deus
//
//  Created by Jean Barros Silva on 30/05/25.
//

/// Subatomic excitation of an underlying field, which exhibits discrete interactions with other
/// fields. Differs from vacuum fluctuations or delocalized modes on such field in that it is
/// localized: it has a wavepacket of location. Such localization is made possible by
/// collapse-like, interpretation-defined consequence of measuring its wavefunction Ψ(*x*, *t*),
/// where *x* is the position and *t* is the time.
///
/// ## Classification
///
/// Particles are divided into two families:
///
/// Family    | Spin              | Characterization                                                                                                                        |
/// --------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
/// Boson     | s ∈ ℤ × *ħ*       | **Bose–Einstein distribution**: there can be an integer multiple of *nQ* number of particles in a concentration per unit of its volume. |
/// Fermion   | s ∈ (ℤ + ½) × *ħ* | **Pauli exclusion**: identical particles of such family cannot have equal quantum states in the same spacetime.                         |
///
/// - SeeAlso: ``Spin``
public protocol Particle: _Particle, Equatable, Opposable {}

extension Anti: _Particle where Counterpart: _Particle {
  public static var spin: Spin { Counterpart.spin }

  public var charge: Charge { -counterpart.charge }
  public var symbol: String { counterpart.symbol + "̅" }
}

/// Non-``Opposable``-conformant protocol of a ``Particle``.
///
/// > Warning: This should not be referenced by external consumers.
public protocol _Particle {
  /// Intrinsic angular momentum of this type of ``Particle``.
  static var spin: Spin { get }

  /// Force experienced by this type of ``Particle`` in an electromagnetic field.
  var charge: Charge { get }

  /// Character which identifies this type of ``Particle`` as per the International System of Units
  /// (SI).
  var symbol: String { get }
}
