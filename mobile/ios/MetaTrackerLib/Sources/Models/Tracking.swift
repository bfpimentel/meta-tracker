import Foundation

public struct Tracking: Codable, Hashable, Identifiable {
  public var id: String { code }

  public let code: String
  public let events: [Event]

  public init(code: String, events: [Event]) {
    self.code = code
    self.events = events
  }

  public struct Event: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    public let description: String
    public let trackedAt: Date

    public init(description: String, trackedAt: Date) {
      self.description = description
      self.trackedAt = trackedAt
    }
  }
}
