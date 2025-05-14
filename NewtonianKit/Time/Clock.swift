//
//  Clock.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

internal import Collections
import Foundation

/// ``TimeLapseListener`` by which an instance of a conforming struct or class — the `base` — should
/// be wrapped in order to be added and listen to the ticks of a ``Clock``. A randomly generated ID
/// is passed into it upon instantiation, which allows for both ensuring that it is added to a
/// ``Clock`` only once and removing it when it should no longer be notified of ticks.
///
/// - SeeAlso: ``Clock.addTimeLapseListener(_:)``
/// - SeeAlso: ``Clock.removeTimeLapseListener(identifiedAs:)``
private final class AnyTimeLapseListener: TimeLapseListener, Identifiable, Hashable {
  let id: UUID

  /// Callback to which calls to ``timeDidElapse(from:after:to:toward)`` delegate.
  private(set) var timeDidElapse: (Duration, Duration?, Duration, Duration) async -> Void

  init(_ base: any AnyObject & TimeLapseListener) {
    id = (base as? any Identifiable)?.id as? UUID ?? UUID()
    timeDidElapse = base.timeDidElapse
  }

  init(timeDidElapse: @escaping TimeDidElapse) {
    id = UUID()
    self.timeDidElapse = timeDidElapse
  }

  static func == (lhs: AnyTimeLapseListener, rhs: AnyTimeLapseListener) -> Bool {
    lhs.id == rhs.id
  }

  func timeDidElapse(
    from start: Duration,
    after previous: Duration?,
    to current: Duration,
    toward end: Duration
  ) async {
    await timeDidElapse(start, previous, current, end)
  }

  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}

/// Listener of lapses of time of a ``Clock``.
protocol TimeLapseListener: AnyObject {
  /// Closure whose signature matches that of the ``timeDidElapse(from:after:to:toward:)`` callback.
  typealias TimeDidElapse = (
    _ start: Duration,
    _ previous: Duration?,
    _ current: Duration,
    _ end: Duration
  ) async -> Void

  /// Callback called after the ``Clock`` ticks and, therefore, its time has elapsed.
  ///
  /// - Parameters:
  ///   - start: Time from which the ``Clock`` is being advanced.
  ///   - previous: Time prior to the ``current`` one.
  ///
  ///     The time of a ``Clock`` elapses 1 ms per tick. However, the lapse may also have been the
  ///     result of an advancement; in such a scenario, it could have been advanced immediately
  ///     instead of linearly, and, therefore, the difference between both times might not be of
  ///     only 1 ms.
  ///
  ///     It will be `nil` if this is the first lapse of time of the ``Clock`` and, in this case,
  ///     ``current`` *may* be zero depending on whether the ``Clock`` has been restarted. If the
  ///     ``Clock`` is resuming, it will be the amount of time elapsed at the moment it was paused.
  ///   - current: Current time of the ``Clock``.
  ///   - end: Target, final time toward which the ``Clock`` is elapsing.
  func timeDidElapse(
    from start: Duration,
    after previous: Duration?,
    to current: Duration,
    toward end: Duration
  ) async
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
  func addTimeLapseListener(_ timeDidElapse: @escaping TimeLapseListener.TimeDidElapse) -> UUID {
    _addTimeLapseListener(AnyTimeLapseListener(timeDidElapse: timeDidElapse))
  }

  /// Listens to each tick of this ``Clock``.
  ///
  /// - Parameter timeLapseListener: ``AnyTimeLapseListener`` to be added.
  /// - Returns: ID of the ``timeLapseListener`` with which it can be later removed.
  /// - SeeAlso: ``removeTimeLapseListener(identifiedAs:)``
  func addTimeLapseListener(_ listener: any AnyObject & TimeLapseListener) -> UUID {
    _addTimeLapseListener(AnyTimeLapseListener(listener))
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
    let start = elapsedTime
    let end = start + advancement
    for meantime in start...end {
      elapsedTime = meantime
      guard elapsedTime.comprisesWholeTicksOnly && (meantime == start || lastSubtickTime != start)
      else { continue }
      for listener in timeLapseListeners {
        await listener.timeDidElapse(
          from: start,
          after: meantime == start ? nil : max(.zero, meantime - .milliseconds(1)),
          to: meantime,
          toward: end
        )
      }
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

  /// Resets this ``Clock``, stopping the passage of time.
  ///
  /// Calling ``start()`` after having called this function starts the passage of time from the
  /// beginning.
  func reset() async {
    timeLapseListeners.removeAll()
    guard !isInterrupted else { return }
    isInterrupted = true
    lastSubtickTime = nil
    elapsedTime = .zero
  }

  /// Base function for ``AnyTimeLapseListener`` adder functions which adds the ``listener`` and
  /// provides its ID for later removal.
  ///
  /// - Parameter listener: ``AnyTimeLapseListener`` to be added.
  /// - Returns: ID of the ``listener`` with which it can be later removed.
  /// - SeeAlso: ``removeTimeLapseListener(identifiedAs:)``
  private func _addTimeLapseListener(_ listener: AnyTimeLapseListener) -> UUID {
    timeLapseListeners.insert(listener)
    return listener.id
  }
}

extension Duration {
  /// Whether an integer amount of ticks can be performed by a ``Clock`` within this ``Duration``.
  fileprivate var comprisesWholeTicksOnly: Bool { inMicroseconds % Self.millisecondFactor == 0 }
}
