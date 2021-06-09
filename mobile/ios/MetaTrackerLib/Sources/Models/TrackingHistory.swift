//  Created by Guilherme Souza on 09/06/21.
//

import Foundation

public enum TrackingHistory {
    public struct Entry: Hashable {
        public let code: String
        public let lastTrackedAt: Date
        
        public init(code: String, lastTrackedAt: Date) {
            self.code = code
            self.lastTrackedAt = lastTrackedAt
        }
    }
}
