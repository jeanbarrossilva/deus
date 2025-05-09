//
//  Clock.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

internal import Collections
import Foundation

/// ``TimeLapseListener`` by which an instance of a conforming struct or class — the ``base`` —
/// should be wrapped in order to be added and listen to the ticks of a ``Clock``. A randomly
/// generated ID is passed into it upon instantiation, which allows for both ensuring that it is
/// added to a ``Clock`` only once and removing it when it should no longer be notified of ticks.
///
/// - SeeAlso: ``Clock.add(timeLapseListener:)``
/// - SeeAlso: ``Clock.removeTimeLapseListener(identifiedAs:)``
private final class AnyTimeLapseListener: TimeLapseListener, Identifiable, Hashable {
  let id: UUID

  /// Type-erased, wrapped ``TimeLapseListener``. It is safe to cast its type to that with which
  /// this struct was instantiated: it is guaranteed that it will always be of type ``O`` (although
  /// the instance itself might have been mutated by calls to ``timeDidElapse()``).
  private(set) var base: any AnyObject & TimeLapseListener

  init<O: AnyObject & TimeLapseListener>(_ base: O) {
    self.id = (base as? any Identifiable)?.id as? UUID ?? UUID()
    self.base = base
  }

  static func == (lhs: AnyTimeLapseListener, rhs: AnyTimeLapseListener) -> Bool {
    lhs.id == rhs.id
  }

  func timeDidElapse() async {
    await base.timeDidElapse()
  }

  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}

/// Listener of lapses of time of a ``Clock``.
protocol TimeLapseListener: AnyObject {
  /// Callback called after the ``Clock`` ticks and, therefore, its time has elapsed.
  func timeDidElapse() async
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
  /// ``Reference`` to ``AnyTimeLapseListener``s to be notified of ticks of this ``Clock``.
  private var timeLapseListeners = Set<AnyTimeLapseListener>()

  /// Total amount of time elapsed between resumptions and pauses.
  ///
  /// - SeeAlso: ``start()``
  /// - SeeAlso: ``pause()``
  private(set) var elapsedTime = Duration.zero

  /// Last time a subtick was performed upon an advancement of time. Stored for determining whether
  /// such this ``Clock`` should perform a subtick immediately when advancing its time or only on
  /// the next advancement.
  ///
  /// - SeeAlso: ``advanceTime(by:)``
  private var lastSubtickTime: Duration? = nil

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
  /// - Parameter timeLapseListener: ``AnyTimeLapseListener`` to be added.
  /// - Returns: ID of the ``timeLapseListener`` with which it can be later removed.
  /// - SeeAlso: ``removeTimeLapseListener(identifiedAs:)``
  func add(timeLapseListener: any AnyObject & TimeLapseListener) -> UUID {
    let timeLapseListener = AnyTimeLapseListener(timeLapseListener)
    timeLapseListeners.insert(timeLapseListener)
    return timeLapseListener.id
  }

  /// Removes a listener of ticks of this ``Clock``.
  ///
  /// - Parameter id: ID of the ``TimeLapseListener`` to be removed.
  func removeTimeLapseListener(identifiedAs id: UUID) {
    guard let listener = timeLapseListeners.first(where: { listener in listener.id == id }) else {
      return
    }
    timeLapseListeners.remove(listener)
  }

  /// Requests the time to be advanced in case this ``Clock`` is not paused/stopped.
  ///
  /// When advanced, this ``Clock`` will perform `advancement.inMicroseconds` subticks, with 1 tick
  /// per 1,000 subticks.
  ///
  /// - Parameter advancement: Amount of time by which this ``Clock`` is to be advanced.
  func advanceTime(by advancement: Duration) async {
    guard !isInterrupted && advancement != .zero else { return }
    let advancementTime = elapsedTime
    for meantime in advancementTime...(advancementTime + advancement) {
      elapsedTime = meantime
      guard
        elapsedTime.containsWholeMillisecond
          && (meantime == advancementTime || lastSubtickTime != advancementTime)
      else { continue }
      for listener in timeLapseListeners { await listener.timeDidElapse() }
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
    timeLapseListeners.removeAll()
    guard !isInterrupted else { return }
    isInterrupted = true
    lastSubtickTime = nil
    elapsedTime = .zero
  }
}
