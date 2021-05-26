//
//  File.swift
//
//
//  Created by Guilherme Souza on 24/05/21.
//

import Foundation

public struct AnalyticsClient {
  public var initialize: () -> Void
  public var track: (Event) -> Void

  public init(
    initialize: @escaping () -> Void,
    track: @escaping (Event) -> Void
  ) {
    self.initialize = initialize
    self.track = track
  }
}
