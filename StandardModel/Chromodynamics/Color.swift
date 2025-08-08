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

import Foundation

// MARK: - Colors

/// Final state of confined ``ColoredParticle``s whose net ``Color`` charge is zero, making them
/// effectively colorless. Results from the combination of ``Color``-anticolor pairs or of all
/// ``SingleColor``s (``red`` + ``green`` + ``blue``).
public let white = White()

/// Red (r) direction in the ``Color`` field.
public let red = Red()

/// Green (g) direction in the ``Color`` field.
public let green = Green()

/// Blue (r) direction in the ``Color`` field.
public let blue = Blue()

/// Delegate of a ``SingleColorLike``-conformant ``Anti`` of ``red``.
private let antired = Antired()

/// Delegate of a ``SingleColorLike``-conformant ``Anti`` of ``green``.
private let antigreen = Antigreen()

/// Delegate of a ``SingleColorLike``-conformant ``Anti`` of ``blue``.
private let antiblue = Antiblue()

/// Final state of confined ``ColoredParticleLike``s whose net ``Color`` charge is zero, making them
/// effectively colorless. Results from the combination of ``Color``-anticolor pairs or of all
/// ``SingleColor``s (``red`` + ``green`` + ``blue``).
public class White: Color { fileprivate init() {} }

/// Red (r) direction in the ``Color`` field.
public class Red: SingleColor { fileprivate init() {} }

/// Green (g) direction in the ``Color`` field.
public class Green: SingleColor { fileprivate init() {} }

/// Blue (b) direction in the ``Color`` field.
public class Blue: SingleColor { fileprivate init() {} }

/// Antired (r̄) direction in the ``Color`` field.
private class Antired: SingleColor { fileprivate init() {} }

/// Antigreen (ḡ) direction in the ``Color`` field.
private class Antigreen: SingleColor { fileprivate init() {} }

/// Antiblue (b̄) direction in the ``Color`` field.
private class Antiblue: SingleColor { fileprivate init() {} }

// MARK: - Type erasure

/// Type-erased ``SingleColorLike``. Might be ``red``, antired, ``green``, antigreen, ``blue`` or
/// antiblue.
public struct AnySingleColorLike: SingleColorLike {
  /// ``SingleColorLike`` whose type has been erased. Casting it to the original type is a safe
  /// operation.
  public let base: any AnyObject & SingleColorLike

  init(_ base: some AnyObject & SingleColorLike) { self.base = base }

  public func `is`(_ other: (some Color).Type) -> Bool { type(of: base) == other }
}

// MARK: - Particle

extension Anti: ColoredParticleLike
where Counterpart: ColoredParticle, Counterpart.Color: SingleColor {
  public var color: Anti<Counterpart.Color> { Anti<Counterpart.Color>(counterpart.color) }
}

/// Direct (in the case of a gluon ``Particle``) or indirect result of a localized excitation of the
/// ``Color`` field.
public protocol ColoredParticle<Color>: ColoredParticleLike, Particle {}

extension ColoredParticle where Self: ParticleLike {
  public func isPartiallyEqual<Other: ParticleLike>(to other: Other) -> Bool {
    guard let other = other as? any ColoredParticle else {
      return _particleLikeIsPartiallyEqual(to: other)
    }
    return _coloredParticleLikeIsPartiallyEqual(to: other)
  }
}

extension ColoredParticleLike {
  /// The default implementation of ``isPartiallyEqual(to:)``.
  ///
  /// - Parameter other: ``ColoredParticleLike`` to which this one will be compared.
  /// - Returns: `true` if the properties shared by these ``ColoredParticleLike`` values are equal;
  ///   otherwise, `false`.
  func _coloredParticleLikeIsPartiallyEqual<Other: ParticleLike>(to other: Other) -> Bool {
    guard let color = color as? AnyClass,
      let otherColor = (other as? any ColoredParticleLike)?.color as? AnyClass
    else { return _particleLikeIsPartiallyEqual(to: other) }
    return color === otherColor && _particleLikeIsPartiallyEqual(to: other)
  }
}

/// Base protocol to which ``ColoredParticle``s and colored antiparticles conform.
public protocol ColoredParticleLike<Color>: ParticleLike {
  /// The specific type of ``Color``.
  associatedtype Color: StandardModel.Color

  /// Measured transformation under the SU(3) symmetry.
  var color: Color { get }
}

// MARK: Color and single-color-like declarations

extension Anti: Color, SingleColorLike where Counterpart: SingleColor {}

/// One direction in the ``Color`` field.
public protocol SingleColor: SingleColorLike, Opposable {}

/// Base protocol to which single ``Color``s and anticolors conform.
public protocol SingleColorLike: Color {}

/// Color charge is a fundamental, confined (unobservable while free) property which determines its
/// transformation under the SU(3) gauge symmetry whose field, SU(3)₍color₎ or gluon field, is
/// quantized as gluons, boson ``Particle``s responsible for binding the ``Quark``s of a ``Hadron``
/// by mediating the strong interactions.
///
/// Each of the three directions of the vector (red, green and blue) are amplitudes when unmeasured;
/// upon measurement, the probability of this charge being in such direction is produced according
/// to the Born rule. Finally, a definite color is determined, resulting in one of the cases of this
/// enum.
///
/// These three directions are intrinsically equal to each other: they can be swapped via an SU(3)
/// transformation and the overall state of the system will not be modified. They affect, however,
/// the interactions to be had with them by the gluons, which carry specific color-anticolor
/// combinations; these can, in turn…
///
/// - …annihilate one direction and redirect;
/// - influence the phase of a direction but not redirect the vector; or
/// - be effectless.
///
/// > Note: None of the two mentioned concepts, color and direction, refer to their classical
/// description (respectively, a visual perception of the electromagnetic spectrum and a projection
/// of physical movement from one point toward another). These are uniquely-quantum properties of a
/// ``ColoredParticle``.
public protocol Color: Equatable {
  /// Returns whether the type of this ``Color`` and the given one match.
  ///
  /// - Parameter other: Type of ``Color`` to compare that of this one with.
  func `is`(_ other: (some Color).Type) -> Bool
}

extension Color { public func `is`(_ other: (some Color).Type) -> Bool { Self.self == other } }

extension Color where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { true }
}
