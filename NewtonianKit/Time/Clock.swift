//
//  Clock.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

import Foundation
import Future

/// ``OnTickListener`` by which an instance of a conforming struct or class — the ``base`` — should
/// be wrapped in order to be added and listen to the ticks of a ``Clock``. A randomly generated ID
/// is passed into it upon instantiation, which allows for both ensuring that it is added to a
/// ``Clock`` only once and removing it when it should no longer be notified of ticks.
///
/// - SeeAlso: ``Clock.add(onTickListener:)``
/// - SeeAlso: ``Clock.removeOnTickListener(identifiedAs:)``
private struct AnyOnTickListener: ~Copyable, OnTickListener {
  /// Randomly generated ID.
  let id: UUID

  /// Type-erased, wrapped ``OnTickListener``. It is safe to cast its type to that with which this
  /// struct was instantiated: it is guaranteed that it will always be of type ``O`` (although the
  /// instance itself might have been mutated by calls to ``onTick()``).
  private(set) var base: any OnTickListener

  init<O: OnTickListener>(withID id: UUID, from base: consuming O) {
    self.id = id
    self.base = consume base
  }

  static func == (lhs: borrowing AnyOnTickListener, rhs: borrowing AnyOnTickListener) -> Bool {
    lhs.id == rhs.id
  }

  mutating func onTick() async {
    await base.onTick()
  }

  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}

/// Listener of ticks of a ``Clock``.
protocol OnTickListener: ~Copyable {
  /// Callback called whenever the ``Clock`` ticks.
  ///
  /// - SeeAlso: ``Clock.start()``
  mutating func onTick() async
}

extension DynamicArray where Element: ~Copyable & OnTickListener {
  /// Iterates through this ``DynamicArray`` by borrowing its elements and executing the ``body``
  /// on each of them.
  ///
  /// - Parameter body: Closure into which a borrowed element is passed. Returns whether the
  ///   borrowing should stop at the given element.
  /// - SeeAlso: ``borrowElement(at:by:)``
  @discardableResult
  func borrowElements<R>(until body: (_ index: Int, borrowing Element) -> (R, Bool)) -> [R] {
    var results = [R?](repeating: nil, count: count)
    var resultCount = 0
    for index in startIndex...endIndex {
      let (result, isSatisfied) = borrowElement(at: index, by: { element in body(index, element) })
      results.insert(result, at: index)
      resultCount += 1
      guard isSatisfied else { break }
    }
    results.removeSubrange(resultCount...results.endIndex)
    return results as! [R]
  }

  /// Removes all added elements from this ``DynamicArray``.
  mutating func removeAll() {
    for index in startIndex...endIndex { remove(at: index) }
  }
}

/// ``Error`` thrown when no ``OnTickListener`` satisfies the critieria for removal from a
///  ``Clock``, either because none with the given ID was found or was, but its type does not match
///  the specified one.
///
/// - SeeAlso: ``Clock.add(onTickListener:)``
/// - SeeAlso: ``Clock.removeOnTickListener(withID:ofType:)``
struct UnknownTickListenerError: Error {
  /// Type of the unknown ``OnTickListener``.
  let type: OnTickListener.Type?

  /// ID of the unknown ``OnTickListener``.
  let id: UUID

  fileprivate init(type: OnTickListener.Type?, id: UUID) {
    self.type = type
    self.id = id
  }
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
  /// Current state of this ``Clock``, changed by calls to ``start()``, ``pause()`` and ``stop()``.
  private var state = State.evergreen

  /// ``Subticker`` by which the subticks are scheduled.
  private var subticker: Subticker

  /// ``AnyOnTickListener``s to be notified of ticks of this ``Clock``.
  private var onTickListeners = DynamicArray<AnyOnTickListener>()

  /// One of the four possible states of a ``Clock``.
  private enum State: Comparable {
    /// The ``Clock`` has never been started.
    ///
    /// - SeeAlso: ``Clock.start()``
    case evergreen

    /// The ``Clock`` has been started and is ticking.
    ///
    /// - SeeAlso: ``Clock.start()``
    case started

    /// The ``Clock`` is no longer ticking, but can be resumed by being started again.
    ///
    /// - SeeAlso: ``Clock.pause()``
    /// - SeeAlso: ``Clock.start()``
    case paused

    /// The ``Clock`` is no longer ticking and cannot be resumed because its time has been reset.
    ///
    /// - SeeAlso: ``Clock.stop()``
    case stopped
  }

