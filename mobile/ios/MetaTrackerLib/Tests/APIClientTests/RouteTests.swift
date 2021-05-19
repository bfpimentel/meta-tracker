import SnapshotTesting
import XCTest

@testable import APIClient

final class RouteTests: XCTestCase {

  private let baseURL = URL(string: "http://localhost:3000/api")!

  func test_route_trackings() {
    let route = Route.trackings(["LE251026577SE", "LE258050301SE"])
    assertSnapshot(matching: route.urlRequest(withBaseURL: baseURL), as: .raw)
  }
}
