//
//  File.swift
//
//
//  Created by Guilherme Souza on 19/05/21.
//

import Combine
import ComposableArchitecture
import Foundation

extension APIClient {

  public static let live = APIClient(
    trackings: { codes in
      apiRequest(.trackings(codes)).apiDecoded()
    }
  )
}

extension Effect where Output == (Data, HTTPURLResponse) {
  func apiDecoded<T: Decodable>(to type: T.Type = T.self) -> Effect<T, Error> {
    tryMap { data, _ in
      try decoder.decode(type, from: data)
    }
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
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()
