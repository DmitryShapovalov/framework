import Foundation

public final class Configuration: NSObject {
  var graphQLHost: String
  var restHost: String
  var credential: Credential
  public override init() {
    graphQLHost = Constant.Config.Network.graphQLHost
    restHost = Constant.Config.Network.restHost
    credential = Credential(
      secretKey: "",
      htSecretKey: "",
      accountID: "",
      deviceId: "",
      pk_key: ""
    )
    super.init()
  }

  public convenience init(
    _ graphQLHost: String,
    _ restHost: String,
    _ credential: Credential
  ) {
    self.init()
    self.graphQLHost = graphQLHost
    self.restHost = restHost
    self.credential = credential
  }
}
