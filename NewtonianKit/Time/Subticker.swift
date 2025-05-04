//
//  Scheduler.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

/// Amount of time relative to the subticks of a ``Subticker``.
enum Subticking: AdditiveArithmetic, Strideable {
  /// Amount of microseconds represented by this unit. In the case of subticks, their `count` is
  /// returned by the getter of this property as they are; as for ticks, given that theirs are in
  /// milliseconds, it is multiplied by 1,000.
  ///
  /// - SeeAlso: ``.subticks(_:)``
  /// - SeeAlso: ``.ticks(_:)``
  private var inMicroseconds: Int {
    switch self {
    case .subticks(let count):
      count
    case .ticks(let count):
      count * 1_000
    }
  }

  static let zero = Self.subticks(0)

  /// Whether this amount of time is zero or contains a whole tick.
  ///
  /// - SeeAlso: ``zero``
  /// - SeeAlso: ``.ticks(_:)``
  var containsWholeTick: Bool {
    switch self {
    case .subticks(let count):
      count % 1_000 == 0
    case .ticks(_):
      true
    }
  }

  /// Duration in microseconds in which each microsecond equals to one subtick.
  ///
  /// - Parameter count: Amount of subticks — microseconds.
  case subticks(_ count: Int)

  /// Duration in milliseconds in which each millisecond equals to one tick, and each tick is one
  /// thousand subticks.
  ///
  /// - Parameter count: Amount of ticks — milliseconds.
  case ticks(_ count: Int)

  static func + (lhs: Self, rhs: Self) -> Self {
    if lhs == .zero {
      rhs
    } else if rhs == .zero {
      lhs
    } else {
      .subticks(lhs.inMicroseconds + rhs.inMicroseconds)
    }
  }

  static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }

  static func - (lhs: Self, rhs: Self) -> Self {
    if rhs == .zero { lhs } else { .subticks(lhs.inMicroseconds - rhs.inMicroseconds) }
  }

  static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }

  func distance(to other: Self) -> Int {
    inMicroseconds.distance(to: other.inMicroseconds)
  }

  func advanced(by n: Int) -> Self {
    n == -inMicroseconds ? .zero : n == 0 ? self : .subticks(inMicroseconds + n)
  }
}

/// Handles periodic execution of actions and also their interruption, either resumable when paused
/// or definite in case of a stop. Abstracts the main aspect of a ``Clock``: its subticking
/// mechanism.
protocol Subticker: Actor {
  /// Total amount of time elapsed between resumptions and pauses.
  ///
  /// - SeeAlso: ``resume()``
  /// - SeeAlso: ``pause()``
  var elapsedTime: Subticking { get }

  /// Schedules the per-subtick execution of the `action` for when this ``Subticker`` is resumed and
  /// until either paused or stopped.
  ///
  /// - Parameter action: Callback run per subtick.
  /// - SeeAlso: ``resume``
  /// - SeeAlso: ``pause()``
  /// - SeeAlso: ``stop()``
  func schedule(action: @escaping (_ elapsedTime: Subticking) async -> Void)

  /// Either executes the scheduled action until either paused or stopped at each subtick or resumes
  /// it.
  ///
  /// - SeeAlso: ``schedule(action:)``
  /// - SeeAlso: ``pause()``
  /// - Seealso: ``stop()``
  func resume() async

  /// Pauses the execution of an ongoing, scheduled action, and allows posterior resumption.
  ///
  /// - SeeAlso: ``schedule(action:)``
  /// - SeeAlso: ``resume()``
  func pause()

  /// Interrupts an ongoing, scheduled action, cancelling its further executions and resetting the
  /// ``elapsedTime``.
  ///
  /// - SeeAlso: ``schedule(action:)``
  func stop()
}
