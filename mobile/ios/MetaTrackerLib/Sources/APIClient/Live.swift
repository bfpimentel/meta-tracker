//
//  File.swift
//
//
//  Created by Guilherme Souza on 19/05/21.
//

import Combine
import ComposableArchitecture
import Foundation
import Models
import OSLog

let log = Logger(subsystem: "br.dev.native.metatracker.apiclient", category: "main")

extension APIClient {

  public static let live = APIClient(
    trackings: { codes in
      apiRequest(.trackings(codes))
        .apiDecoded(as: [TrackingResponse].self)
        .map { $0.map(Tracking.from(response:)) }
    }
  )
}

extension Effect where Output == (Data, HTTPURLResponse) {
  func apiDecoded<T: Decodable>(as type: T.Type = T.self) -> Effect<T, Error> {
    tryMap { data, _ in try data.apiDecoded() }
      .eraseToEffect()
  }
}

//private let baseURL = URL(string: "http://localhost:3000/api")!
private let baseURL = URL(string: "https://meta.native.dev.br/api")!

private func apiRequest(_ route: Route) -> Effect<(Data, HTTPURLResponse), Error> {
  URLSession.shared
    .dataTaskPublisher(for: route.urlRequest(withBaseURL: baseURL))
    .mapError { $0 as Error }
    .map { ($0, $1 as! HTTPURLResponse) }
    .handleEvents(receiveOutput: { data, response in
      #if DEBUG
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
          return
        }

        guard
          let data = try? JSONSerialization.data(
            withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        else {
          return
        }

        print(String(data: data, encoding: .utf8) ?? "")
      #endif
    })
    .eraseToEffect()
}

private let decoder = { () -> JSONDecoder in
  var decoder = JSONDecoder()
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()

extension Data {

  func apiDecoded<T: Decodable>(as type: T.Type = T.self) throws -> T {
    do {
      return try decoder.decode(type, from: self)
    } catch {
      log.error("error decoding '\(T.self)': \(error as NSError)")
      throw error
    }
  }
}
