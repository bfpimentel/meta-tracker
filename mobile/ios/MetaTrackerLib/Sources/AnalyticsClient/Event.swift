import Foundation

public struct Event {
  public let name: String
  public let additionalPayload: [String: String]
}

extension Event {

  public static var appLaunched: Self {
    Event(name: "appLaunched", additionalPayload: [:])
  }
}
