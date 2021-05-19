import Foundation

struct Route {
  var method: Method
  var path: String
  var query: [(String, String)] = []
  var headers: [String: String] = [:]

  enum Method: String {
    case get = "GET"
  }

  func urlRequest(withBaseURL baseURL: URL) -> URLRequest {
    guard
      var components = URLComponents(
        url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
    else {
      preconditionFailure("Invalid URL or PATH found.")
    }

    if !query.isEmpty {
      components.queryItems = components.queryItems ?? []
      components.queryItems!.append(contentsOf: query.map(URLQueryItem.init))
    }

    guard let url = components.url else {
      preconditionFailure("Invalid URL")
    }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
    return request
  }
}

extension Route {

  /// GET /trackings?codes={{ codes }}
  static func trackings(_ codes: [String]) -> Route {
    Route(
      method: .get,
      path: "trackings",
      query: [
        ("codes", codes.joined(separator: ","))
      ]
    )
  }
}
