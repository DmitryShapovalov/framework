import Trips
import UIKit

let kPublishableKey = "SavePublishableKey"

struct ServerModel {
  let authURL: String
  let eventURL: String
  let publishableKey: String
  let graphQLHost: String
  let restHost: String
  let graphQLSecretKey: String
  let accountID: String
  let htSecretKey: String

  init(
    authURL: String,
    eventURL: String,
    publishableKey: String,
    graphQLHost: String,
    restHost: String,
    accountID: String,
    graphQLSecretKey: String,
    htSecretKey: String
  ) {
    self.htSecretKey = htSecretKey
    self.accountID = accountID
    self.authURL = authURL
    self.eventURL = eventURL
    self.publishableKey = publishableKey
    self.graphQLHost = graphQLHost
    self.restHost = restHost
    self.graphQLSecretKey = graphQLSecretKey
  }
}

class BaseURLConfigurator: NSObject {
  func changeDevice(name: String?, complition: @escaping (String) -> Void) {
    guard let name = name, !name.isEmpty else {
      complition("Device name is empty")
      return
    }
//    let appDelegate = UIApplication.shared.delegate as? AppDelegate
//    let hyperTrack = appDelegate?.hypertrack
//    guard let hypertrack = hyperTrack else { return }
//    hypertrack.setDeviceName(name)
    complition("Successed")
  }

  func getCurrentBaseURLIndex() -> ServerOptions {
    switch Provider.configManager.config.network.host {
      case "https://live-api.htprod.hypertrack.com": return .live
      case "https://devpoc-api.htdev.hypertrack.com": return .devpoc
      default: return .other
    }
  }

  func getURLWith(index: ServerOptions) -> ServerModel {
    switch index {
      case .live:
        return ServerModel(
          authURL: "https://live-api.htprod.hypertrack.com",
          eventURL: "https://live-api.htprod.hypertrack.com",
          publishableKey:
          "uvIAA8xJANxUxDgINOX62-LINLuLeymS6JbGieJ9PegAPITcr9fgUpROpfSMdL9kv-qFjl17NeAuBHse8Qu9sw",
          graphQLHost:
          "https://s6a3q7vbqzfalfhqi2vr32ugee.appsync-api.us-west-2.amazonaws.com",
          restHost: "https://v3.api.hypertrack.com",
          accountID: "4IZ7fWXxRmmxFL4RWcAgxrPWBD8",
          graphQLSecretKey: "da2-p6gfdp2tyndifmyufg6qfbscv4",
          htSecretKey: "rXc40pSVlYkhJsNkcQCncp-c5CVxQeRi6s6bAWXM6T76bWwUlaUMlQ"
        )
      case .devpoc:
        return ServerModel(
          authURL: "https://devpoc-api.htdev.hypertrack.com",
          eventURL: "https://devpoc-api.htdev.hypertrack.com",
          publishableKey:
          "7rQOIqNZv2rIMp1l75S9X25tDWcreiPOKa0clLu4f47KB5H40i7DxQ5uxqKyORAA2IIeHs8mAl4msa24Emwvig",
          graphQLHost:
          "https://es3btclsqnhftcze6yh4ayn7ae.appsync-api.us-west-2.amazonaws.com",
          restHost: "https://devpoc-public-api.htdev.hypertrack.com",
          accountID: "edyByNehR4dC-OX1MARajJU54pc",
          graphQLSecretKey: "da2-a7jwekil7nf4dogz5q64h53kle",
          htSecretKey: "odOirKVsc4SP8Ph63CoGpKdQrXmzGopKwcOYVGuYmZwk_e0VQOaw9w"
        )
      case .other:
        return ServerModel(
          authURL: "",
          eventURL: "",
          publishableKey: "",
          graphQLHost: "",
          restHost: "",
          accountID: "",
          graphQLSecretKey: "",
          htSecretKey: ""
        )
    }
  }

  func changeBaseURLs(
    hostURL: String?,
    publicKey: String?,
    complition: @escaping (String) -> Void
  ) {
    if let host = hostURL?.encodeUrl, let pKey = publicKey, !host.isEmpty,
      !pKey.isEmpty {
      // Create new config
      let config = Config()
      config.network.host = host
      config.network.htBaseUrl = host
      initializeSDK(
        config: config,
        publishableKey: pKey,
        complition: complition
      )
    } else { complition("New URLs error") }
  }

  func getHyperTrackConfig() -> Config { return Provider.configManager.config }

  private func initializeSDK(
    config: Config,
    publishableKey: String,
    complition: @escaping (String) -> Void
  ) {
    Provider.configManager.updateConfig(config)
    Provider.configManager.save()
    if let firtChar = publishableKey.first {
      let otherPK = String(publishableKey.dropFirst())
      _ = HyperTrack.makeSDK(publishableKey: .init(firtChar, otherPK))
    }
    save(publishableKey: publishableKey)
    complition("initializing")
  }

  private func save(publishableKey: String) {
    UserDefaults.standard.set(publishableKey, forKey: kPublishableKey)
  }

  private func removeFromUserDefaults() {
    UserDefaults.standard.removeObject(forKey: kPublishableKey)
  }
}

extension String {
  var encodeUrl: String {
    return addingPercentEncoding(
      withAllowedCharacters: NSCharacterSet.urlQueryAllowed
    )!
  }
}

extension BaseURLConfigurator {
//  static func mapBaseHyperTrackConfig() -> Configuration {
//    let configurator = BaseURLConfigurator()
//    let configIndex = configurator.getCurrentBaseURLIndex()
//    let serverConfigModel = configurator.getURLWith(index: configIndex)
//    let appDelegate = UIApplication.shared.delegate as? AppDelegate
////    let hypertrack = appDelegate?.hypertrack
////    let credential = Credential(
////      secretKey: serverConfigModel.graphQLSecretKey,
////      htSecretKey: serverConfigModel.htSecretKey,
////      accountID: serverConfigModel.accountID,
////      deviceId: hypertrack?.deviceID ?? "",
////      pk_key: serverConfigModel.publishableKey
////    )
//    let configuration = Configuration(
//      serverConfigModel.graphQLHost,
//      serverConfigModel.restHost,
//      credential
//    )
//    return configuration
//  }
}
