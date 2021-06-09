import AnalyticsClient
import Secrets
import TelemetryClient

extension AnalyticsClient {
  public static let appTelemetry = Self(
    initialize: {
      let config = TelemetryManagerConfiguration(appID: Secrets.appTelemetryID)
      TelemetryManager.initialize(with: config)
    },
    track: { event in
      TelemetryManager.send(event.name, with: event.additionalPayload)
    }
  )
}
