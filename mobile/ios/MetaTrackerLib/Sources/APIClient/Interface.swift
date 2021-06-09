import ComposableArchitecture
import Foundation
import Models

public struct APIClient {

  public var trackings: (_ codes: [String]) -> Effect<[Result<Tracking, TrackingError>], Error>

  public init(
    trackings: @escaping (_ codes: [String]) -> Effect<[Result<Tracking, TrackingError>], Error>
  ) {
    self.trackings = trackings
  }
}

struct TrackingResponse: Decodable {
  let code: String
  let isDelivered: Bool
  let events: [Event]?
  let errorMessage: String?

  struct Event: Decodable, Equatable, Hashable {
    let description: String
    let trackedAt: Date
  }
}

public struct TrackingError: Error, Equatable {
  public let code: String
  public let message: String
}

extension Tracking {
  static func from(response: TrackingResponse) -> Result<Tracking, TrackingError> {
    if let error = response.errorMessage {
      return .failure(TrackingError(code: response.code, message: error))
    }

    return .success(
      Tracking(
        code: response.code, isDelivered: response.isDelivered,
        events: (response.events ?? []).map(Event.init(from:))))
  }
}

extension Tracking.Event {
  init(from response: TrackingResponse.Event) {
    self.init(description: response.description, trackedAt: response.trackedAt)
  }
}
