import Foundation

struct AuthToken: Codable {
  let token: String
  let expiresIn: TimeInterval

  init() {
    token = ""
    expiresIn = 0
  }

  init(token: String, expiresIn: TimeInterval) {
    self.token = token
    self.expiresIn = expiresIn
  }

  enum Keys: String, CodingKey {
    case token = "access_token"
    case expiresIn = "expires_in"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Keys.self)
    token = (try? container.decode(String.self, forKey: .token)) ?? ""
    expiresIn = (
      try? container
        .decode(TimeInterval.self, forKey: .expiresIn)
    ) ??
      0
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Keys.self)
    try container.encode(token, forKey: .token)
    try container.encode(expiresIn, forKey: .expiresIn)
  }
}
