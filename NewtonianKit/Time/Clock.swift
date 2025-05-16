//
//  Clock.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

internal import Collections
import Foundation

/// Closure which is executed whenever a ``Clock`` is started.
typealias ClockDidStart = () -> Void

/// ``Identifiable`` listener which is notified of starts of a ``Clock``.
fileprivate final class ClockStartListener: Identifiable, Hashable {
  /// Callback called whenever the ``Clock`` starts.
  private let clockDidStart: ClockDidStart

  /// Denotes whether this ``ClockStartListener`` will continue to be notified after subsequent
  /// ``Clock`` starts.
  private let repetition: Repetition

  let id = UUID()

  /// Frequency with which a ``ClockStartListener`` should be notified.
  enum Repetition {
    /// Notification will be performed only once: either immediately, in case the ``Clock`` is
    /// already ticking; or by the time it is started. Further calls to ``Clock.start()`` after the
    /// ``ClockStartListener`` has been notified will be ignored.
    case once

    /// Callback called after the ``listener`` gets notified.
    ///
    /// Dereferences the ``listener`` in case this is ``.once``.
    ///
    /// - Parameters:
    ///   - clock: ``Clock`` whose start has been listened to.
    ///   - listener: ``ClockStartListener`` to which a start of the ``clock`` has been notified.
    func didNotify(startOf clock: isolated Clock, to listener: ClockStartListener) {
      switch self {
      case .once:
        clock.removeStartListener(identifiedAs: listener.id)
      }
    }
  }

  init(listening repetition: Repetition, clockDidStart: @escaping ClockDidStart) {
    self.repetition = repetition
    self.clockDidStart = clockDidStart
  }

  static func == (lhs: ClockStartListener, rhs: ClockStartListener) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }

  /// Notifies this ``ClockStartListener`` of a start of the ``clock``, calling its ``didStart``
  /// callback.
  ///
  /// - Parameters:
  ///   - clock: ``Clock`` whose start is being notified.
  ///   - isImmediate: Whether this notification is amid ticks of the ``clock`` — in which case it
  ///     is already started and has not *scheduled* the listening to its starts, but is, rather,
  ///     notifying this ``ClockStartListener`` immediately.
  ///
  ///     Setting this to `false` with ``repetition`` == ``Repetition.once`` signals that an
  ///     O(`clock.startListeners.count`) lookup for this ``ClockStartListener`` should be performed
  ///     and it should, then, be removed from such ``Array``. Means that the listening was, in
  ///     fact, scheduled.
  func notify(startOf clock: isolated Clock, isImmediate: Bool) {
    clockDidStart()
    guard !isImmediate else { return }
    repetition.didNotify(startOf: clock, to: self)
  }
}

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
  /// ``Mode`` in which this ``Clock`` is ticking or will tick, determining whether its time is that
  /// of a wall-clock or virtual. It is defined as virtual by default — meaning that it will not
  /// elapse automatically when started; rather, it will do so upon explicit calls to
  /// ``advanceTime(by:)`` —, and can be changed via ``setMode(_:)``.
  private var mode = Mode.virtual
  
  /// ``Timer`` by which the subticking of this ``Clock`` is scheduled performed periodically when
  /// in wall-clock mode. Will be `nil` in case the mode is virtual or upon an advancement of time,
  /// after which it is initialized and fired again.
  ///
  /// - SeeAlso: ``Mode.wall``
  /// - SeeAlso: ``advanceTime(by:)``
  /// - SeeAlso: ``Timer.fire()``
  private var timer: Timer? = nil
  
  /// ``ClockStartListener``s to be notified when this ``Clock`` starts.
  ///
  /// - SeeAlso: ``start()``
  private var startListeners = [ClockStartListener]()

  /// ``AnyTimeLapseListener``s to be notified of ticks of this ``Clock``.
  private var timeLapseListeners = [AnyTimeLapseListener]()

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

  /// Mode based on which a ``Clock`` passes its time. Determines whether its time will elapse
  /// automatically until reset, and such option can be defined at any moment via calls to
  /// ``Clock.setMode(_:)``.
  ///
  /// The main difference between the two modes is, essentially, on whether the passage of time upon
  /// a start is automatic — in such case, the ``.wall`` mode (meaning "walltime") would be used —
  /// or manual, requiring explicit advancements — scenario for which ``.virtual`` is.
  ///
  /// - SeeAlso: ``Clock.reset()``
  enum Mode: Sendable {
    /// Denotes that a ``Clock`` should elapse its time only upon command, with explicit calls to
    /// ``Clock.advanceTime(by:)``. Its ticking is, then, dependent of such advancements, and does
    /// not occur until they are both performed and done so by a sufficient amount — 1,000
    /// microseconds = 1,000 subticks = 1 millisecond = 1 tick.
    ///
    /// This ``Mode`` is especially useful for tests, given that the passage of time can be
    /// precisely controlled and, therefore, is deterministic.
    case virtual

    /// Denotes that a ``Clock`` should elapse its time automatically when started or immediately if
    /// it is currently uninterrupted, via the the mechanisms specific to the underlying operating
    /// system.
    case wall

    /// Callback called before this ``Mode`` is set to the ``clock``.
    ///
    /// Triggers the system-based passage of time in case this is the ``.wall`` ``Mode``; otherwise,
    /// invalidates and dereferences the ``Timer``, since the ``.virtual`` ``Mode`` requires
    /// explicit advancements of time via ``Clock.advanceTime(by:)``.
    ///
    /// - Parameter clock: ``Clock`` whose ``Mode`` will be set to this one.
    /// - SeeAlso: ``Timer.invalidate()``
    fileprivate func willBeSet(to clock: isolated Clock) async {
      guard clock.mode != self else { return }
      clock.timer?.invalidate()
      clock.timer = nil
      await willBeSetToAndDidPrepare(clock: clock)
    }

    /// Handles setting the ``Mode`` of the ``clock`` to this one, considering that the previous
    /// state resulted from the current mode has already been reset and, therefore, it is safe to
    /// perform the configuration specific to this ``Mode``.
    ///
    /// By the time this function is called, it is implicitly guaranteed that:
    ///
    /// - ``clock.mode`` != `self`;
    /// - ``clock.timer`` == `nil`.
    ///
    /// - Parameter clock: ``Clock`` whose ``Mode`` will be set to this one.
    private func willBeSetToAndDidPrepare(clock: isolated Clock) async {
      switch self {
      case .virtual:
        return
      case .wall:
        clock.addStartListener(listening: .once) {
          let timer = Timer(
            timeInterval: 0.00001,
            repeats: true,
            block: { _ in Task { await clock.advanceTimeUnconditionally(by: .microseconds(1)) } }
          )
          clock.timer = timer
          timer.fire()
        }
      }
    }
  }

  /// Determines how time will be elapsed by this ``Clock``: whether virtually — manually —, with
  /// explicit advancements; or as that of a wall-clock, automatically and through the underlying
  /// operating system.
  ///
  /// - Parameter mode: ``Mode`` to be defined and applied in case this ``Clock`` is ticking.
  /// - SeeAlso: ``start()``
  func setMode(_ mode: Mode) async {
    await mode.willBeSet(to: self)
    self.mode = mode
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
    guard isInterrupted else { return }
    isInterrupted = false
    for listener in startListeners { listener.notify(startOf: self, isImmediate: false) }
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
    timeLapseListeners.removeFirst(where: { listener in listener.id == id })
  }

  /// Requests the time to be advanced in case this ``Clock`` is not paused/stopped.
  ///
  /// When advanced, this ``Clock`` will perform `advancement.inMicroseconds` subticks, with 1 tick
  /// per 1,000 subticks.
  ///
  /// - Parameter advancement: Amount of time by which this ``Clock`` is to be advanced.
  func advanceTime(by advancement: Duration) async {
    guard !isInterrupted && advancement != .zero else { return }
    await advanceTimeUnconditionally(by: advancement)
  }

  /// Resets this ``Clock``, stopping the passage of time.
  ///
  /// Calling ``start()`` after having called this function starts the passage of time from the
  /// beginning.
  func reset() async {
    timeLapseListeners.removeAll()
    startListeners.removeAll()
    await setMode(.virtual)
    guard !isInterrupted else { return }
    isInterrupted = true
    lastSubtickTime = nil
    elapsedTime = .zero
  }

  /// Removes a listener of starts of this ``Clock``.
  ///
  /// - Parameter id: ID of the ``ClockStartListener`` to be removed.
  fileprivate func removeStartListener(identifiedAs id: UUID) {
    startListeners.removeFirst(where: { listener in listener.id == id })
  }

  /// Adds ``advancement`` to the time that has elapsed, notifying each added listener when a tick
  /// is performed. Differs from the public function for advancing time in that this one does not
  /// ensure that this ``Clock`` is uninterrupted or the given ``advancement`` is greater than zero:
  /// it is implied that both conditions are true.
  ///
  /// - Parameter advancement: Amount of time by which this ``Clock`` is to be advanced.
  /// - SeeAlso: ``advanceTime(by:)``
  /// - SeeAlso: ``isInterrupted``
  private func advanceTimeUnconditionally(by advancement: Duration) async {
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

  /// Listens to starts of this ``Clock``.
  ///
  /// - Parameters:
  ///   - repetition: Denotes whether this ``ClockStartListener`` will continue to be notified after
  ///     subsequent starts.
  ///   - clockDidStart: Callback called whenever this ``Clock`` starts.
  private func addStartListener(
    listening repetition: ClockStartListener.Repetition,
    _ clockDidStart: @escaping ClockDidStart
  ) {
    let listener = ClockStartListener(listening: repetition, clockDidStart: clockDidStart)
    guard isInterrupted else {
      listener.notify(startOf: self, isImmediate: true)
      return
    }
    startListeners.append(listener)
  }

  /// Base function for ``AnyTimeLapseListener`` adder functions which adds the ``listener`` and
  /// provides its ID for later removal.
  ///
  /// - Parameter listener: ``AnyTimeLapseListener`` to be added.
  /// - Returns: ID of the ``listener`` with which it can be later removed.
  /// - SeeAlso: ``removeTimeLapseListener(identifiedAs:)``
  private func _addTimeLapseListener(_ listener: AnyTimeLapseListener) -> UUID {
    timeLapseListeners.append(listener)
    return listener.id
  }
}

extension Array {
  /// Removes the first element of this ``Array`` matching the ``predicate``.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this ``Array``.
  /// - Parameter predicate: Condition to be satisfied by an element in order for it to be removed.
  /// - Returns: The removed element, or `nil` if none matched the ``predicate``.
  @discardableResult fileprivate mutating func removeFirst(
    where predicate: (Element) throws -> Bool
  ) rethrows -> Element? {
    for (index, element) in enumerated() {
      guard try predicate(element) else { continue }
      return remove(at: index)
    }
    return nil
  }
}

extension Duration {
  /// Whether an integer amount of ticks can be performed by a ``Clock`` within this ``Duration``.
  fileprivate var comprisesWholeTicksOnly: Bool { inMicroseconds % Self.millisecondFactor == 0 }
}
