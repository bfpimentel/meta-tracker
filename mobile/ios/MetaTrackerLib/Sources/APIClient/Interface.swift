import ComposableArchitecture
import Foundation
import Models

public struct APIClient {

  public var trackings: (_ codes: [String]) -> Effect<[Tracking], Error>

  public init(trackings: @escaping (_ codes: [String]) -> Effect<[Tracking], Error>) {
    self.trackings = trackings
  }
}

struct TrackingResponse: Decodable {
  let code: String
  let events: [Event]?

  struct Event: Decodable, Equatable, Hashable {
    let description: String
    let trackedAt: Date
  }
}

extension Tracking {
  init(from response: TrackingResponse) {
    self.init(code: response.code, events: (response.events ?? []).map(Event.init(from:)))
  }
}

extension Tracking.Event {
  init(from response: TrackingResponse.Event) {
    self.init(description: response.description, trackedAt: response.trackedAt)
  }
}