  init(subticker: Subticker) {
    self.subticker = subticker
  }

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
    guard state != .started else { return }
    await invalidateTickNotification()
    await subticker.resume()
    state = .started
  }

  /// Listens to each tick of this ``Clock``.
  ///
  /// - Parameter onTickListener: ``AnyOnTickListener`` to be added.
  /// - Returns: ID of the ``onTickListener`` with which it can be later removed.
  /// - SeeAlso: ``removeOnTickListener(withID:ofType:)``
  func add<O: OnTickListener>(onTickListener: consuming O) -> UUID {
    let id = UUID()
    add(onTickListener: onTickListener, withID: id)
    return id
  }

  /// Removes a listener of ticks of this ``Clock``.
  ///
  /// - Parameters:
  ///   - id: ID of the ``OnTickListener`` to be removed.
  ///   - type: Exact type of the ``OnTickListener`` to be removed.
  /// - Throws: When an ``OnTickListener`` identified as ``id`` and of type ``type`` is not found.
  @discardableResult
  func removeOnTickListener<O: OnTickListener>(withID id: UUID, ofType type: O.Type) throws -> O {
    guard let removedOnTickListener = try removeOnTickListener(withID: id) as? O else {
      throw UnknownTickListenerError(type: type, id: id)
    }
    return removedOnTickListener
  }

  /// Pauses the passage of time.
  ///
  /// Calling ``start()`` after having called this function resumes the passage of time from where
  /// it was paused.
  func pause() async {
    guard state < .paused else { return }
    await subticker.pause()
    state = .paused
  }

  /// Stops the passage of time, resetting this ``Clock``.
  ///
  /// Calling ``start()`` after having called this function starts the passage of time from the
  /// beginning.
  func stop() async {
    onTickListeners.removeAll()
    guard state != .stopped else { return }
    await subticker.stop()
    state = .stopped
  }

  /// Schedules the action of listening to each subtick performed by the ``scheduler`` and notifying
  /// the added ``OnTickListener``s of its ticks. Should be called whenever a listener is either
  /// added or removed, since an action might not have been scheduled at this point or, in case it
  /// was, it may be leaving newly added listeners unnotified or notifying removed ones.
  ///
  /// - SeeAlso: ``onTickListeners``
  /// - SeeAlso: ``add(onTickListener:)``
  /// - SeeAlso: ``removeOnTickListener(withID:ofType:)``
  private func invalidateTickNotification() async {
    let subticker = subticker
    await subticker.schedule {
      if await subticker.elapsedTime.containsWholeTick {
        for var (listenerID, listener) in self.onTickListeners.borrowElements(
          until: {
            _,
            listener in
            ((listener.id, try! self.removeOnTickListener(withID: listener.id)), false)
          })
        {
          await listener.onTick()
          self.add(onTickListener: listener, withID: listenerID)
        }
      }
    }
  }

  /// Adds a listener of ticks of this ``Clock``.
  ///
  /// - Parameters:
  ///   - onTickListener: ``AnyOnTickListener`` to be added.
  ///   - id: ID with which it can be later removed.
  /// - SeeAlso: ``removeOnTickListener(withID:ofType:)``
  private func add(onTickListener: consuming any OnTickListener, withID id: UUID) {
    onTickListeners.append(AnyOnTickListener(withID: id, from: onTickListener))
  }

  /// Removes a listener of ticks of this ``Clock``. Differs from the public overload in that it
  /// does not require the removed ``OnTickListener`` (that is, in case it is found) to be of a
  /// specific type.
  ///
  /// - Parameter id: ID of the ``OnTickListener`` to be removed.
  /// - SeeAlso: ``removeOnTickListener(withID:ofType:)``
  /// - Throws: When an ``OnTickListener`` identified as ``id`` is not found.
  private func removeOnTickListener(
    withID id: UUID
  ) throws(UnknownTickListenerError) -> any OnTickListener {
    var removedOnTickListener: (any OnTickListener)?
    onTickListeners.borrowElements(until: { index, onTickListener in
      guard onTickListener.id == id else {
        return ((), false)
      }
      removedOnTickListener = (onTickListeners.remove(at: index).base)
      return ((), true)
    })
    guard let removedOnTickListener = removedOnTickListener else {
      throw UnknownTickListenerError(type: nil, id: id)
    }
    return removedOnTickListener
  }
}
