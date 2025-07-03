//
//  Color.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

import Foundation

/// ``Color``s whose cumulative combination result in a white ``Mixture``.
///
/// - SeeAlso: ``Mixture/white``
public let colors: InlineArray<3, any SingleColor> = [red, green, blue]

/// Red (r) direction in the ``Color`` field.
public let red: Red = Red()

/// Green (g) direction in the ``Color`` field.
public let green: Green = Green()

/// Blue (r) direction in the ``Color`` field.
public let blue: Blue = Blue()

/// Relation between each ``Mixture`` and the single ``Color``s by which they are composed.
private let compositions: [Mixture: Set<AnyHashable>] = [
  .red: Set(arrayLiteral: red),
  .green: Set(arrayLiteral: green),
  .blue: Set(arrayLiteral: blue),
  .brown: Set(arrayLiteral: red, green),
  .purple: Set(arrayLiteral: red, blue),
  .cyan: Set(arrayLiteral: green, blue),
  .white: Set(arrayLiteral: red, green, blue)
]

/// Pairing of each single ``Color`` to their respective anticolor (e.g., `self[red] == antired`).
private let colorAnticolorPairs: [AnyHashable: any SingleColor] =
  [red: antired, green: antigreen, blue: antiblue]

/// Antired (r̄) direction in the ``Color`` field.
private let antired = Antired()

/// Antigreen (ḡ) direction in the ``Color`` field.
private let antigreen = Antigreen()

/// Antiblue (b̄) direction in the ``Color`` field.
private let antiblue = Antiblue()

/// Direct (in the case of a gluon ``Particle``) or indirect result of a localized excitation of the
/// ``Color`` field.
public protocol ColoredParticle<Color>: NonOpposableColoredParticle, Particle {}

extension Anti: NonOpposableColoredParticle
where Counterpart: NonOpposableColoredParticle, Counterpart.Color: SingleColor {
  public var color: Anti<Counterpart.Color> { Anti<Counterpart.Color>(counterpart.color) }
}

/// Base protocol to which ``ColoredParticle``s and colored antiparticles conform.
public protocol NonOpposableColoredParticle<Color>: _Particle {
  /// The specific type of ``Color``.
  associatedtype Color: StandardKit.Color

  /// Measured transformation under the SU(3) symmetry.
  var color: Color { get }
}

/// Red (r) direction in the ``Color`` field.
public class Red: SingleColor {
  fileprivate init() {}
}

/// Green (g) direction in the ``Color`` field.
public class Green: SingleColor {
  fileprivate init() {}
}

/// Blue (b) direction in the ``Color`` field.
public class Blue: SingleColor {
  fileprivate init() {}
}

extension SingleColor {
  /// Forms a ``Mixture`` by combining both ``Color``s.
  ///
  /// - Parameters:
  ///   - lhs: ``Color`` to which `rhs` will be combined.
  ///   - rhs: ``Color`` to be combined to `lhs`.
  public static func + (lhs: Self, rhs: any SingleColor) -> Mixture {
    if self === rhs {
      .of(rhs)
    } else if (self === red || self === green) && (rhs === green || rhs === red) {
      .brown
    } else if (self === red || self === blue) && rhs === blue || rhs === red {
      .purple
    } else if (self === green || self === blue) && (rhs === blue || rhs === green) {
      .cyan
    } else {
      .white
    }
  }
}

extension SingleColor where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs === rhs
  }
}

extension SingleColor where Self: Hashable {
  public func hash(into hasher: inout Hasher) {
    colorAnticolorPairs.keys.first(where: { color in color.base as? Self != nil })!.hash(
      into: &hasher
    )
  }
}

/// One direction in the ``Color`` field.
public protocol SingleColor: AnyObject, NonOpposableSingleColor, Opposable {}

extension Anti: Color & NonOpposableSingleColor
where Counterpart: AnyObject & NonOpposableSingleColor {
  /// Combines both ``Color``s into a white ``Mixture``.
  ///
  /// - Parameters:
  ///   - lhs: Anticolor to which `rhs` will be combined.
  ///   - rhs: ``Color`` to be combined to `lhs`.
  public static func + (lhs: Self, rhs: Counterpart) -> Mixture {
    return .white
  }

  /// Combines both ``Color``s into a white ``Mixture``.
  ///
  /// - Parameters:
  ///   - lhs: ``Color`` to which `rhs` will be combined.
  ///   - rhs: Anticolor to be combined to `lhs`.
  public static func + (lhs: Counterpart, rhs: Self) -> Mixture {
    return .white
  }
}

