import Foundation

public struct Credential {
  let secretKey: String
  let htSecretKey: String
  let accountID: String
  let device_id: String
  let pk_key: String
  public init(
    secretKey: String,
    htSecretKey: String,
    accountID: String,
    deviceId: String,
    pk_key: String
  ) {
    self.htSecretKey = htSecretKey
    self.pk_key = pk_key
    self.accountID = accountID
    self.secretKey = secretKey
    device_id = deviceId
  }
}
