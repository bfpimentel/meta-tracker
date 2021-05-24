//
//  File.swift
//
//
//  Created by Guilherme Souza on 19/05/21.
//

import Combine
import ComposableArchitecture
import Foundation
import OSLog

let log = Logger(subsystem: "br.dev.native.metatracker.apiclient", category: "main")

extension APIClient {

  public static let live = APIClient(
    trackings: { codes in
      apiRequest(.trackings(codes)).apiDecoded()
    }
  )
}

extension Effect where Output == (Data, HTTPURLResponse) {
  func apiDecoded<T: Decodable>(to type: T.Type = T.self) -> Effect<T, Error> {
    tryMap { data, _ in try data.apiDecoded() }
      .eraseToEffect()
  }
}

private let baseURL = URL(string: "https://meta.native.dev.br/api")!

private func apiRequest(_ route: Route) -> Effect<(Data, HTTPURLResponse), Error> {
  URLSession.shared
    .dataTaskPublisher(for: route.urlRequest(withBaseURL: baseURL))
    .mapError { $0 as Error }
    .map { ($0, $1 as! HTTPURLResponse) }
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