extension Anti: Hashable where Self: NonOpposableSingleColor, Counterpart: NonOpposableSingleColor {
  public func hash(into hasher: inout Hasher) {
    let anticolor = colorAnticolorPairs[counterpart]
    precondition(
      anticolor != nil,
      "No equivalent anticolor for \(counterpart) found. This occurs when "
        + "\((any NonOpposableSingleColor).self) is conformed to outside of the StandardKit "
        + "module, which is completely discouraged and may lead to inconsistencies such as this "
        + "one."
    )
    anticolor?.hash(into: &hasher)
  }
}

extension Anti: Equatable
where Self: NonOpposableSingleColor, Counterpart: NonOpposableSingleColor {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    true
  }
}

/// Base protocol to which ``Color``s and anticolors conform.
public protocol NonOpposableSingleColor: Color, Equatable, Hashable {}

/// Combination of two ``Color``s.
public enum Mixture: CaseIterable, Color {
  /// Combination of two reds.
  ///
  /// - SeeAlso: ``red``
  case red

  /// Combination of two greens.
  ///
  /// - SeeAlso: ``green``
  case green

  /// Combination of two blues.
  ///
  /// - SeeAlso: ``blue``
  case blue

  /// Combination of red and green.
  ///
  /// - SeeAlso: ``red``
  /// - SeeAlso: ``green``
  case brown

  /// Combination of red and blue.
  ///
  /// - SeeAlso: ``red``
  /// - SeeAlso: ``blue``
  case purple

  /// Combination of green and blue.
  ///
  /// - SeeAlso: ``green``
  /// - SeeAlso: ``blue``
  case cyan

  /// Final state of confined ``ColoredParticle``s whose net ``Color`` charge is zero, making them
  /// effectively colorless. Results from the combination of ``Color``-anticolor pairs or of all
  /// ``SingleColor``s (red + green + blue).
  ///
  /// - SeeAlso: ``red``
  /// - SeeAlso: ``green``
  /// - SeeAlso: ``blue``
  case white

  /// Combines the ``Color`` to the ``Mixture``.
  ///
  /// - Parameters:
  ///   - lhs: ``Mixture`` to which the ``Color`` will be combined.
  ///   - rhs: ``Color`` to be combined with the ``Mixture``; the combining ``Color``.
  /// - Returns:
  ///   Scenario                                                                                    | Result                                                               | Example
  ///   ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | --------------------
  ///   ``Mixture`` is white                                                                        | ``Mixture`` composed solely of the combining ``Color``               | White + red = red
  ///   ``Mixture`` is composed by the combining ``Color``                                          | ``Mixture`` as-is                                                    | Brown + red = brown
  ///   ``Mixture`` is composed by one ``Color``                                                    | Result of such ``Color`` + the combining one, as per `Color/+(_:_:)` | Red + green = brown
  ///   ``Mixture`` is composed by two ``Color``s and the combining ``Color`` is the antagonist one | White                                                                | Brown + blue = white
  public static func + (lhs: Self, rhs: some SingleColor) -> Self {
    guard lhs != .white else { return Self.of(rhs) }
    let composition = compositions[lhs]!
    if let singleColor = composition.single { return rhs + (singleColor.base as! any SingleColor) }
    guard compositions[.white]!.subtracting(composition).contains(rhs) else { return lhs }
    return .white
  }

  /// Obtains the ``Mixture`` composed only by the given `color`.
  ///
  /// - Parameter color: ``Color`` whose equivalent single-``Color`` ``Mixture`` will be obtained.
  static func of<SingleColorOfMixture: SingleColor>(_ color: SingleColorOfMixture) -> Self {
    guard
      let mixture =
        compositions
        .first(where: { _, composition in
          guard let singleColor = composition.single else { return false }
          return type(of: singleColor.base) == SingleColorOfMixture.self
        })?
        .key
    else {
      fatalError(
        "No single-color mixture found for \(color) because it is not red, green or blue; rather, "
          + "it appears to be a color unknown by StandardKit. The SingleColor protocol is meant "
          + "for conformance by StandardKit only."
      )
    }
    return mixture
  }
}

extension Collection {
  /// The only element in this `Collection`; or `nil` if the `Collection` contains none or more than
  /// one element.
  fileprivate var single: Element? {
    guard count == 1 else { return nil }
    return self.first!
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

/// Antired (r̄) direction in the ``Color`` field.
private class Antired: SingleColor {
  fileprivate init() {}
}

/// Antigreen (ḡ) direction in the ``Color`` field.
private class Antigreen: SingleColor {
  fileprivate init() {}
}

/// Antiblue (b̄) direction in the ``Color`` field.
private class Antiblue: SingleColor {
  fileprivate init() {}
}
