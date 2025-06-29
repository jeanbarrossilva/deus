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
/// Family | Baryon number        | Composition       |
/// ------ | -------------------- | ----------------- |
/// Meson  | 0                    | qⁱ ⊗ q̄ⱼ           |
/// Baryon | +1                   | εⁱʲᵏ qⁱ ⊗ qʲ ⊗ qᵏ |
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
public protocol Hadron: ColoredParticle {
  /// ``Quark``s by which this ``Hadron`` is composed, bound by strong force via the gluon
  /// ``Particle``s.
  var quarks: [any Equatable & Quark] { get }
}

extension Hadron where Self: ColoredParticle {
  public var charge: Charge { quarks.reduce(.zero) { charge, quark in quark.charge + charge } }
  public var color: Mixture { .white }
}
