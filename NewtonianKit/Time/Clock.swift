//
//  Clock.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

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

/// Listener of ticks of a ``Clock``.
protocol OnTickListener: AnyObject {
  /// Callback called whenever the ``Clock`` ticks.
  ///
  /// - SeeAlso: ``Clock.start()``
  func onTick() async
}

/// ``Error`` thrown when no ``OnTickListener`` satisfies the critieria for removal from a
///  ``Clock``, either because none with the given ID was found or was, but its type does not match
///  the specified one.
///
/// - SeeAlso: ``Clock.add(onTickListener:)``
/// - SeeAlso: ``Clock.removeOnTickListener(identifiedAs:)``
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

  /// ``Reference`` to ``AnyOnTickListener``s to be notified of ticks of this ``Clock``.
  private var onTickListeners = Set<AnyOnTickListener>()

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
    await listenToTicks()
    await subticker.resume()
    state = .started
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
  /// the added ``OnTickListener``s of its ticks.
  ///
  /// - SeeAlso: ``onTickListeners``
  private func listenToTicks() async {
    await subticker.schedule { [self] elapsedTime in
      guard elapsedTime.containsWholeTick else { return }
      print(onTickListeners)
      for listener in onTickListeners { await listener.onTick() }
    }
  }
}
