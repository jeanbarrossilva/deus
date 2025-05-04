//
//  VirtualSubticker.swift
//  Deus
//
//  Created by Jean Barros Silva on 28/04/25.
//

import DequeModule

@testable import NewtonianKit

/// ``Subticker`` which schedules actions based on a non-wall-clock, virtual time. Its time does not
/// elapse unless requested to do so explicitly via ``advance(by:)``; therefore, the specified
/// action is only executed upon each further advancement.
actor VirtualSubticker: Subticker {
  /// The operation scheduled to be executed periodically.
  ///
  /// - SeeAlso: ``schedule(action:)``
  private var action: ((Subticking) async -> Void)? = nil

  /// Last time the ``action`` was executed upon an advancement of the virtual time. Stored for
  /// determining whether such ``action`` should be executed immediately when advancing such virtual
  /// time or only on the next subtick.
  ///
  /// - SeeAlso: ``advance(by:)``
  private var lastActionExecutionTime: Subticking? = nil

  /// Amounts by which the time has been requested to be advanced while this ``VirtualSubticker``
  /// was interrupted.
  ///
  /// - SeeAlso: ``advance(by:)``
  /// - SeeAlso: ``isInterrupted``
  private var pendingAdvancements = Deque<Subticking>()

  /// Whether execution of the ``action`` has been interrupted, due to this ``VirtualSubticker``
  /// having been paused/stopped.
  ///
  /// - SeeAlso: ``pause()``
  /// - SeeAlso: ``stop()``
  /// - SeeAlso: ``advance(by:)``
  private var isInterrupted = true

  var elapsedTime: Subticking = .zero

  func schedule(action: @escaping (_ elapsedTime: Subticking) async -> Void) {
    self.action = action
  }

  func resume() async {
    isInterrupted = false
    while let pendingAdvancement = pendingAdvancements.popFirst() {
      await _advance(by: pendingAdvancement)
    }
  }

  func pause() {
    isInterrupted = true
  }

  func stop() {
    isInterrupted = true
    pendingAdvancements.removeAll()
    lastActionExecutionTime = nil
    elapsedTime = .zero
  }

  /// Requests the virtual time to be advanced in case this ``VirtualSubticker`` is not
  /// paused/stopped; otherwise, such advancement is performed after it is resumed. When advanced,
  /// the scheduled action will be executed once per subtick (`advancement` times).
  ///
  /// - Parameter advancement: Amount of microseconds by which the virtual time is to be advanced.
  /// - SeeAlso: ``schedule(action:)``
  func advance(by advancement: Subticking) async {
    guard advancement != .zero else { return }
    guard !isInterrupted else {
      pendingAdvancements.append(advancement)
      return
    }
    await _advance(by: advancement)
  }

  /// Advances the virtual time, regardless of whether this ``VirtualSubticker`` is interrupted.
  /// This function is intended for scenarios in which the advancement is guaranteed to be allowed
  /// (i.e., ``isInterrupted`` is `false`).
  ///
  /// - SeeAlso: ``advance(by:)``
  private func _advance(by advancement: Subticking) async {
    let advancementTime = elapsedTime
    for meantime in stride(from: advancementTime, through: advancementTime + advancement, by: 1) {
      elapsedTime = meantime
      guard meantime == advancementTime || lastActionExecutionTime != advancementTime else {
        break
      }
      await action?(elapsedTime)
    }
    lastActionExecutionTime = elapsedTime
  }
}
