//
//  Color.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

/// Relation between each ``Mixture`` and the ``Pigment``s by which they are composed.
private let compositions: [Mixture: Set<Pigment>] = [
  .red: Set([.red]),
  .green: Set([.green]),
  .blue: Set([.blue]),
  .brown: Set([.red, .green]),
  .purple: Set([.red, .blue]),
  .cyan: Set([.green, .blue]),
  .white: Set([.red, .green, .blue])
]

/// A single direction in the ``Color`` field.
///
/// ## Nomenclature
///
/// "Pigment" is not standard terminology for such concept: in the Standard Model, it is simply
/// referred to as color. Here, however, we differentiate single ``Color``s from the result of
/// combining these (``Mixture``s); therefore, "color" is treated as the umbrella term for both.
public indirect enum Pigment: CaseIterable, Color, Equatable, Hashable, Opposable {
  public static var allCases = Set([red, green, blue])

  /// Red (r) direction in the ``Color`` field.
  case red

  /// Green (g) direction in the ``Color`` field.
  case green

  /// Blue (b) direction in the ``Color`` field.
  case blue

  /// Counterpart of a ``Pigment``: antired (r̅), antigreen (g̅) or antiblue (b̅).
  case anti(Pigment)

  /// Forms a ``Mixture`` by combining both ``Pigment``s.
  ///
  /// - Parameters:
  ///   - lhs: ``Pigment`` to which `rhs` will be combined.
  ///   - rhs: ``Pigment`` to be combined to `lhs`.
  public static func + (lhs: Self, rhs: Self) -> Mixture {
    let both = [lhs, rhs]
    return if both.contains(only: .red) {
      .red
    } else if both.contains(only: .green) {
      .green
    } else if both.contains(only: .blue) {
      .blue
    } else if both.either({ first, second in first == .red && second == .green }) {
      .brown
    } else if both.either({ first, second in first == .red && second == .blue }) {
      .purple
    } else if both.either({ first, second in first == .green && second == .blue }) {
      .cyan
    } else {
      .white
    }
  }
}

/// Combination of two ``Color``s.
public enum Mixture: CaseIterable, Color {
  /// Composition of this ``Mixture``.
  private var pigments: Set<Pigment> { compositions[self]! }

  /// Combination of two reds.
  ///
  /// - SeeAlso: ``Pigment/red``
  case red

  /// Combination of two greens.
  ///
  /// - SeeAlso: ``Pigment/green``
  case green

  /// Combination of two blues.
  ///
  /// - SeeAlso: ``Pigment/blue``
  case blue

  /// Combination of red and green.
  ///
  /// - SeeAlso: ``Pigment/red``
  /// - SeeAlso: ``Pigment/green``
  case brown

  /// Combination of red and blue.
  ///
  /// - SeeAlso: ``Pigment/red``
  /// - SeeAlso: ``Pigment/blue``
  case purple

  /// Combination of green and blue.
  ///
  /// - SeeAlso: ``Pigment/green``
  /// - SeeAlso: ``Pigment/blue``
  case cyan

  /// Final state of confined ``ColoredParticle``s whose net ``Color`` charge is zero, making them
  /// effectively colorless. Results from the combination of ``Pigment``-anticolor pairs or of all
  /// ``Pigment``s (red + green + blue).
  ///
  /// - SeeAlso: ``Pigment/red``
  /// - SeeAlso: ``Pigment/green``
  /// - SeeAlso: ``Pigment/blue``
  case white

  /// Combines the ``Pigment`` to the ``Mixture``.
  ///
  /// - Parameters:
  ///   - lhs: ``Mixture`` to which the ``Pigment`` will be combined.
  ///   - rhs: ``Pigment`` to be combined with the ``Mixture``; the combining ``Pigment``.
  /// - Returns:
  ///   Scenario                                                                                        | Result                                                                     | Example
  ///   ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | --------------------
  ///   ``Mixture`` is white                                                                            | ``Mixture`` composed solely of the combining ``Pigment``                   | White + red = red
  ///   ``Mixture`` is composed by the combining ``Pigment``                                            | ``Mixture`` as-is                                                          | Brown + red = brown
  ///   ``Mixture`` is composed by one ``Pigment``                                                      | Result of such ``Pigment`` + the combining one, as per ``Pigment/+(_:_:)`` | Red + green = brown
  ///   ``Mixture`` is composed by two ``Pigment``s and the combining ``Pigment`` is the antagonist one | White                                                                      | Brown + blue = white
  public static func + (lhs: Self, rhs: Pigment) -> Self {
    guard lhs != .white else { return Self.of(rhs) }
    if let singlePigment = lhs.pigments.single { return singlePigment + rhs }
    guard Pigment.allCases.subtracting(lhs.pigments).contains(rhs) else { return lhs }
    return .white
  }

  /// Obtains the ``Mixture`` composed only by the given `pigment`.
  ///
  /// - Parameter pigment: ``Pigment`` whose equivalent ``Mixture`` will be obtained.
  static func of(_ pigment: Pigment) -> Self {
    compositions.first(where: { _, composition in composition.single == pigment })!.key
  }
}

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
/// ## Combination
///
/// Colors can be combined with one another in order to form a ``Mixture`` (e.g., red + green + blue
/// = white). Such operation is performable by `+(_:_:)`, which takes in two colors and produces the
/// result of combining both.
///
/// > Note: None of the two mentioned concepts, color and direction, refer to their classical
/// description (respectively, a visual perception of the electromagnetic spectrum and a projection
/// of physical movement from one point toward another). These are uniquely-quantum properties of a
/// ``ColoredParticle``.
///
/// - SeeAlso: ``Mixture/white``
public protocol Color {}

/// Direct (in the case of a gluon ``Particle``) or indirect result of a localized excitation of the
/// ``Color`` field.
public protocol ColoredParticle<Color>: _ColoredParticle, Particle {}

extension Anti: _ColoredParticle where Counterpart: _ColoredParticle<Pigment> {
  public var color: Pigment { .anti(counterpart.color) }
}

/// Non-``Opposable``-conformant protocol of a ``ColoredParticle``.
public protocol _ColoredParticle<Color>: _Particle {
  /// The specific type of ``Color``.
  associatedtype Color: StandardKit.Color

  /// Measured transformation under the SU(3) symmetry.
  var color: Color { get }
}

extension Collection {
  /// The only element in this `Collection`; or `nil` if the `Array` contains none or more than one
  /// element.
  fileprivate var single: Element? {
    guard count == 1 else { return nil }
    return self.first!
  }
}
