//
//  Color.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

/// Color charge is a fundamental, confined (unobservable while free) property which determines its
/// transformation under the SU(3) gauge symmetry whose field, SU(3)₍color₎ or gluon field, is
/// quantized as gluons, boson ``Particle``s responsible for binding the ``Quark``s of a hadron by
/// mediating the strong interactions.
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
public indirect enum Color: CaseIterable, Equatable, Opposable {
  public static var allCases = [red, green, blue]

  /// Red (r) direction in the SU(3)₍color₎ field.
  case red

  /// Green (g) direction in the SU(3)₍color₎ field.
  case green

  /// Blue (b) direction in the SU(3)₍color₎ field.
  case blue

  /// Counterpart of a ``Color``: antired, antigreen or antiblue.
  case anti(Color)
}

/// Direct (in the case of a gluon ``Particle``) or indirect result of a localized excitation of the
/// ``Color`` field.
public protocol ColoredParticle: _ColoredParticle, Particle {}

extension Anti: _ColoredParticle where Counterpart: _ColoredParticle {
  public var color: Color { .anti(counterpart.color) }
}

/// Non-``Opposable``-conformant protocol of a ``ColoredParticle``.
///
/// > Warning: This should not be referenced by external consumers.
public protocol _ColoredParticle {
  /// Measured transformation under the SU(3) symmetry.
  var color: Color { get }
}
