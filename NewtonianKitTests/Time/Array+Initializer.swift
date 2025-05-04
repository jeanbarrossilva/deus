//
//  Array+Initializer.swift
//  Deus
//
//  Created by Jean Barros Silva on 03/05/25.
//

extension Array {
  /// Initializes an ``Array`` with ``count`` elements which result from the given closure.
  ///
  /// - Parameters:
  ///   - count: Amount of elements in the ``Array`` (and of times the ``initializer`` is called).
  ///   - initializer: Produces the element to be inserted at the given index.
  init(count: Int, _ initializer: (_ index: Int) -> Element) {
    self =
      count <= 0
      ? .init()
      : .init(
        unsafeUninitializedCapacity: Swift.max(count, 1),
        initializingWith: { buffer, initializedCount in
          for index in 0..<count {
            buffer.baseAddress?.advanced(by: index).initialize(to: initializer(index))
          }
          initializedCount = count
        }
      )
  }
}
