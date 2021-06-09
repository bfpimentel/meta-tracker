#if DEBUG

  import Foundation
  import XCTestDynamicOverlay

  extension APIClient {
    public static let failing = APIClient(
      trackings: {
        .failing("APIClient.trackings(\($0))")
      }
    )
  }

#endif
