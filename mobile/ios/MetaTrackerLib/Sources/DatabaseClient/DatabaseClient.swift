import Foundation

public struct DatabaseClient {

  public init() {}
}

#if DEBUG
  import XCTestDynamicOverlay

  extension DatabaseClient {
    public static let failing = DatabaseClient()
  }
#endif
