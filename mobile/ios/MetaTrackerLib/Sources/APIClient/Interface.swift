import ComposableArchitecture
import Foundation
import Models

public struct APIClient {

  public var trackings: (_ codes: [String]) -> Effect<[Tracking], Error>

  public init(trackings: @escaping (_ codes: [String]) -> Effect<[Tracking], Error>) {
    self.trackings = trackings
  }
}

//public struct TrackingResponse: Decodable {
//  public let code: String
//  public let isTracked: Bool
//  public let isDelivered: Bool?
//  public let postedAt: Date?
//  public let updatedAt: Date?
//  public let events: [Event]
//  public let errorMessage: String?
//
//  public struct Event: Decodable, Equatable, Hashable {
//    public let description: String
//    public let country: String
//    public let state: String?
//    public let city: String?
//    public let trackedAt: Date
//  }
//}
