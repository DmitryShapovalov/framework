import Foundation

extension String {
  func escapeString() -> String {
    let string = replacingOccurrences(of: "\"", with: "\\\"")
    return string
  }

  func convertToDictionary() -> [String: Any]? {
    if let data = self.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: [])
          as? [String: Any]
      } catch { print(error.localizedDescription) }
    }
    return nil
  }
}
