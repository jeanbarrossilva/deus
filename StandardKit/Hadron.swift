//
//  Hadron.swift
//  Deus
//
//  Created by Jean Barros Silva on 12/06/25.
//

/// ``Particle`` composed by two or more ``Quark``s which are bound by strong force. It is the
/// compositor of nucleons — such as protons and neutrons — and, therefore, the most common
/// composite ``Particle`` in the universe.
///
/// ## Classification
///
/// Hadrons are divided into two families:
///
/// Family     | Baryon number        | Composition       |
/// ---------- | -------------------- | ----------------- |
/// ``Meson``  | 0                    | qⁱ ⊗ q̄ⱼ           |
/// Baryon     | +1                   | εⁱʲᵏ qⁱ ⊗ qʲ ⊗ qᵏ |
///
/// > Glossary: • **Baryon number**: ⅓ of the difference between the number of quarks and that of
///               antiquarks. Because of ``Color`` confinement, a phenomenon in which
///               ``ColoredParticle``s are confined, hadrons cannot have a net ``Color`` charge;
///               thus, a hadron being composed of three ``Quark``s of distinct ``Color``s (a
///               baryon) or of a ``Quark`` and an antiquark (a meson) has a ``Color``-neutral
///               state — it is white;\
///             • **q̄**: antiquark, the antiparticle of a ``Quark``.\
///             • **⊗**: tensor product of two vector spaces *V* and *W*: an *m* × *n* matrix, where
///               *m* is the number of components of *V* and *n* is that of *W*.
public protocol Hadron: ColoredParticle<Mixture> {
  /// `Sequence` of ``Quark``s that compose this ``Hadron``.
  associatedtype Quarks: Sequence<any NonOpposableQuark>

  /// ``Quark``s by which this ``Hadron`` is composed, bound by strong force via the gluon
  /// ``Particle``s.
  var quarks: Quarks { get }
}

extension Hadron {
  public var charge: Charge { quarks.reduce(.zero) { charge, quark in quark.charge + charge } }
  public var color: Mixture { .white }
}

// MARK: - Mesons
extension UpQuark {
  static func + (lhs: Self, rhs: Anti<DownQuark<Self.Color>>) -> PositivePion {
    return PositivePion(quarks: [lhs, rhs])
  }
}

/// ``Pion`` with a positive ``charge`` (π⁺), resulted from u + d̄.
///
/// - SeeAlso: ``UpQuark``
/// - SeeAlso: ``DownQuark``
public struct PositivePion: Equatable, Pion {
  public static let spin = Spin.zero
  public static let symbol = "π⁺"

  public let charge = Charge.elementary(1)
  public let quarks: InlineArray<2, any NonOpposableQuark>

  fileprivate init(quarks: InlineArray<2, any NonOpposableQuark>) {
    self.quarks = quarks
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.charge == rhs.charge
      && lhs.color == rhs.color
      && lhs.quarks[0].isPartiallyEqual(to: rhs.quarks[0])
      && lhs.quarks[1].isPartiallyEqual(to: rhs.quarks[1])
  }
}

/// ``Meson`` composed by ``Quark``-antiquark pairs, produced most commonly via high-energy
/// collisions between ``Hadron``s and specific ``Particle``-antiparticle annihilation.
///
/// ## Etimology
///
/// Its name ("π meson", contracted to "pion") was defined by Hideki Yukawa in 1935 and is
/// indicative of its then-theorized role as a carrier ``Particle`` of strong force, inspired by the
/// visual resemblance between "π" and "介", Kanji that means "to mediate".
///
/// Later, in 1962, Murray Gell-Mann theorized that such force was, rather, mediated by gluons,
/// massless ``Particle``s whose ``Spin`` is 1 *ħ* and which are, consequently, categorized as
/// vector bosons.
///
/// ## Stability
///
/// Because of their lightness, the lifetime of pions is extremely short, resulting in them lasting
/// from 85 attoseconds to ~26.033 ns before their decay into muons and neutrinos (π⁺ → μ + v) or
/// into gamma rays. Therefore, they are considered **unstable**.
public protocol Pion: Meson {}

/// ``Hadron`` composed by an even amount of ``Quark``s.
public protocol Meson: Hadron {}
