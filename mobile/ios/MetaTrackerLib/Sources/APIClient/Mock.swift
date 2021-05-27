#if DEBUG

  import Foundation
  import XCTestDynamicOverlay

  extension APIClient {
    public static let failing = APIClient(
      trackings: {
        XCTFail("APIClient.trackings(\($0)) is unimplemented.")
        return .none
      }
    )
  }

#endif
