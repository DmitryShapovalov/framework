import Foundation
import RxSwift

enum ParamEncoding: Int {
  case url
  case json
  case gzip
}

enum ApiRouter {
  case getTrips(Configuration, Credential)
  case createTrip(Configuration, Credential, TripModel)
  case endTrip(Configuration, Credential, TripModel)
}

extension ApiRouter: APIEndpoint {
  var host: String {
    switch self {
      case let .getTrips(config, _), let .createTrip(config, _, _):
        return config.graphQLHost
      case let .endTrip(config, _, _): return config.restHost
    }
  }

  var path: String {
    switch self {
      case .getTrips, .createTrip: return "/graphql"
      case let .endTrip(_, _, model):
        return "/trips/\(model.trip_id ?? "")/complete"
    }
  }

  var params: Any? {
    switch self {
      case let .getTrips(_, credential):
        return QueryBuilder.buildGraphQLGetTripQuery(credential: credential)
      case let .createTrip(_, credential, model):
        return QueryBuilder.buildGraphQLCreateTripQuery(
          model: model,
          credential: credential
        )
      case .endTrip: return nil
    }
  }

  var body: Data? {
    guard let params = params, encoding != .url else { return nil }
    switch encoding {
      case .json:
        do {
          return try JSONSerialization.data(
            withJSONObject: params,
            options: JSONSerialization.WritingOptions(rawValue: 0)
          )
        } catch { return nil }
      default: return nil
    }
  }

  var encoding: ParamEncoding {
    switch self {
      case .getTrips, .createTrip, .endTrip: return .json
    }
  }

  var method: HTTPMethod {
    switch self {
      case .getTrips, .createTrip, .endTrip: return .post
    }
  }

  var headers: [String: String] {
    switch self {
      case let .getTrips(_, credential), let .createTrip(_, credential, _):
        return ["X-Api-Key": credential.secretKey]
      case let .endTrip(_, credential, _):
        let credentialsString =
          "\(credential.accountID):\(credential.htSecretKey)"
        let credentialsUTF8 = credentialsString.utf8
        let credentialsData = Data(credentialsUTF8)
        let credentialsBase64 = credentialsData.base64EncodedString(options: [])
        return [
          "Content-Type": "application/json",
          "Authorization": "Basic \(credentialsBase64)"
        ]
    }
  }
}
