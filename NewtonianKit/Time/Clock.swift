//
//  Clock.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

internal import Collections
import Foundation

/// ``OnTickListener`` by which an instance of a conforming struct or class — the ``base`` — should
/// be wrapped in order to be added and listen to the ticks of a ``Clock``. A randomly generated ID
/// is passed into it upon instantiation, which allows for both ensuring that it is added to a
/// ``Clock`` only once and removing it when it should no longer be notified of ticks.
///
/// - SeeAlso: ``Clock.add(onTickListener:)``
/// - SeeAlso: ``Clock.removeOnTickListener(identifiedAs:)``
private final class AnyOnTickListener: OnTickListener, Identifiable, Hashable {
  let id: UUID

  /// Type-erased, wrapped ``OnTickListener``. It is safe to cast its type to that with which this
  /// struct was instantiated: it is guaranteed that it will always be of type ``O`` (although the
  /// instance itself might have been mutated by calls to ``onTick()``).
  private(set) var base: any AnyObject & OnTickListener

  init<O: AnyObject & OnTickListener>(_ base: O) {
    self.id = (base as? any Identifiable)?.id as? UUID ?? UUID()
    self.base = base
  }

  static func == (lhs: AnyOnTickListener, rhs: AnyOnTickListener) -> Bool {
    lhs.id == rhs.id
  }

  func onTick() async {
    await base.onTick()
  }

  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}

/// Amount of time relative to the subticks of a ``Clock``.
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

/// Listener of ticks of a ``Clock``.
protocol OnTickListener: AnyObject {
  /// Callback called whenever the ``Clock`` ticks.
  ///
  /// - SeeAlso: ``Clock.start()``
  func onTick() async
}

/// Coordinates the passage of time in a simulated universe, allowing for the movement of bodies and
/// other time-based changes to their properties (such as temperature, size, direction, velocity,
/// route, etc.).
///
/// Passage of time is counted per millisecond — referred to here as a _tick_ — from the moment this
/// clock is started and until it is either paused or stopped. Each tick can be listened to by
/// adding a listener, which will be notified at each millisecond until this clock is either paused
/// or stopped.
actor Clock {
  /// ``Reference`` to ``AnyOnTickListener``s to be notified of ticks of this ``Clock``.
  private var onTickListeners = Set<AnyOnTickListener>()

  /// Total amount of time elapsed between resumptions and pauses.
  ///
  /// - SeeAlso: ``start()``
  /// - SeeAlso: ``pause()``
  private(set) var elapsedTime = Subticking.zero

  /// Last time a subtick was performed upon an advancement of time. Stored for determining whether
  /// such this ``Clock`` should perform a subtick immediately when advancing its time or only on
  /// the next advancement.
  ///
  /// - SeeAlso: ``advanceTime(by:)``
  private var lastSubtickTime: Subticking? = nil

  /// Whether the subticking has been interrupted, due to this ``Clock`` having been paused/stopped.
  ///
  /// - SeeAlso: ``pause()``
  /// - SeeAlso: ``stop()``
  private var isInterrupted = true

  /// Initiates the passage of time. From the moment this function is called, this ``Clock`` starts
  /// ticking on a per-millisecond basis and, upon each of its ticks, the added listeners are
  /// notified.
  ///
  /// Calling this function consecutively is a no-op. In case it is called after this ``Clock`` was
  /// paused, the pessage of time is resumed from where it left off; if it was stopped, the time is
  /// restarted.
  ///
  /// - SeeAlso: ``Clock.pause()``
  /// - SeeAlso: ``Clock.stop()``
  func start() async {
    isInterrupted = false
  }

  /// Listens to each tick of this ``Clock``.
  ///
  /// - Parameter onTickListener: ``AnyOnTickListener`` to be added.
  /// - Returns: ID of the ``onTickListener`` with which it can be later removed.
  /// - SeeAlso: ``removeOnTickListener(identifiedAs:)``
  func add(onTickListener: any AnyObject & OnTickListener) -> UUID {
    let onTickListener = AnyOnTickListener(onTickListener)
    onTickListeners.insert(onTickListener)
    return onTickListener.id
  }

  /// Removes a listener of ticks of this ``Clock``.
  ///
  /// - Parameter id: ID of the ``OnTickListener`` to be removed.
  func removeOnTickListener(identifiedAs id: UUID) {
    guard let listener = onTickListeners.first(where: { listener in listener.id == id }) else {
      return
    }
    onTickListeners.remove(listener)
  }

  /// Requests the time to be advanced in case this ``Clock`` is not paused/stopped; When advanced,
  /// this ``Clock`` will tick `advancement.inMicroseconds` / 1,000 times.
  ///
  /// - Parameter advancement: Amount of time by which this ``Clock`` is to be advanced.
  func advanceTime(by advancement: Subticking) async {
    guard !isInterrupted && advancement != .zero else { return }
    let advancementTime = elapsedTime
    for meantime in advancementTime...(advancementTime + advancement) {
      elapsedTime = meantime
      guard
        elapsedTime.containsWholeTick
          && (meantime == advancementTime || lastSubtickTime != advancementTime)
      else { continue }
      for listener in onTickListeners { await listener.onTick() }
    }
    lastSubtickTime = elapsedTime
  }

  /// Pauses the passage of time.
  ///
  /// Calling ``start()`` after having called this function resumes the passage of time from where
  /// it was paused.
  func pause() async {
    isInterrupted = true
  }

  /// Stops the passage of time, resetting this ``Clock``.
  ///
  /// Calling ``start()`` after having called this function starts the passage of time from the
  /// beginning.
  func stop() async {
    onTickListeners.removeAll()
    guard !isInterrupted else { return }
    isInterrupted = true
    lastSubtickTime = nil
    elapsedTime = .zero
  }
}
