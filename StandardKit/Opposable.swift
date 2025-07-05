//
//  Opposable.swift
//  Deus
//
//  Created by Jean Barros Silva on 02/06/25.
//

/// Matter or property which has a counterpart of opposite charge: its ``Anti`` part.
///
/// There is an imbalance regarding the amount of matter and antimatter in nature, unexplained by
/// the Standard Model. In 1967, Andrei Sakharov theorized that such disproportion may have arisen
/// after the very early universe (first 10⁻¹² seconds — picosecond — of its existence) due to
/// factors now known as Sakharov conditions, such as violation of the Baryon number and
/// interactions occurred out of thermal equilibrium.
public protocol Opposable {}

/// Counterpart of an ``Opposable``.
public struct Anti<Counterpart: Opposable> {
  /// Non-anti-matter or -property version of this one.
  let counterpart: Counterpart

  init(_ counterpart: consuming Counterpart) {
    self.counterpart = counterpart
  }
}
