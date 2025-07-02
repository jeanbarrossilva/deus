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
public protocol Particle: _Particle, Opposable {}

/// Non-``Opposable``-conformant protocol of a ``Particle``.
public protocol _Particle {
  /// Intrinsic angular momentum of this type of ``Particle``.
  static var spin: Spin { get }

  /// Character which identifies this type of ``Particle`` as per the International System of Units
  /// (SI).
  static var symbol: String { get }

  /// Force experienced by this type of ``Particle`` in an electromagnetic field.
  var charge: Charge { get }

  /// Performs a partial equality comparison between this ``Particle`` and the given one by testing
  /// all their properties common to such protocol against each other.
  ///
  /// ## Partiality
  ///
  /// This method returning `true` does not necessarily denote that both ``Particle``s are equal;
  /// rather, as the name implies, the existing equality is partial, meaning that properties that
  /// are specific to either `Self` or the type of `other` may differ and, therefore, still
  /// differentiate them from one another.
  ///
  /// Some ``Particle``s might resort to their type-specific equality comparison, falling back to
  /// the partial comparison in case the first deems their structure different (e.g., an `Equatable`
  /// ``Particle`` initially tests `self == other`; if `false`, then the partial comparison is
  /// performed).
  ///
  /// ## Implicit contract with `Equatable` ``Particle``s
  ///
  /// Comparing two ``Particle``s of the same type which conform to the `Equatable` protocol by
  /// calling this method should always return `true` when `self == other`. However, because of the
  /// aforementioned considerations on partiality, `isPartiallyEqual(to: other) && self == other`
  /// may be `false`.
  ///
  /// - Parameter other: ``Particle`` to which this one will be compared.
  /// - Returns: `true` if the properties shared by these ``Particle``-conformant values are equal;
  ///   otherwise, `false`.
  func isPartiallyEqual<Other: _Particle>(to other: Other) -> Bool
}

extension _Particle {
  public func isPartiallyEqual<Other: _Particle>(to other: Other) -> Bool {
    return _isPartiallyEqual(to: other)
  }

  /// The default implementation of ``isPartiallyEqual(to:)``.
  ///
  /// This function is distinct from the internal one in that it allows for overriders which employ
  /// type-specific checks to resort to the default check in case such type-specific checks return
  /// `false`.
  fileprivate func _isPartiallyEqual<Other: _Particle>(to other: Other) -> Bool {
    return Self.spin == Other.spin && Self.symbol == Other.symbol && charge == other.charge
  }
}

extension _Particle where Self: Equatable {
  public func isPartiallyEqual<Other: _Particle>(to other: Other) -> Bool {
    guard let other = other as? Self else { return _isPartiallyEqual(to: other) }
    return self == other || _isPartiallyEqual(to: other)
  }
}

extension Anti: _Particle where Counterpart: _Particle {
  public static var spin: Spin { Counterpart.spin }
  public static var symbol: String { Counterpart.symbol + "̅" }

  public var charge: Charge { -counterpart.charge }
}
